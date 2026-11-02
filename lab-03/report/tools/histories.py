"""Операционные и информационные истории алгоритмов ЛР № 3.

Срабатывания получаются моделированием псевдокода (листинги 1 и 2 отчёта);
номер оператора равен номеру строки листинга. Информационная дуга
проводится от последнего срабатывания, записавшего величину, к срабатыванию,
которое её читает.

Запуск из каталога report: python3 tools/histories.py
Результат: graphs/*-history.tex и graphs/stats.tex.
"""

import math
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "graphs"


class Trace:
    def __init__(self):
        self.events = []          # (номер оператора, подпись, кадр вызова)
        self.writer = {}          # величина -> индекс срабатывания
        self.arcs = set()         # информационные дуги (u, v)
        self.frames = []          # подписи кадров вызова в порядке создания

    def run(self, op, label, reads=(), writes=(), frame=0):
        idx = len(self.events)
        self.events.append((op, label, frame))
        for name in reads:
            if name in self.writer:
                self.arcs.add((self.writer[name], idx))
        for name in writes:
            self.writer[name] = idx
        return idx


def iterative(k, s):
    """Листинг 1: операторы --- строки 2--8 (k и s --- аргументы)."""
    t = Trace()
    cells = [f"F{i},{j}" for i in range(k + 1) for j in range(s + 1)]
    t.run(2, "F = 0", writes=cells)
    t.run(3, "F[0][0]", writes=["F0,0"])
    i = 1
    t.run(4, "i = 1", writes=["i"])
    while i <= k:
        j = 1
        t.run(5, "j = 1", writes=["j"])
        while j <= s:
            c = 0
            t.run(6, "c = 0", reads=["j"], writes=["c"])
            while c <= min(9, j):
                t.run(7, f"F[{i}][{j}]",
                      reads=["i", "j", "c", f"F{i},{j}", f"F{i-1},{j-c}"],
                      writes=[f"F{i},{j}"])
                c += 1
                t.run(6, f"c = {c}", reads=["c", "j"], writes=["c"])
            j += 1
            t.run(5, f"j = {j}", reads=["j"], writes=["j"])
        i += 1
        t.run(4, f"i = {i}", reads=["i"], writes=["i"])
    t.run(8, f"F[{k}][{s}]", reads=[f"F{k},{s}"])
    return t


def recursive(k, s):
    """Листинг 2: F --- строки 2--11, S --- строки 13--19."""
    t = Trace()

    def new_frame(label):
        t.frames.append(label)
        return len(t.frames) - 1

    def F(i, j, me):
        p, lab = f"P{me}", f"F({i},{j})"
        t.run(2, lab, reads=[p], frame=me)
        if i == 0:
            t.run(3, lab, reads=[p], frame=me)
            t.run(4 if j == 0 else 6, lab, writes=[f"r{me}"], frame=me)
            result, rvar = (1 if j == 0 else 0), f"r{me}"
        else:
            t.run(7, lab, reads=[p], frame=me)
            if j == 0:
                t.run(8, lab, writes=[f"r{me}"], frame=me)
                result, rvar = 0, f"r{me}"
            else:
                callee = new_frame(f"S({i},{j},0)")
                t.run(10, lab, reads=[p], writes=[f"P{callee}"], frame=me)
                result, rvar = S(i, j, 0, callee), f"R{callee}"
        t.run(11, lab, reads=[rvar], writes=[f"R{me}"], frame=me)
        return result

    def S(i, j, c, me):
        p, lab = f"P{me}", f"S({i},{j},{c})"
        t.run(13, lab, reads=[p], frame=me)
        if c > 9 or c > j:
            t.run(14, lab, writes=[f"t{me}"], frame=me)
            result = 0
        else:
            f_frame = new_frame(f"F({i - 1},{j - c})")
            t.run(16, lab, reads=[p], writes=[f"P{f_frame}"], frame=me)
            a = F(i - 1, j - c, f_frame)
            s_frame = new_frame(f"S({i},{j},{c + 1})")
            t.run(17, lab, reads=[p], writes=[f"P{s_frame}"], frame=me)
            b = S(i, j, c + 1, s_frame)
            t.run(18, lab, reads=[f"R{f_frame}", f"R{s_frame}"],
                  writes=[f"t{me}"], frame=me)
            result = a + b
        t.run(19, lab, reads=[f"t{me}"], writes=[f"R{me}"], frame=me)
        return result

    F(k, s, new_frame(f"F({k},{s})"))
    return t


