//
//  SudokuViewModel.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import Foundation
import Combine

final class SudokuViewModel: ObservableObject {
    @Published private(set) var grid: SudokuGrid
    @Published var selectedRow: Int? = nil
    @Published var selectedCol: Int? = nil
    
    private let seed: String
    private let difficulty: SudokuDifficulty
    
    init(seed: String, difficulty: SudokuDifficulty) {
        self.seed = seed
        self.difficulty = difficulty
        self.grid = SudokuGenerator.generate(seed: seed, difficulty: difficulty)
    }
    
    func select(row: Int, col: Int) {
        selectedRow = row
        selectedCol = col
    }
    
    func set(value: Int) {
        guard let r = selectedRow, let c = selectedCol else { return }
        if grid.cells[r][c].isGiven { return }
        grid.cells[r][c].value = value
    }
    
    func clear() {
        guard let r = selectedRow, let c = selectedCol else { return }
        if grid.cells[r][c].isGiven { return }
        grid.cells[r][c].value = 0
    }
}


