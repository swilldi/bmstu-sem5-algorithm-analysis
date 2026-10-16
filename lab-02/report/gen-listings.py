#!/usr/bin/env python3
"""Готовит фрагменты исходного кода для листингов отчёта в listings/.

Из исходников удаляются шапка-комментарий, `import Foundation` и блоки
`#if DEBUG ... #endif`. Длинный файл режется на части перед строками,
начинающимися с заданных маркеров. Для каждого листинга пишется
listings/<имя>.tex: части в minipage не разрываются между страницами,
первая идёт с подписью, следующие — с подписью «Продолжение листинга».

listings 1.11b под XeLaTeX выводит символы кириллицы в обход своего буфера:
они попадают в листинг из пропускаемых строк (firstline/linerange) и меняются
местами с соседними пробелами и знаками. Поэтому листинги вставляются целыми
файлами, а кириллические фрагменты оборачиваются в escape-последовательность
#*...*) (escapeinside в преамбуле) и набираются самим LaTeX.

Использование: python3 gen-listings.py
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CODE = ROOT.parent / "code"
OUT = ROOT / "listings"

# имя -> (исходный файл, подпись, маркеры начала частей 2, 3, ...)
# Часть должна помещаться на страницу: не больше ~28 строк с учётом переносов.
LISTINGS = {
    "matrix": ("Sources/MatrixMultiply/Matrix.swift",
               "Тип матрицы и создание нулевой матрицы", []),
    "standard": ("Sources/MatrixMultiply/MatrixMultiply.swift",
                 "Стандартный алгоритм умножения матриц", []),
    "winograd": ("Sources/MatrixMultiply/WinogradMultiply.swift",
                 "Алгоритм Винограда", ["// Основная матрица"]),
    "winograd-shift": ("Sources/MatrixMultiply/WinogradMultiplyShift.swift",
                       "Алгоритм Винограда с оптимизацией А", ["// Основная матрица"]),
    "winograd-add": ("Sources/MatrixMultiply/WinogradMultiplyAddAsigned.swift",
                     "Алгоритм Винограда с оптимизацией Б", ["// Основная матрица"]),
    "winograd-shift-add": ("Sources/MatrixMultiply/WinogradMultiplyShiftAddAsigned.swift",
                           "Алгоритм Винограда с оптимизациями А и Б", ["// Основная матрица"]),
    "tests": ("Tests/MatrixMultiplyTests/MatrixMultiplyTests.swift",
              "Модульные тесты реализаций алгоритмов",
              ['@Test("Умножение на единичную', '@Test("Прямоугольные 2x3', '@Test("Совпадение']),
    "measure": ("Sources/lab02/TimeMeasure.swift",
                "Замеры процессорного времени",
                ["/// Среднее процессорное", "for n in measureSizes"]),
}


def clean(lines):
    out, skip = [], False
    for line in lines:
        s = line.strip()
        if s == "#if DEBUG":
            skip = True
            continue
        if skip:
            skip = s != "#endif"
            continue
        if s == "import Foundation":
            continue
        out.append(line)
    # шапка «//\n//  File.swift ...» и пустые строки в начале
    while out and (out[0].strip() == "" or out[0].startswith("//")):
        out.pop(0)
    # подряд идущие пустые строки схлопываются в одну
    res = []
    for line in out:
        if line.strip() == "" and res and res[-1].strip() == "":
            continue
        res.append(line)
    return res


CYRILLIC = re.compile(r"[А-Яа-яЁё«»—]+(?:[ ,.:;!?—–-]+[А-Яа-яЁё«»—]+)*")


def comment_start(line):
    """Позиция начала комментария // вне строкового литерала или len(line)."""
    in_str = False
    for i, ch in enumerate(line):
        if ch == '"':
            in_str = not in_str
        elif not in_str and line.startswith("//", i):
            return i
    return len(line)


def escape_cyrillic(line):
    start = comment_start(line)

    def wrap(m):
        # комментарии в листингах курсивные, кириллица в них тоже
        text = m.group(0)
        return "#*{\\itshape " + text + "}*)" if m.start() >= start else "#*" + text + "*)"

    return CYRILLIC.sub(wrap, line)


def strip_blank(lines):
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    return lines


def split(lines, markers):
    parts, cur, pending = [], [], list(markers)
    for line in lines:
        if pending and line.strip().startswith(pending[0]):
            parts.append(cur)
            cur = []
            pending.pop(0)
        cur.append(line)
    parts.append(cur)
    if pending:
        raise SystemExit(f"маркер не найден: {pending[0]}")
    return [strip_blank(p) for p in parts]


OUT.mkdir(exist_ok=True)
for old in list(OUT.glob("*.swift")) + list(OUT.glob("*.tex")):
    old.unlink()
for name, (src, caption, markers) in LISTINGS.items():
    lines = clean((CODE / src).read_text().splitlines())
    parts = split(lines, markers)
    blocks = []
    for i, part in enumerate(parts, 1):
        file = f"{name}.swift" if len(parts) == 1 else f"{name}-{i}.swift"
        (OUT / file).write_text("\n".join(escape_cyrillic(l) for l in part) + "\n")
        print(f"listings/{file}: {len(part)} строк")
        if i == 1:
            opts = f"caption={{{caption}}}, label={{lst:{name}}}"
        else:
            opts = f"title={{Продолжение листинга~\\ref{{lst:{name}}}}}"
        blocks.append("\\noindent\\begin{minipage}{\\linewidth}\n"
                      f"\\lstinputlisting[{opts}]{{{file}}}\n"
                      "\\end{minipage}\n")
    # листинг на \input{listings/<имя>.tex}: части в minipage не разрываются
    (OUT / f"{name}.tex").write_text("% сгенерировано gen-listings.py\n" + "\n".join(blocks))
