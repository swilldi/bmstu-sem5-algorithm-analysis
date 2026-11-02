.PHONY: report graphs code test run

XELATEX = xelatex -interaction=nonstopmode -halt-on-error -output-directory=output

report: graphs code
	cd report && mkdir -p output && $(XELATEX) report.tex > /dev/null && $(XELATEX) report.tex > /dev/null

# Фрагменты кода для листингов приложения А вырезаются по именам функций:
# listings выводит кириллицу из строк, пропущенных параметром firstline
code:
	mkdir -p report/code
	python3 report/tools/extract.py Sources/Algorithms/Algorithms.swift countNumbersBySumDigits > report/code/iterative.swift
	python3 report/tools/extract.py Sources/Algorithms/Algorithms.swift countNumbersBySumDigitsRecursive sumOverDigits > report/code/recursive.swift
	python3 report/tools/extract.py Sources/Algorithms/Algorithms.swift countNumbersBySumDigitsMatrix printMatrixOfCounts > report/code/table.swift
	python3 report/tools/extract.py Tests/Lab03Tests.swift > report/code/tests.swift

graphs:
	cd report && python3 tools/histories.py > /dev/null

test:
	swift test

run:
	swift run lab03