def levels(t):
    """Ярус вершины: число вершин на наибольшем пути, оканчивающемся в ней."""
    lvl = [1] * len(t.events)
    for u, v in sorted(t.arcs, key=lambda a: a[1]):
        lvl[v] = max(lvl[v], lvl[u] + 1)
    return lvl


def layout_levels(t):
    """Ярусы для рисунка: истоки ставятся непосредственно над потребителями."""
    lvl = levels(t)
    preds = {v for _, v in t.arcs}
    for u in range(len(lvl)):
        succ = [lvl[v] for a, v in t.arcs if a == u]
        if u not in preds and succ:
            lvl[u] = min(succ) - 1
    return lvl


def operational_tikz(t, cols):
    lines = ["\\begin{tikzpicture}[x=26mm,y=-17mm]"]
    for idx, (op, label, _) in enumerate(t.events):
        row, pos = divmod(idx, cols)
        col = pos if row % 2 == 0 else cols - 1 - pos
        lines.append(f"\\node[hist] (e{idx}) at ({col},{row}) "
                     f"{{{op}\\\\[-2pt]\\footnotesize {label}}};")
    for idx in range(len(t.events) - 1):
        lines.append(f"\\draw[flow] (e{idx}) -- (e{idx + 1});")
    lines.append("\\end{tikzpicture}")
    return "\n".join(lines) + "\n"


def route(pos, half, u, v):
    """Изгиб дуги (градусы), при котором она меньше всего задевает вершины."""
    (x0, y0), (x1, y1) = pos[u], pos[v]
    length = math.hypot(x1 - x0, y1 - y0)
    ang = math.atan2(y1 - y0, x1 - x0)

    def points(bend):
        d = 0.3915 * length
        a0 = ang + math.radians(bend)
        a1 = ang + math.pi - math.radians(bend)
        c0 = (x0 + d * math.cos(a0), y0 + d * math.sin(a0))
        c1 = (x1 + d * math.cos(a1), y1 + d * math.sin(a1))
        for i in range(1, 60):
            s = i / 60
            yield tuple((1 - s) ** 3 * p0 + 3 * (1 - s) ** 2 * s * p1
                        + 3 * (1 - s) * s ** 2 * p2 + s ** 3 * p3
                        for p0, p1, p2, p3 in zip((x0, y0), c0, c1, (x1, y1)))

    def hits(bend):
        pts = list(points(bend))
        return sum(1 for n, (cx, cy) in pos.items() if n not in (u, v) and
                   any(abs(px - cx) < half[0] and abs(py - cy) < half[1]
                       for px, py in pts))

    return min((0, 12, -12, 22, -22, 32, -32, 42, -42),
               key=lambda b: (hits(b), abs(b)))


def arc_tikz(u, v, bend):
    # ось y рисунка направлена вниз, поэтому положительный изгиб --- вправо
    if bend == 0:
        return f"\\draw[flow] (e{u}) -- (e{v});"
    side = "right" if bend > 0 else "left"
    return f"\\draw[flow] (e{u}) to[bend {side}={abs(bend)}] (e{v});"


def layered_tikz(t, initial, dx, dy, half, style="hist"):
    """Информационная история по ярусам: строка рисунка --- ярус."""
    lvl = layout_levels(t)
    by_level = {}
    for idx in sorted(range(len(t.events)), key=initial):
        by_level.setdefault(lvl[idx], []).append(idx)
    neighbours = {i: [] for i in range(len(t.events))}
    for u, v in t.arcs:
        neighbours[u].append(v)
        neighbours[v].append(u)
    pos = {}

    def place(l):
        items = by_level[l]
        for p, idx in enumerate(items):
            pos[idx] = ((p - (len(items) - 1) / 2) * dx, (l - 1) * dy)

    order = sorted(by_level)
    for l in order:
        place(l)
    for sweep in range(8):
        for l in (order if sweep % 2 == 0 else order[::-1]):
            def key(idx):
                xs = [pos[n][0] for n in neighbours[idx] if lvl[n] != l]
                return (sum(xs) / len(xs) if xs else pos[idx][0], idx)
            by_level[l].sort(key=key)
            place(l)
    lines = ["\\begin{tikzpicture}[x=1mm,y=-1mm]"]
    for idx, (op, label, _) in enumerate(t.events):
        x, y = pos[idx]
        lines.append(f"\\node[{style}] (e{idx}) at ({x:.1f},{y:.1f}) "
                     f"{{{op}\\\\[-2pt]\\footnotesize {label}}};")
    for u, v in sorted(t.arcs):
        lines.append(arc_tikz(u, v, route(pos, half, u, v)))
    lines.append("\\end{tikzpicture}")
    return "\n".join(lines) + "\n"


