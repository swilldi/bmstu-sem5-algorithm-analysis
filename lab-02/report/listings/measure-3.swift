    for n in measureSizes {
        let a = randomMatrix(n, n)
        let b = randomMatrix(n, n)

        var line = String(n).padding(toLength: 6, withPad: " ", startingAt: 0)
        for (i, algorithm) in algorithms.enumerated() {
            let t = measure(algorithm.algo, a, b, repeats: measureRepeats)
            times[i].append(t)
            line += "\(t) #*нс*)".padding(toLength: 24, withPad: " ", startingAt: 0)
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
        print("#*Результаты сохранены в*) \(resultDirectory.path)")
    } catch {
        print("#*Ошибка записи результатов*): \(error)")
    }
}
