import MatrixMultiply
import Foundation

typealias Algorithm = (algo: MatrixMultiplyFuncition, decs: String, file: String)

@main
struct App {
    static func main() {
        var app = App()
        app.run()
    }

    let algorithms: [Algorithm] = [
        (matrixMultiply, "Классичесое умножение матриц", "classic"),
        (winogradMultiply, "Алгоритм Винограда без оптимизаций", "winograd"),
        (winogradMultiplyShift, "Алгоритм Винограда + \">>1\"", "winograd_shift"),
        (winogradMultiplyAddAsigned, "Алгоритм Винограда + \"+=\"", "winograd_add_assigned"),
        (winogradMultiplyShiftAddAsigned, "Алгоритм Винограда + \">>1\" + \"+=\"", "winograd_shift_add_assigned")
    ]

    var selectedAlgorithm: Algorithm
    var pathA: String?
    var pathB: String?
    var matrixA: Matrix?
    var matrixB: Matrix?

    init() {
        selectedAlgorithm = algorithms[0]
    }

    mutating func run() {
        while true {
            printMenu()
            guard let choice = readLine() else { return }
            print()

            switch choice.trimmingCharacters(in: .whitespaces) {
            case "1": multiply(with: [selectedAlgorithm])
            case "2": multiply(with: algorithms)
            case "3": showMatrices()
            case "4": selectAlgorithm()
            case "5": (pathA, matrixA) = loadMatrix(name: "A")
            case "6": (pathB, matrixB) = loadMatrix(name: "B")
            case "7": runTimeMeasurements(algorithms)
            case "0": return
            default: print("Неизвестный пункт меню")
            }
            print()
        }
    }

    func printMenu() {
        print(
            """
            Выбранный алгоритм: \(selectedAlgorithm.decs)
            Матрица A: \(pathA ?? "не загружена")
            Матрица B: \(pathB ?? "не загружена")
            --------------------\(String(repeating: "-", count: selectedAlgorithm.decs.count))
            1. Выполнить умножение
            2. Выполнить умножение всеми алгоритмами
            3. Показать матрицы
            4. Выбрать алгоритм
            5. Загрузить матрицу A из файла
            6. Загрузить матрицу B из файла
            7. Замеры времени
            0. Выход
            """
        )
        print("> ", terminator: "")
    }

    func multiply(with selected: [Algorithm]) {
        guard let a = matrixA, let b = matrixB else {
            print("Сначала загрузите матрицы A и B")
            return
        }
        guard a[0].count == b.count else {
            print("Нельзя умножить: в A \(a[0].count) столбцов, а в B \(b.count) строк")
            return
        }

        for algorithm in selected {
            print("\(algorithm.decs):")
            print(algorithm.algo(a, b))
            print()
        }
    }

    func showMatrices() {
        print("Матрица A:")
        if let a = matrixA { print(a) } else { print("не загружена") }
        print("Матрица B:")
        if let b = matrixB { print(b) } else { print("не загружена") }
    }

    mutating func selectAlgorithm() {
        for (i, algorithm) in algorithms.enumerated() {
            print("\(i + 1). \(algorithm.decs)")
        }
        print("> ", terminator: "")

        guard let line = readLine(), let index = Int(line), algorithms.indices.contains(index - 1) else {
            print("Неверный номер алгоритма")
            return
        }
        selectedAlgorithm = algorithms[index - 1]
    }

    /// Возвращает текущие путь и матрицу при ошибке, чтобы не терять загруженное ранее
    func loadMatrix(name: String) -> (String?, Matrix?) {
        let current = name == "A" ? (pathA, matrixA) : (pathB, matrixB)

        print("Путь к файлу с матрицей \(name): ", terminator: "")
        guard let path = readLine()?.trimmingCharacters(in: .whitespaces), !path.isEmpty else {
            return current
        }

        do {
            let matrix = try readMatrix(path: path)
            print("Матрица \(name) загружена: \(matrix.count)x\(matrix[0].count)")
            return (path, matrix)
        } catch {
            print("Ошибка: \(error)")
            return current
        }
    }
}