# Ручная раскладка информационных историй при k = 1, s = 1
# (номер срабатывания -> координаты центра вершины, мм; ось y вниз).
ITER_INFO_POS = {
    0: (-62, 0), 1: (-22, 0), 3: (8, 0), 2: (60, 0),
    9: (-30, 24), 4: (20, 24), 10: (66, 24),
    5: (-30, 48), 6: (36, 48),
    7: (8, 72), 8: (60, 72),
    11: (8, 96),
}
ITER_INFO_PATHS = {}

REC_INFO_POS = {
    0: (-80, 0), 1: (-56, 0),
    2: (-68, 15),
    3: (-72, 30), 4: (-28, 30), 9: (-2, 30),
    5: (-58, 45), 6: (-36, 45), 10: (6, 45), 11: (28, 45), 16: (50, 45),
    7: (-58, 60), 12: (6, 60), 13: (28, 60), 17: (64, 60),
    8: (-58, 75), 14: (17, 75), 18: (64, 75),
    15: (17, 90), 19: (64, 90),
    20: (40, 105),
    21: (40, 120),
    22: (-24, 135),
    23: (-24, 150),
    24: (-68, 165),
}
REC_INFO_PATHS = {}


def manual_tikz(t, pos, half, style, paths=None):
    paths = paths or {}
    lines = ["\\begin{tikzpicture}[x=1mm,y=-1mm]"]
    for idx, (op, label, _) in enumerate(t.events):
        x, y = pos[idx]
        lines.append(f"\\node[{style}] (e{idx}) at ({x},{y}) "
                     f"{{{op}\\\\[-2pt]\\footnotesize {label}}};")
    for u, v in sorted(t.arcs):
        if (u, v) in paths:
            lines.append(f"\\draw[flow] {paths[(u, v)]};")
        else:
            lines.append(arc_tikz(u, v, route(pos, half, u, v)))
    lines.append("\\end{tikzpicture}")
    return "\n".join(lines) + "\n"


def main():
    OUT.mkdir(exist_ok=True)
    it, rec = iterative(1, 1), recursive(1, 1)
    (OUT / "iter-op-history.tex").write_text(operational_tikz(it, 5))
    (OUT / "rec-op-history.tex").write_text(operational_tikz(rec, 5))
    for name, tr, pos, paths in (("iter", it, ITER_INFO_POS, ITER_INFO_PATHS),
                                 ("rec", rec, REC_INFO_POS, REC_INFO_PATHS)):
        assert set(pos) == set(range(len(tr.events))), name
        (OUT / f"{name}-info-history.tex").write_text(manual_tikz(
            tr, pos, (10, 5.5), "histnarrow", paths))

    rows = []
    for kk, ss in [(1, 1), (2, 1), (2, 2), (3, 5), (3, 15), (4, 18)]:
        a, b = iterative(kk, ss), recursive(kk, ss)
        rows.append((kk, ss, len(a.events), max(levels(a)),
                     len(b.events), max(levels(b))))
    with open(OUT / "stats.tex", "w") as f:
        for r in rows:
            f.write(" & ".join(f"{v:,}".replace(",", "\\,") for v in r)
                    + " \\\\\n\\hline\n")
    for r in rows:
        print(r)
    for name, tr in (("iter", it), ("rec", rec)):
        print(name, len(tr.events), "событий,", max(levels(tr)), "ярусов")


if __name__ == "__main__":
    main()
