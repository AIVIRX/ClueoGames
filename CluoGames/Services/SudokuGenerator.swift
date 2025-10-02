//
//  SudokuGenerator.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import Foundation

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed &* 6364136223846793005 &+ 1 }
    mutating func next() -> UInt64 {
        state = state &* 2862933555777941757 &+ 3037000493
        return state
    }
}

final class SudokuGenerator {
    struct GeneratedSudoku {
        let puzzle: SudokuGrid
        let solution: SudokuGrid
    }
    static func generate(seed: String, difficulty: SudokuDifficulty) -> GeneratedSudoku {
        print("🔢 Generating with seed: '\(seed)'")
        let hashed = deterministicHash(seed)
        print("🔢 Deterministic hash: \(hashed)")
        var rng = SeededRandomNumberGenerator(seed: hashed)
        var solution = baseSolvedGrid()
        
        // Test RNG consistency
        let firstRandom = rng.next()
        print("🔢 First random: \(firstRandom)")
        
        // Apply random valid transformations deterministically
        applyRandomTransforms(&solution, rng: &rng)
        // Remove cells based on difficulty
        var puzzle = solution
        removeCells(&puzzle, difficulty: difficulty, rng: &rng)
        
        // Print first row for comparison
        let firstRow = puzzle.cells[0].map { $0.isGiven ? "\($0.value)" : "_" }.joined(separator: " ")
        print("🔢 First row: \(firstRow)")
        
        return GeneratedSudoku(puzzle: puzzle, solution: solution)
    }
    
    private static func baseSolvedGrid() -> SudokuGrid {
        // Standard Latin square base pattern
        var grid = SudokuGrid.empty()
        for r in 0..<9 {
            for c in 0..<9 {
                let value = ((r * 3) + (r / 3) + c) % 9 + 1
                grid[r, c] = SudokuCell(row: r, col: c, value: value, isGiven: true)
            }
        }
        return grid
    }
    
    private static func applyRandomTransforms(_ grid: inout SudokuGrid, rng: inout SeededRandomNumberGenerator) {
        // Swap rows within bands, columns within stacks, shuffle bands and stacks
        func swapRows(_ a: Int, _ b: Int) {
            grid.cells.swapAt(a, b)
        }
        func swapCols(_ a: Int, _ b: Int) {
            for r in 0..<9 {
                grid.cells[r].swapAt(a, b)
            }
        }
        
        for band in stride(from: 0, to: 9, by: 3) {
            let a = band + Int(rng.next() % 3)
            let b = band + Int(rng.next() % 3)
            if a != b { swapRows(a, b) }
        }
        for stack in stride(from: 0, to: 9, by: 3) {
            let a = stack + Int(rng.next() % 3)
            let b = stack + Int(rng.next() % 3)
            if a != b { swapCols(a, b) }
        }
        // Shuffle bands using deterministic method
        let bandOrder = deterministicShuffle([0,3,6], using: &rng)
        print("🔢 Band order: \(bandOrder)")
        var newRows = grid.cells
        for (i, bandStart) in bandOrder.enumerated() {
            for offset in 0..<3 { newRows[i*3+offset] = grid.cells[bandStart+offset] }
        }
        grid.cells = newRows
        // Shuffle stacks using deterministic method
        let stackOrder = deterministicShuffle([0,3,6], using: &rng)
        print("🔢 Stack order: \(stackOrder)")
        for r in 0..<9 {
            var newRow = grid.cells[r]
            for (i, stackStart) in stackOrder.enumerated() {
                for offset in 0..<3 { newRow[i*3+offset] = grid.cells[r][stackStart+offset] }
            }
            grid.cells[r] = newRow
        }
    }
    
    private static func removeCells(_ grid: inout SudokuGrid, difficulty: SudokuDifficulty, rng: inout SeededRandomNumberGenerator) {
        let removals: Int
        switch difficulty {
        case .easy: removals = 40
        case .medium: removals = 50
        case .hard: removals = 60
        }
        
        // Create a list of all cell positions that can be removed
        var availableCells: [(Int, Int)] = []
        for r in 0..<9 {
            for c in 0..<9 {
                if grid.cells[r][c].value != 0 {
                    availableCells.append((r, c))
                }
            }
        }
        
        // Shuffle the available cells using the seeded RNG
        availableCells.shuffle(using: &rng)
        
        // Remove the first 'removals' cells
        let cellsToRemove = min(removals, availableCells.count)
        for i in 0..<cellsToRemove {
            let (r, c) = availableCells[i]
            grid.cells[r][c].value = 0
            grid.cells[r][c].isGiven = false
        }
    }
    
    private static func deterministicShuffle<T>(_ array: [T], using rng: inout SeededRandomNumberGenerator) -> [T] {
        var result = array
        for i in stride(from: result.count - 1, to: 0, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            result.swapAt(i, j)
        }
        return result
    }
    
    private static func deterministicHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 5381
        for byte in string.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return hash
    }
}


