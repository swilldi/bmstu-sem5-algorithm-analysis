"""Вырезает фрагмент исходного кода для листинга.

python3 extract.py ФАЙЛ ПЕРВАЯ_ФУНКЦИЯ [ПОСЛЕДНЯЯ_ФУНКЦИЯ]
Фрагмент начинается строкой с объявлением первой функции (и примыкающими
к ней комментариями) и заканчивается первой строкой «}» после объявления
последней функции. Без имён функций выводится файл без шапки-комментария.
"""
import re
import sys

lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
if len(sys.argv) == 2:
    start = next(i for i, l in enumerate(lines) if l and not l.startswith("//"))
    print("\n".join(lines[start:]).rstrip())
    sys.exit()
first = sys.argv[2]
last = sys.argv[3] if len(sys.argv) > 3 else first
decl = lambda name: re.compile(rf"^(public )?func {re.escape(name)}\(")
start = next(i for i, l in enumerate(lines) if decl(first).match(l))
while start > 0 and lines[start - 1].startswith("//"):
    start -= 1
end = next(i for i, l in enumerate(lines) if decl(last).match(l))
end = next(i for i in range(end, len(lines)) if lines[i] == "}")
print("\n".join(lines[start:end + 1]))
