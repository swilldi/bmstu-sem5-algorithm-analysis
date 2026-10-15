//
//  WinogradMultiplyAddAsigned.swift
//  lab02
//
//  Created by Dmitriy on 15.10.2026.
//

import Foundation

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
    
    #if DEBUG
    print("A:")
    print(a)
    
    print("mulH: \(mulH)")
    #endif
    
    // mulV
    var mulV = Array(repeating: 0, count: q)
    for i in 0..<q {
        for j in 0..<(m/2) {
            mulV[i] += b[2*j][i] * b[2*j + 1][i]
        }
    }
    
    #if DEBUG
    print("B:")
    print(b)
    
    print("mulV: \(mulV)")
    #endif
    
    // Основная матрица
    for i in 0..<n {
        for j in 0..<q {
            c[i][j] = -mulH[i] - mulV[j]
            for k in 0..<(m/2) {
                c[i][j] += (a[i][2*k] + b[2*k + 1][j]) * (a[i][2*k + 1] + b[2*k][j])
            }
        }
    }
    
    // Поправка при M нечетном
    if m % 2 == 1 {
        for i in 0..<n {
            for j in 0..<q {
                c[i][j] += a[i][m - 1] * b[m - 1][j]
            }
        }
    }
    
    #if DEBUG
    print("result:")
    print(c)
    #endif
    
    return c
}

