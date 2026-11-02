public func countNumbersBySumDigitsRecursive(sumTarget: Int, digitsCount: Int) -> Int {
    return countRecursive(digitsCount, sumTarget)
}

// F(i, j) – кол-во i-значных чисел, сумма цифр которых j
func countRecursive(_ i: Int, _ j: Int) -> Int {
    let r: Int
    if i == 0 {
        if j == 0 {
            r = 1
        } else {
            r = 0
        }
    } else if j == 0 {
        r = 0
    } else {
        r = sumOverDigits(i, j, 0)
    }
    return r
}

// S(i, j, c) – сумма F(i - 1, j - d) по цифрам d от c до min(9, j)
func sumOverDigits(_ i: Int, _ j: Int, _ c: Int) -> Int {
    let t: Int
    if c > 9 || c > j {
        t = 0
    } else {
        let a = countRecursive(i - 1, j - c)
        let b = sumOverDigits(i, j, c + 1)
        t = a + b
    }
    return t
}
