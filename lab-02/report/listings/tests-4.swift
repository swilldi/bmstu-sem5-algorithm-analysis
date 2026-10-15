    @Test("#*Совпадение с классическим на случайных матрицах*)", arguments: algorithms, 1...6)
    func randomAgainstClassic(_ a: NamedAlgorithm, _ m: Int) {
        let n = Int.random(in: 1...5), q = Int.random(in: 1...5)
        let m1 = (0..<n).map { _ in (0..<m).map { _ in Int.random(in: -50...50) } }
        let m2 = (0..<m).map { _ in (0..<q).map { _ in Int.random(in: -50...50) } }
        #expect(a.algo(m1, m2) == matrixMultiply(a: m1, b: m2))
    }
}
