    // #*{\itshape Основная матрица}*)
    for i in 0..<n {
        for j in 0..<q {
            c[i][j] = -mulH[i] - mulV[j]
            for k in 0..<(m>>1) {
                c[i][j] = c[i][j] + (a[i][2*k] + b[2*k + 1][j]) * (a[i][2*k + 1] + b[2*k][j])
            }
        }
    }
    
    // #*{\itshape Поправка при}*) M #*{\itshape нечетном}*)
    if m % 2 == 1 {
        for i in 0..<n {
            for j in 0..<q {
                c[i][j] = c[i][j] + a[i][m - 1] * b[m - 1][j]
            }
        }
    }
    
    return c
}
