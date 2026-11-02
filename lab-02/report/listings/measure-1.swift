import MatrixMultiply

/// #*Размеры квадратных матриц: чётные*) 10, 20, ..., 200 #*и нечётные*) 11, 21, ..., 201
let measureSizes = stride(from: 10, through: 200, by: 10).flatMap { [$0, $0 + 1] }
/// #*Число повторов умножения для одного размера, итоговое время — среднее*)
let measureRepeats = 10

/// #*Каталог с результатами*): lab-02/TimeTestResult (#*рядом с папкой*) code)
let resultDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent() // lab02
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // code
    .deletingLastPathComponent() // lab-02
    .appendingPathComponent("TimeTestResult")

/// #*Процессорное время текущего потока в наносекундах*)
func cpuTimeNs() -> UInt64 {
    clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
}

/// #*Не даёт компилятору выбросить вычисление результата*)
@inline(never)
func blackHole(_ matrix: Matrix) {}
