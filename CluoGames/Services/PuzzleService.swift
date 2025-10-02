//
//  PuzzleService.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation
import Combine

// MARK: - Puzzle Service Protocol
protocol PuzzleServiceProtocol {
    func getTodaysPuzzle() async throws -> ConnectionsPuzzle
    func getPuzzle(for date: Date) async throws -> ConnectionsPuzzle?
    func markPuzzleAsSolved(_ puzzle: any Puzzle, timeToSolve: TimeInterval, mistakes: Int)
    func canAccessPuzzle(for date: Date) -> Bool
}

// MARK: - Puzzle Service Implementation
class PuzzleService: PuzzleServiceProtocol, ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let solvedPuzzlesKey = "solvedPuzzles"
    private let userProgressKey = "userProgress"
    
    @Published var userProgress: UserGameProgress = UserGameProgress()
    
    init() {
        loadUserProgress()
    }
    
    // MARK: - Public Methods
    
    func getTodaysPuzzle() async throws -> ConnectionsPuzzle {
        return try await getPuzzle(for: Date()) ?? generateDefaultPuzzle()
    }
    
    func getPuzzle(for date: Date) async throws -> ConnectionsPuzzle? {
        // In a real app, this would fetch from a server or local database
        // For now, we'll use bundled JSON data
        return try await loadPuzzleFromBundle(for: date)
    }
    
    func markPuzzleAsSolved(_ puzzle: any Puzzle, timeToSolve: TimeInterval, mistakes: Int) {
        var updatedPuzzle = puzzle
        updatedPuzzle.isSolved = true
        updatedPuzzle.timeToSolve = timeToSolve
        updatedPuzzle.mistakes = mistakes
        
        // Update user progress
        userProgress.solvedPuzzleIds.insert(puzzle.id)
        userProgress.totalPuzzlesSolved += 1
        
        // Update streak
        updateStreak()
        
        // Save progress
        saveUserProgress()
    }
    
    func canAccessPuzzle(for date: Date) -> Bool {
        // All puzzles are accessible
        return true
    }

    
    // MARK: - Private Methods
    
    private func loadPuzzleFromBundle(for date: Date) async throws -> ConnectionsPuzzle? {
        // Load from bundled JSON file
        guard let url = Bundle.main.url(forResource: "connections_puzzles", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        let puzzles = try JSONDecoder().decode([ConnectionsPuzzle].self, from: data)
        let dateString = DateFormatter.puzzleDate.string(from: date)
        
        return puzzles.first { puzzle in
            DateFormatter.puzzleDate.string(from: puzzle.date) == dateString
        }
    }
    
    
    private func generateDefaultPuzzle() -> ConnectionsPuzzle {
        // Fallback puzzle if no data is available
        return ConnectionsPuzzle(
            id: "default-\(Date().timeIntervalSince1970)",
            date: Date(),
            difficulty: .medium,
            words: ["APPLE", "BANANA", "ORANGE", "GRAPE", "CAR", "TRUCK", "BIKE", "BUS", "RED", "BLUE", "GREEN", "YELLOW", "DOG", "CAT", "BIRD", "FISH"],
            groups: [
                ConnectionsPuzzle.WordGroup(
                    id: "fruits",
                    words: ["APPLE", "BANANA", "ORANGE", "GRAPE"],
                    category: "Fruits",
                    difficulty: 1,
                    color: "#FF6B6B"
                ),
                ConnectionsPuzzle.WordGroup(
                    id: "vehicles",
                    words: ["CAR", "TRUCK", "BIKE", "BUS"],
                    category: "Vehicles",
                    difficulty: 2,
                    color: "#4ECDC4"
                ),
                ConnectionsPuzzle.WordGroup(
                    id: "colors",
                    words: ["RED", "BLUE", "GREEN", "YELLOW"],
                    category: "Colors",
                    difficulty: 3,
                    color: "#45B7D1"
                ),
                ConnectionsPuzzle.WordGroup(
                    id: "animals",
                    words: ["DOG", "CAT", "BIRD", "FISH"],
                    category: "Animals",
                    difficulty: 4,
                    color: "#96CEB4"
                )
            ],
            title: "Daily Connections",
            description: "Group the words into 4 categories of 4"
        )
    }
    
    private func updateStreak() {
        let today = Date()
        let calendar = Calendar.current
        
        if let lastPlayDate = userProgress.lastPlayDate {
            let daysDifference = calendar.dateComponents([.day], from: lastPlayDate, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                userProgress.currentStreak += 1
            } else if daysDifference > 1 {
                // Streak broken
                userProgress.currentStreak = 1
            }
            // If daysDifference == 0, it's the same day, don't change streak
        } else {
            // First time playing
            userProgress.currentStreak = 1
        }
        
        userProgress.lastPlayDate = today
        userProgress.longestStreak = max(userProgress.longestStreak, userProgress.currentStreak)
    }
    
    private func loadUserProgress() {
        if let data = userDefaults.data(forKey: userProgressKey),
           let progress = try? JSONDecoder().decode(UserGameProgress.self, from: data) {
            userProgress = progress
        }
    }
    
    private func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            userDefaults.set(data, forKey: userProgressKey)
        }
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let puzzleDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
