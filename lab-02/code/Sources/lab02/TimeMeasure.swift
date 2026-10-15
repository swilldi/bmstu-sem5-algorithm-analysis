//
//  TimeMeasure.swift
//  lab02
//

import MatrixMultiply
import Foundation

/// Размеры квадратных матриц: чётные 10, 20, ..., 200 и нечётные 11, 21, ..., 201
let measureSizes = stride(from: 10, through: 200, by: 10).flatMap { [$0, $0 + 1] }
/// Число повторов умножения для одного размера, итоговое время — среднее
let measureRepeats = 10

/// Каталог с результатами: lab-02/TimeTestResult (рядом с папкой code)
let resultDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent() // lab02
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // code
    .deletingLastPathComponent() // lab-02
    .appendingPathComponent("TimeTestResult")

/// Процессорное время текущего потока в наносекундах
func cpuTimeNs() -> UInt64 {
    clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
}

/// Не даёт компилятору выбросить вычисление результата
@inline(never)
func blackHole(_ matrix: Matrix) {}

/// Среднее процессорное время одного умножения (нс)
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

/// Выполняет замеры для всех алгоритмов и пишет по CSV-файлу на алгоритм
func runTimeMeasurements(_ algorithms: [Algorithm]) {
    #if DEBUG
    print("""
        ВНИМАНИЕ: debug-сборка, алгоритмы печатают промежуточные данные и работают медленно.
        Для корректных замеров запустите: swift run -c release
        """)
    #endif

    // times[i][j] — время алгоритма i на размере measureSizes[j]
    var times = Array(repeating: [UInt64](), count: algorithms.count)

    print("n".padding(toLength: 6, withPad: " ", startingAt: 0)
          + algorithms.map { $0.file.padding(toLength: 24, withPad: " ", startingAt: 0) }.joined())
    for n in measureSizes {
        let a = randomMatrix(n, n)
        let b = randomMatrix(n, n)

        var line = String(n).padding(toLength: 6, withPad: " ", startingAt: 0)
        for (i, algorithm) in algorithms.enumerated() {
            let t = measure(algorithm.algo, a, b, repeats: measureRepeats)
            times[i].append(t)
            line += "\(t) нс".padding(toLength: 24, withPad: " ", startingAt: 0)
        }
        print(line)
    }

    do {
        try FileManager.default.createDirectory(at: resultDirectory, withIntermediateDirectories: true)
        for (i, algorithm) in algorithms.enumerated() {
            var csv = "size,time_ns\n"
            for (n, t) in zip(measureSizes, times[i]) {
                csv += "\(n),\(t)\n"
            }
            let url = resultDirectory.appendingPathComponent("\(algorithm.file).csv")
            try csv.write(to: url, atomically: true, encoding: .utf8)
        }
        print("Результаты сохранены в \(resultDirectory.path)")
    } catch {
        print("Ошибка записи результатов: \(error)")
    }
}
