/// #*{\itshape Среднее процессорное время одного умножения}*) (#*{\itshape нс}*))
func measure(_ algo: MatrixMultiplyFuncition, _ a: Matrix, _ b: Matrix, repeats: Int) -> UInt64 {
    var total: UInt64 = 0
    for _ in 0..<repeats {
        let start = cpuTimeNs()
        let c = algo(a, b)
        let end = cpuTimeNs()
        blackHole(c)
        total += end - start
    }
    return total / UInt64(repeats)
}

/// #*{\itshape Выполняет замеры для всех алгоритмов и пишет по}*) CSV-#*{\itshape файлу на алгоритм}*)
func runTimeMeasurements(_ algorithms: [Algorithm]) {

    // times[i][j] #*{\itshape — время алгоритма}*) i #*{\itshape на размере}*) measureSizes[j]
    var times = Array(repeating: [UInt64](), count: algorithms.count)

    print("n".padding(toLength: 6, withPad: " ", startingAt: 0)
          + algorithms.map { $0.file.padding(toLength: 24, withPad: " ", startingAt: 0) }.joined())
