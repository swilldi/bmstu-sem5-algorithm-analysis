import Testing
@testable import MatrixMultiply

struct NamedAlgorithm: CustomTestStringConvertible, Sendable {
    let name: String
    let algo: @Sendable (Matrix, Matrix) -> Matrix

    var testDescription: String { name }
}

let algorithms: [NamedAlgorithm] = [
    NamedAlgorithm(name: "Классический", algo: matrixMultiply),
    NamedAlgorithm(name: "Виноград", algo: winogradMultiply),
    NamedAlgorithm(name: "Виноград >>1", algo: winogradMultiplyShift),
    NamedAlgorithm(name: "Виноград +=", algo: winogradMultiplyAddAsigned),
    NamedAlgorithm(name: "Виноград >>1 и +=", algo: winogradMultiplyShiftAddAsigned),
]

@Suite("Умножение матриц")
struct MatrixMultiplyTests {

    @Test("Матрицы 1x1", arguments: algorithms)
    func oneByOne(_ a: NamedAlgorithm) {
        #expect(a.algo([[3]], [[-4]]) == [[-12]])
    }

    @Test("Умножение на единичную матрицу", arguments: algorithms)
    func identity(_ a: NamedAlgorithm) {
        let m = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        let e = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
        #expect(a.algo(m, e) == m)
        #expect(a.algo(e, m) == m)
    }

    @Test("Умножение на нулевую матрицу", arguments: algorithms)
    func zero(_ a: NamedAlgorithm) {
        let m = [[1, 2], [3, 4]]
        let z = [[0, 0], [0, 0]]
        #expect(a.algo(m, z) == z)
    }

    @Test("Квадратные 2x2 (чётное M)", arguments: algorithms)
    func square2x2(_ a: NamedAlgorithm) {
        #expect(a.algo([[1, 2], [3, 4]], [[5, 6], [7, 8]]) == [[19, 22], [43, 50]])
    }

    @Test("Квадратные 3x3 (нечётное M)", arguments: algorithms)
    func square3x3(_ a: NamedAlgorithm) {
        let m1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        let m2 = [[9, 8, 7], [6, 5, 4], [3, 2, 1]]
        #expect(a.algo(m1, m2) == [[30, 24, 18], [84, 69, 54], [138, 114, 90]])
    }

    @Test("Прямоугольные 2x3 * 3x2 (нечётное M)", arguments: algorithms)
    func rectangularOdd(_ a: NamedAlgorithm) {
        #expect(a.algo([[1, 2, 3], [4, 5, 6]], [[7, 8], [9, 10], [11, 12]]) == [[58, 64], [139, 154]])
    }

    @Test("Прямоугольные 3x2 * 2x4 (чётное M)", arguments: algorithms)
    func rectangularEven(_ a: NamedAlgorithm) {
        let m1 = [[1, 2], [3, 4], [5, 6]]
        let m2 = [[1, 2, 3, 4], [5, 6, 7, 8]]
        #expect(a.algo(m1, m2) == [[11, 14, 17, 20], [23, 30, 37, 44], [35, 46, 57, 68]])
    }

    @Test("Строка на столбец", arguments: algorithms)
    func rowByColumn(_ a: NamedAlgorithm) {
        #expect(a.algo([[1, 2, 3, 4]], [[1], [2], [3], [4]]) == [[30]])
    }

    @Test("Столбец на строку", arguments: algorithms)
    func columnByRow(_ a: NamedAlgorithm) {
        #expect(a.algo([[1], [2], [3]], [[4, 5]]) == [[4, 5], [8, 10], [12, 15]])
    }

    @Test("Отрицательные элементы", arguments: algorithms)
    func negative(_ a: NamedAlgorithm) {
        #expect(a.algo([[-1, 2], [3, -4]], [[-5, -6], [7, 8]]) == [[19, 22], [-43, -50]])
    }

    @Test("Совпадение с классическим на случайных матрицах", arguments: algorithms, 1...6)
    func randomAgainstClassic(_ a: NamedAlgorithm, _ m: Int) {
        let n = Int.random(in: 1...5), q = Int.random(in: 1...5)
        let m1 = (0..<n).map { _ in (0..<m).map { _ in Int.random(in: -50...50) } }
        let m2 = (0..<m).map { _ in (0..<q).map { _ in Int.random(in: -50...50) } }
        #expect(a.algo(m1, m2) == matrixMultiply(a: m1, b: m2))
    }
}
