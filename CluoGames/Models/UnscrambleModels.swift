//
//  UnscrambleModels.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation

// MARK: - Letter State
enum LetterState: String, CaseIterable, Codable {
    case correct = "correct"      // Green - letter in correct position
    case wrongPosition = "wrong"  // Yellow - letter exists but wrong position
    case notInWord = "absent"     // Gray - letter not in word
    case empty = "empty"          // Default state
    
    var color: String {
        switch self {
        case .correct: return "green"
        case .wrongPosition: return "yellow"
        case .notInWord: return "gray"
        case .empty: return "white"
        }
    }
}

// MARK: - Letter
struct UnscrambleLetter: Identifiable, Codable, Hashable {
    let id: UUID
    let character: Character
    var state: LetterState = .empty
    var position: Int = 0
    
    init(_ character: Character, state: LetterState = .empty, position: Int = 0) {
        self.id = UUID()
        self.character = character
        self.state = state
        self.position = position
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case id, characterString, state, position
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        let characterString = try container.decode(String.self, forKey: .characterString)
        self.character = Character(characterString)
        self.state = try container.decode(LetterState.self, forKey: .state)
        self.position = try container.decode(Int.self, forKey: .position)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(String(character), forKey: .characterString)
        try container.encode(state, forKey: .state)
        try container.encode(position, forKey: .position)
    }
}

// MARK: - Guess
struct UnscrambleGuess: Identifiable, Codable {
    let id: UUID
    var letters: [UnscrambleLetter]
    var isComplete: Bool = false
    var isCorrect: Bool = false
    
    init(word: String) {
        self.id = UUID()
        self.letters = word.map { UnscrambleLetter($0) }
        self.isComplete = !word.isEmpty
    }
    
    var word: String {
        return String(letters.map { $0.character })
    }
    
    mutating func addLetter(_ character: Character) {
        if letters.count < 7 && !isComplete {
            letters.append(UnscrambleLetter(character))
        }
    }
    
    mutating func removeLastLetter() {
        if !letters.isEmpty {
            letters.removeLast()
        }
    }
    
    mutating func clear() {
        letters.removeAll()
        isComplete = false
        isCorrect = false
    }
}

// MARK: - Unscramble Game
struct UnscrambleGame: Codable, Identifiable {
    let id: String
    let date: Date
    let word: String
    let scrambledWord: String
    var guesses: [UnscrambleGuess] = []
    var currentGuess: UnscrambleGuess = UnscrambleGuess(word: "")
    var isSolved: Bool = false
    var isGameOver: Bool = false
    var maxGuesses: Int = 6
    
    init(id: String = UUID().uuidString, date: Date = Date(), word: String) {
        self.id = id
        self.date = date
        self.word = word.uppercased()
        self.scrambledWord = UnscrambleGenerator.scrambleWord(word)
    }
    
    var remainingGuesses: Int {
        return maxGuesses - guesses.count
    }
    
    var canMakeGuess: Bool {
        return !isSolved && !isGameOver && currentGuess.isComplete && remainingGuesses > 0
    }
}

// MARK: - Keyboard Layout
struct KeyboardLayout {
    static let qwerty: [[String]] = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M"]
    ]
}

// MARK: - Game State
enum UnscrambleGameState {
    case notStarted
    case inProgress
    case won
    case lost
}

// MARK: - Game Statistics
struct UnscrambleStats: Codable {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageGuesses: Double = 0.0
    var lastPlayDate: Date?
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
}
