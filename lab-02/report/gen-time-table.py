#!/usr/bin/env python3
"""Строит parts/time-table.tex из ../TimeTestResult/*.csv (время в мс).

Использование: python3 gen-time-table.py
"""
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ALGOS = ["classic", "winograd", "winograd_shift", "winograd_add_assigned"]


def load(name):
    with open(ROOT.parent / "TimeTestResult" / f"{name}.csv") as f:
        return {int(r["size"]): int(r["time_ns"]) for r in csv.DictReader(f)}


def us(ns):
    return f"{ns / 1e6:.2f}".replace(".", "{,}")


data = [load(a) for a in ALGOS]
sizes = sorted(data[0])
even = [n for n in sizes if n % 2 == 0]
odd = [n for n in sizes if n % 2 == 1]

rows = []
for e, o in zip(even, odd):
    rows.append(f"{e} & " + " & ".join(us(d[e]) for d in data)
                + f" & {o} & " + " & ".join(us(d[o]) for d in data) + r" \\")

table = r"""\begin{table}[H]
\caption{Процессорное время умножения квадратных матриц, мс}
\label{tbl:time}
\centering
\small
\setlength{\tabcolsep}{3pt}
\begin{tabular}{|c|c|c|c|c||c|c|c|c|c|}
\hline
\multicolumn{5}{|c||}{\bfseries Чётные размеры} & \multicolumn{5}{c|}{\bfseries Нечётные размеры} \\
\hline
$N$ & Станд. & Виногр. & Опт. А & Опт. Б & $N$ & Станд. & Виногр. & Опт. А & Опт. Б \\
\hline
""" + "\n".join(rows) + r"""
\hline
\end{tabular}
\end{table}
"""
(ROOT / "parts" / "time-table.tex").write_text(table)
print(f"parts/time-table.tex: {len(rows)} строк")
