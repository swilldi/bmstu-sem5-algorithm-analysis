package typealias MatrixMultiplyFuncition = (Matrix, Matrix) -> Matrix
package typealias Matrix = [[Int]]

package func matrixInit(_ n: Int, _ m: Int) -> Matrix {
    Array(repeating: Array(repeating: 0, count: m), count: n)
}

package func print(_ matrix: Matrix) {
    for r in matrix {
        print(r)
    }
}
