//
//  Algorithm.swift
//  lab-03
//
//  Created by Dmitriy Dudyrev on 29.10.2026.
//

import Foundation

func countNumbersBySumDigits(sumTarget: Int, digitsCount: Int) -> Int {
    let cnt: = Array(repeating: Array(repeating: 0, count: sumTarget), count: digitsCount)
    
    // Начальные значения
    for i in 0..<10 {
        cnt[1][i] = 1
    }
    
    
    for i in 1..<digitsCount {
        for s in 0..<sumTarget {
            for j in 0..<10 {
                cnt[i][s] += cnt[i][s - j]
            }
        }
    }
    
    #if DEBUG
    for row in cnt {
        for elem in row {
            print(elem, terminator: "\t")
        }
        print()
    }
    #endif
    
    return cnt[digitsCount][sumTarget]
}
