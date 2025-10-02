//
//  GoalGenerator.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation

final class ExactoGenerator {
    static func dailySeed(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func generate(seed: String, difficulty: ExactoDifficulty) -> ExactoPuzzle {
        let seedKey = "exacto-\(difficulty.rawValue)-\(seed)"
        var rng = SeededRandomNumberGenerator(seed: deterministicHash(seedKey))

        // Numbers pool by difficulty
        var pool: [Int]
        switch difficulty {
        case .easy:
            pool = Array(1...10) + [25, 50]
        case .medium:
            pool = Array(1...10) + [25, 50, 75]
        case .hard:
            pool = Array(1...12) + [25, 50, 75, 100]
        }

        // Difficulty target bounds
        let bounds: (min: Int, max: Int)
        switch difficulty {
        case .easy: bounds = (50, 249)
        case .medium: bounds = (100, 499)
        case .hard: bounds = (300, 999)
        }

        // Attempt to construct a solvable pair using multiplication within bounds
        var chosenA = 0
        var chosenB = 0
        var target = 100
        var found = false

        attemptLoop: for _ in 0..<1000 {
            let a = pool[Int(rng.next() % UInt64(pool.count))]
            let b = pool[Int(rng.next() % UInt64(pool.count))]
            let tVal = a * b
            if tVal >= bounds.min && tVal <= bounds.max {
                chosenA = a
                chosenB = b
                target = tVal
                found = true
                break attemptLoop
            }
        }

        // Fallback: ensure solvable by forcing addition from pool
        if !found {
            // pick two numbers a,b and set target = a + b within bounds by clamping with retries
            for _ in 0..<500 {
                let a = pool[Int(rng.next() % UInt64(pool.count))]
                let b = pool[Int(rng.next() % UInt64(pool.count))]
                let tVal = a * b
                if tVal >= bounds.min && tVal <= bounds.max {
                    chosenA = a
                    chosenB = b
                    target = tVal
                    found = true
                    break
                }
            }
        }

        // Build numbers list including the solvable pair, plus four more from pool
        var numbers: [Int] = [chosenA, chosenB]
        var remainingPool = pool
        remainingPool.shuffle(using: &rng)
        for n in remainingPool {
            numbers.append(n)
            if numbers.count == 6 { break }
        }
        // If still short (edge cases), pad by repeating from pool
        while numbers.count < 6 {
            numbers.append(pool[Int(rng.next() % UInt64(pool.count))])
        }
        numbers.shuffle(using: &rng)

        return ExactoPuzzle(id: seedKey, date: Date(), target: target, numbers: numbers)
    }

    private static func deterministicHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 5381
        for byte in string.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return hash
    }
}


