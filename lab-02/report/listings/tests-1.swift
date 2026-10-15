import Testing
@testable import MatrixMultiply

struct NamedAlgorithm: CustomTestStringConvertible, Sendable {
    let name: String
    let algo: @Sendable (Matrix, Matrix) -> Matrix

    var testDescription: String { name }
}

let algorithms: [NamedAlgorithm] = [
    NamedAlgorithm(name: "#*Классический*)", algo: matrixMultiply),
    NamedAlgorithm(name: "#*Виноград*)", algo: winogradMultiply),
    NamedAlgorithm(name: "#*Виноград*) >>1", algo: winogradMultiplyShift),
    NamedAlgorithm(name: "#*Виноград*) +=", algo: winogradMultiplyAddAsigned),
]

@Suite("#*Умножение матриц*)")
struct MatrixMultiplyTests {

    @Test("#*Матрицы*) 1x1", arguments: algorithms)
    func oneByOne(_ a: NamedAlgorithm) {
        #expect(a.algo([[3]], [[-4]]) == [[-12]])
    }
