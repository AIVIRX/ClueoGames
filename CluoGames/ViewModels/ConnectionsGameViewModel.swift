//
//  ConnectionsGameViewModel.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation
import Combine

class ConnectionsGameViewModel: ObservableObject {
    @Published var puzzle: ConnectionsPuzzle
    @Published var selectedWords: Set<String> = []
    @Published var gameState: GameState = .notStarted
    @Published var mistakes: Int = 0
    @Published var startTime: Date?
    @Published var completedGroups: Set<String> = []
    @Published var showingResult = false
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var isAnimating = false
    
    private let puzzleService: PuzzleServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        puzzle: ConnectionsPuzzle,
        puzzleService: PuzzleServiceProtocol = PuzzleService(),
    ) {
        self.puzzle = puzzle
        self.puzzleService = puzzleService
        
        startGame()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func selectWord(_ word: String) {
        guard gameState == .inProgress else { return }
        guard !completedGroups.contains(where: { group in
            puzzle.groups.first { $0.id == group }?.words.contains(word) == true
        }) else { return }
        
        if selectedWords.contains(word) {
            selectedWords.remove(word)
        } else if selectedWords.count < 4 {
            selectedWords.insert(word)
            
            // Check if we have 4 words selected
            if selectedWords.count == 4 {
                checkGroup()
            }
        }
    }
    
    @MainActor
    func deselectAll() {
        selectedWords.removeAll()
    }
    
    @MainActor
    func startGame() {
        gameState = .inProgress
        startTime = Date()
        selectedWords.removeAll()
        completedGroups.removeAll()
        mistakes = 0
    }
    
    @MainActor
    func resetGame() {
        startGame()
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func checkGroup() {
        guard selectedWords.count == 4 else { return }
        
        // Find matching group
        if let matchingGroup = puzzle.groups.first(where: { group in
            Set(group.words) == selectedWords
        }) {
            // Correct group found
            completeGroup(matchingGroup)
        } else {
            // Wrong group
            handleWrongGroup()
        }
    }
    
    @MainActor
    private func completeGroup(_ group: ConnectionsPuzzle.WordGroup) {
        completedGroups.insert(group.id)
        selectedWords.removeAll()
        
        // Check if all groups are completed
        if completedGroups.count == puzzle.groups.count {
            completeGame()
        }
        
        // Animate success
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    @MainActor
    private func handleWrongGroup() {
        mistakes += 1
        selectedWords.removeAll()
        
        // Show error animation
        showingError = true
        errorMessage = "Not quite! Try again."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showingError = false
        }
        
        // Check if too many mistakes (optional game over condition)
        if mistakes >= 4 {
        }
    }
    
    @MainActor
    private func completeGame() {
        guard let startTime = startTime else { return }
        
        let timeToSolve = Date().timeIntervalSince(startTime)
        let endTime = Date()
        gameState = .completed
        
        // Update puzzle with results
        puzzle.isSolved = true
        puzzle.timeToSolve = timeToSolve
        puzzle.mistakes = mistakes
        
        // Save to service
        puzzleService.markPuzzleAsSolved(puzzle, timeToSolve: timeToSolve, mistakes: mistakes)
        
                
        // Show result screen
        showingResult = true
    }
}

// MARK: - Computed Properties
extension ConnectionsGameViewModel {
    
    var availableWords: [String] {
        return puzzle.words.filter { word in
            !completedGroups.contains { groupId in
                puzzle.groups.first { $0.id == groupId }?.words.contains(word) == true
            }
        }
    }
    
    var completedWords: [String] {
        return completedGroups.flatMap { groupId in
            puzzle.groups.first { $0.id == groupId }?.words ?? []
        }
    }
    
    var progressPercentage: Double {
        return Double(completedGroups.count) / Double(puzzle.groups.count)
    }
    
    var timeElapsed: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    var formattedTime: String {
        let time = gameState == .completed ? (puzzle.timeToSolve ?? 0) : timeElapsed
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var canSubmit: Bool {
        return selectedWords.count == 4 && gameState == .inProgress
    }
    
    var isWordSelected: (String) -> Bool {
        return { word in
            self.selectedWords.contains(word)
        }
    }
    
    var isWordCompleted: (String) -> Bool {
        return { word in
            self.completedWords.contains(word)
        }
    }
    
    var getGroupForWord: (String) -> ConnectionsPuzzle.WordGroup? {
        return { word in
            self.puzzle.groups.first { group in
                group.words.contains(word) && self.completedGroups.contains(group.id)
            }
        }
    }
}
