package func matrixMultiply(a: Matrix, b: Matrix) -> Matrix {
    let n = a.count, m = a[0].count, q = b[0].count
    var c = matrixInit(n, q)
    
    for i in 0..<n {
        for j in 0..<q {
            for k in 0..<m {
                c[i][j] = c[i][j] + a[i][k] * b[k][j]
            }
        }
    }
    
    return c
}
