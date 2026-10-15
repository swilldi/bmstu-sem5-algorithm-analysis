    @Test("#*Умножение на единичную матрицу*)", arguments: algorithms)
    func identity(_ a: NamedAlgorithm) {
        let m = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        let e = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
        #expect(a.algo(m, e) == m)
        #expect(a.algo(e, m) == m)
    }

    @Test("#*Умножение на нулевую матрицу*)", arguments: algorithms)
    func zero(_ a: NamedAlgorithm) {
        let m = [[1, 2], [3, 4]]
        let z = [[0, 0], [0, 0]]
        #expect(a.algo(m, z) == z)
    }

    @Test("#*Квадратные*) 2x2 (#*чётное*) M)", arguments: algorithms)
    func square2x2(_ a: NamedAlgorithm) {
        #expect(a.algo([[1, 2], [3, 4]], [[5, 6], [7, 8]]) == [[19, 22], [43, 50]])
    }

    @Test("#*Квадратные*) 3x3 (#*нечётное*) M)", arguments: algorithms)
    func square3x3(_ a: NamedAlgorithm) {
        let m1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        let m2 = [[9, 8, 7], [6, 5, 4], [3, 2, 1]]
        #expect(a.algo(m1, m2) == [[30, 24, 18], [84, 69, 54], [138, 114, 90]])
    }
