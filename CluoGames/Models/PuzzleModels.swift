//
//  PuzzleModels.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation

// MARK: - Base Puzzle Protocol
protocol Puzzle: Codable, Identifiable {
    var id: String { get }
    var date: Date { get }
    var difficulty: PuzzleDifficulty { get }
    var isSolved: Bool { get set }
    var timeToSolve: TimeInterval? { get set }
    var mistakes: Int { get set }
}

// MARK: - Puzzle Difficulty
enum PuzzleDifficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}


// MARK: - Connections Puzzle
struct ConnectionsPuzzle: Puzzle {
    let id: String
    let date: Date
    let difficulty: PuzzleDifficulty
    var isSolved: Bool = false
    var timeToSolve: TimeInterval?
    var mistakes: Int = 0
    
    let words: [String]
    let groups: [WordGroup]
    let title: String
    let description: String
    
    struct WordGroup: Codable, Identifiable {
        let id: String
        let words: [String]
        let category: String
        let difficulty: Int // 1-4, where 4 is hardest
        let color: String // Hex color for UI
        
        enum CodingKeys: String, CodingKey {
            case id, words, category, difficulty, color
        }
    }
}

// Crossword puzzle models removed - placeholder only

// MARK: - Game State
enum GameState {
    case notStarted
    case inProgress
    case completed
    case failed
}

// MARK: - User Progress
struct UserGameProgress: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalPuzzlesSolved: Int = 0
    var solvedPuzzleIds: Set<String> = []
    var lastPlayDate: Date?
}

// MARK: - Puzzle Result
struct GameResult: Codable {
    let puzzleId: String
    let puzzleType: PuzzleType
    let date: Date
    let timeToSolve: TimeInterval
    let mistakes: Int
    let isPerfect: Bool
    let streak: Int
    
    enum PuzzleType: String, Codable {
        case connections = "connections"
        case crossword = "crossword"
    }
}

// MARK: - Share Result
struct ShareResult {
    let puzzleType: GameResult.PuzzleType
    let timeToSolve: TimeInterval
    let mistakes: Int
    let isPerfect: Bool
    let streak: Int
    let date: Date
    
    var shareText: String {
        let emoji = isPerfect ? "🎉" : "✅"
        let timeString = formatTime(timeToSolve)
        let mistakeString = mistakes == 0 ? "Perfect!" : "\(mistakes) mistake\(mistakes == 1 ? "" : "s")"
        
        return """
        \(emoji) Clueo Games - \(puzzleType.displayName)
        Solved in \(timeString) with \(mistakeString)
        Streak: \(streak) 🔥
        """
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension GameResult.PuzzleType {
    var displayName: String {
        switch self {
        case .connections: return "Connections"
        case .crossword: return "Crossword"
        }
    }
}
