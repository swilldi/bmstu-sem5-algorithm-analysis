//
//  Algorithms.swift
//  lab-03
//
//  Created by Dmitriy Dudyrev on 29.10.2026.
//

import Foundation

public func countNumbersBySumDigits(sumTarget: Int, digitsCount: Int) -> Int {
    // cnt[i][j] – кол-во i-значных чисел, с суммой j
    var cnt = Array(repeating: Array(repeating: 0, count: sumTarget + 1), count: digitsCount + 1)
    
    // Начальные значения
    cnt[0][0] = 1
    
    for i in 1...digitsCount {
        for s in 1...sumTarget {
            for с in 0..<10 {
                if s - с < 0 { break }
                cnt[i][s] += cnt[i - 1][s - с]
            }
        }
    }
    
    return cnt[digitsCount][sumTarget]
}


public func countNumbersBySumDigitsMatrix(sumTarget: Int, digitsCount: Int) -> [[Int]] {
    // cnt[i][j] – кол-во i-значных чисел, с суммой j
    var cnt = Array(repeating: Array(repeating: 0, count: sumTarget + 1), count: digitsCount + 1)
    
    // Начальные значения
    cnt[0][0] = 1
    
    for i in 1...digitsCount {
        for s in 1...sumTarget {
            for с in 0..<10 {
                if s - с < 0 { break }
                cnt[i][s] += cnt[i - 1][s - с]
            }
        }
    }
    
    return cnt
}


public func printMatrixOfCounts(_ matrix: [[Int]]) {
    for row in matrix {
        for elem in row {
            print(elem, terminator: "\t")
        }
        print()
    }
}
