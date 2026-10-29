//  lab03.swift
//  lab-03
//
//  Created by Dmitriy Dudyrev on 29.10.2026.
//

//Даны натуральные числа k и s. Определите, сколько существует k-значных натуральных чисел, сумма цифр которых равна d. Запись натурального числа не может начинаться с цифры 0.
//
//В этой задаче можно использовать цикл для перебора всех цифр, стоящих на какой-либо позиции.
//
//Ввод    Вывод
//3        69
//15


import Foundation
import Algorithms

@main
struct App {
//    var s: Int?
//    var k: Int?
    
    var running = true
    func run() {
        while running {
            guard let s = readNumer("Введите s: ") else {
                continue
            }
            
            guard let k = readNumer("Введите k: ") else {
                continue
            }
            
            showResult(s: s, k: k)
        }
    }
    
    func showResult(s: Int, k: Int) {
        let resultMatrix = countNumbersBySumDigitsMatrix(sumTarget: s, digitsCount: k)
        printMatrixOfCounts(resultMatrix)
        print("Количество \(k)-значных чисел, сумма цифр которых \(s) -- \(resultMatrix[k][s])")
    }
    
    func readNumer(_ msg: String?) -> Int? {
        if let msg {
            print(msg, terminator: "")
        }
        guard let numStr = readLine() else { return nil }
        return Int(numStr)
    }
    
    static func main() {
        let app = App()
//        app.run()
        app.showResult(s: 15, k: 5)
    }
}

