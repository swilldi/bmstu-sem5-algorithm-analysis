#!/usr/bin/env python3
"""Строит parts/time-table.tex из ../TimeTestResult/*.csv (время в мс).

Две таблицы: для чётных и для нечётных размеров матриц.

Использование: python3 gen-time-table.py
"""
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ALGOS = ["classic", "winograd", "winograd_shift", "winograd_add_assigned",
         "winograd_shift_add_assigned"]
HEADER = r"$N$ & Станд. & Виногр. & Опт. А & Опт. Б & Опт. А и Б \\"


def load(name):
    with open(ROOT.parent / "TimeTestResult" / f"{name}.csv") as f:
        return {int(r["size"]): int(r["time_ns"]) for r in csv.DictReader(f)}


def ms(ns):
    return f"{ns / 1e6:.2f}".replace(".", "{,}")


def table(sizes, caption, label):
    rows = "\n".join(f"{n} & " + " & ".join(ms(d[n]) for d in data) + r" \\ \hline"
                     for n in sizes)
    return rf"""\begin{{table}}[H]
\caption{{{caption}}}
\label{{{label}}}
\centering
\begin{{tabular}}{{|c|c|c|c|c|c|}}
\hline
{HEADER}
\hline
{rows}
\end{{tabular}}
\end{{table}}
"""


data = [load(a) for a in ALGOS]
sizes = sorted(data[0])
even = [n for n in sizes if n % 2 == 0]
odd = [n for n in sizes if n % 2 == 1]

text = (table(even, "Процессорное время умножения квадратных матриц чётного размера, мс", "tbl:time")
        + "\n"
        + table(odd, "Процессорное время умножения квадратных матриц нечётного размера, мс", "tbl:time-odd"))
(ROOT / "parts" / "time-table.tex").write_text(text)
print(f"parts/time-table.tex: {len(even)} + {len(odd)} строк")
