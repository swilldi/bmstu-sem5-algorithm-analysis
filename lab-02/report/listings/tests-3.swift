    @Test("#*Прямоугольные*) 2x3 * 3x2 (#*нечётное*) M)", arguments: algorithms)
    func rectangularOdd(_ a: NamedAlgorithm) {
        #expect(a.algo([[1, 2, 3], [4, 5, 6]], [[7, 8], [9, 10], [11, 12]]) == [[58, 64], [139, 154]])
    }

    @Test("#*Прямоугольные*) 3x2 * 2x4 (#*чётное*) M)", arguments: algorithms)
    func rectangularEven(_ a: NamedAlgorithm) {
        let m1 = [[1, 2], [3, 4], [5, 6]]
        let m2 = [[1, 2, 3, 4], [5, 6, 7, 8]]
        #expect(a.algo(m1, m2) == [[11, 14, 17, 20], [23, 30, 37, 44], [35, 46, 57, 68]])
    }

    @Test("#*Строка на столбец*)", arguments: algorithms)
    func rowByColumn(_ a: NamedAlgorithm) {
        #expect(a.algo([[1, 2, 3, 4]], [[1], [2], [3], [4]]) == [[30]])
    }

    @Test("#*Столбец на строку*)", arguments: algorithms)
    func columnByRow(_ a: NamedAlgorithm) {
        #expect(a.algo([[1], [2], [3]], [[4, 5]]) == [[4, 5], [8, 10], [12, 15]])
    }

    @Test("#*Отрицательные элементы*)", arguments: algorithms)
    func negative(_ a: NamedAlgorithm) {
        #expect(a.algo([[-1, 2], [3, -4]], [[-5, -6], [7, 8]]) == [[19, 22], [-43, -50]])
    }
