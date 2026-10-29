//
//  main.swift
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

let k = 3
let s = 15
let r = countNumbersBySumDigits(sumTarget: s, digitsCount: k)

