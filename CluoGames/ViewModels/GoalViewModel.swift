//
//  GoalViewModel.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation
import Combine

final class ExactoViewModel: ObservableObject {
    @Published private(set) var puzzle: ExactoPuzzle
    @Published private(set) var availableNumbers: [Int]
    @Published var isSolved: Bool = false
    private let seed: String
    private let difficulty: ExactoDifficulty
    
    init(seed: String? = nil, difficulty: ExactoDifficulty = .medium, date: Date = Date()) {
        let seedToUse = seed ?? ExactoGenerator.dailySeed(date: date)
        self.seed = seedToUse
        self.difficulty = difficulty
        let puzzle = ExactoGenerator.generate(seed: seedToUse, difficulty: difficulty)
        self.puzzle = puzzle
        self.availableNumbers = puzzle.numbers
    }
    
    init(puzzle: ExactoPuzzle) {
        self.seed = ""
        self.difficulty = .medium // Default for past games
        self.puzzle = puzzle
        self.availableNumbers = puzzle.numbers
    }
    
    func reset() {
        availableNumbers = puzzle.numbers
        isSolved = false
    }
    
    // Returns true if the attempt matches the target exactly
    @discardableResult
    func attempt(_ op: ExactoOperation, left: Int, right: Int) -> Bool {
        guard left != right,
              availableNumbers.contains(left),
              availableNumbers.contains(right) else { return false }
        let result = compute(op, left, right)
        let success = result == puzzle.target
        if success { 
            isSolved = true
        }
        return success
    }
    
    
    // Find a solvable pair (multiplication only) among current numbers
    func findSolution() -> (leftIndex: Int, rightIndex: Int, op: ExactoOperation)? {
        let nums = availableNumbers
        for i in nums.indices {
            for j in nums.indices where j != i {
                let a = nums[i]
                let b = nums[j]
                if a * b == puzzle.target { return (i, j, .multiply) }
            }
        }
        return nil
    }
    
    func compute(_ op: ExactoOperation, _ a: Int, _ b: Int) -> Int {
        switch op {
        case .multiply: return a * b
        }
    }
    
    // Optional helpers could go here if needed later (scoring, etc.)
}


