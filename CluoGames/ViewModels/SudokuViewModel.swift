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
    private let solution: SudokuGrid
    @Published var selectedRow: Int? = nil
    @Published var selectedCol: Int? = nil
    
    private let seed: String
    private let difficulty: SudokuDifficulty
    
    init(seed: String, difficulty: SudokuDifficulty) {
        self.seed = seed
        self.difficulty = difficulty
        let generated = SudokuGenerator.generate(seed: seed, difficulty: difficulty)
        self.grid = generated.puzzle
        self.solution = generated.solution
    }
    
    init(puzzle: SudokuGrid, solution: SudokuGrid) {
        self.seed = ""
        self.difficulty = .easy // Default for past games
        self.grid = puzzle
        self.solution = solution
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
    
    func revealAll() {
        // Fill values from the solution but preserve original isGiven flags
        for r in 0..<9 {
            for c in 0..<9 {
                grid.cells[r][c].value = solution.cells[r][c].value
                // do NOT change grid.cells[r][c].isGiven
            }
        }
    }
    
}


