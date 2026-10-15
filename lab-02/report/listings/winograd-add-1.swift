package func winogradMultiplyAddAsigned(a: Matrix, b: Matrix) -> Matrix {
    let n = a.count, m = a[0].count, q = b[0].count
    var c = matrixInit(n, q)
    
    // mulH
    var mulH = Array(repeating: 0, count: n)
    for i in 0..<n {
        for j in 0..<(m/2) {
            mulH[i] += a[i][2*j] * a[i][2*j + 1]
        }
    }
    
    // mulV
    var mulV = Array(repeating: 0, count: q)
    for i in 0..<q {
        for j in 0..<(m/2) {
            mulV[i] += b[2*j][i] * b[2*j + 1][i]
        }
    }
