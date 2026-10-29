//
//  Test.swift
//  lab-03
//
//  Created by Dmitriy Dudyrev on 29.10.2026.
//

import Testing
@testable import Algorithms


struct Lab03Tests {
    @Test("Проверка подсчета i-значных чисел, сумма цифр которых s", arguments: [
            (4, 1, 1),
            (14, 1, 0),
            (15, 3, 69),
            (28, 3, 0),
            (2, 2, 2),
            (1, 4, 1),
            (36, 4, 1),
          ])
    func countSumsOfDigits(s: Int, k: Int, expected: Int) {
        let r = countNumbersBySumDigits(sumTarget: s, digitsCount: k)
        #expect(r == expected)
    }
    
}
