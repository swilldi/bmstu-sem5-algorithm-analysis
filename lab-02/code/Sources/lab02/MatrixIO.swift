//
//  MatrixIO.swift
//  lab02
//

import MatrixMultiply
import Foundation

enum MatrixReadError: Error, CustomStringConvertible {
    case cannotOpen(String)
    case empty
    case notANumber(line: Int, token: String)
    case notRectangular(line: Int)

    var description: String {
        switch self {
        case .cannotOpen(let path): "не удалось открыть файл \(path)"
        case .empty: "файл не содержит матрицы"
        case .notANumber(let line, let token): "строка \(line): \"\(token)\" не является целым числом"
        case .notRectangular(let line): "строка \(line): число элементов отличается от первой строки"
        }
    }
}

/// Читает матрицу из текстового файла: одна строка файла — одна строка матрицы,
/// элементы разделены пробелами. Пустые строки пропускаются.
func readMatrix(path: String) throws(MatrixReadError) -> Matrix {
    guard let text = try? String(contentsOfFile: path, encoding: .utf8) else {
        throw .cannotOpen(path)
    }

    var matrix: Matrix = []
    for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
        let tokens = line.split(whereSeparator: \.isWhitespace)
        if tokens.isEmpty { continue }

        var row: [Int] = []
        for token in tokens {
            guard let value = Int(token) else {
                throw .notANumber(line: index + 1, token: String(token))
            }
            row.append(value)
        }

        if let first = matrix.first, first.count != row.count {
            throw .notRectangular(line: index + 1)
        }
        matrix.append(row)
    }

    if matrix.isEmpty { throw .empty }
    return matrix
}

func randomMatrix(_ n: Int, _ m: Int, in range: ClosedRange<Int> = -100...100) -> Matrix {
    (0..<n).map { _ in (0..<m).map { _ in Int.random(in: range) } }
}
