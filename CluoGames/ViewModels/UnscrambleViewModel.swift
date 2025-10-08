//
//  UnscrambleViewModel.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation
import Combine

final class UnscrambleViewModel: ObservableObject {
    @Published private(set) var game: UnscrambleGame
    @Published private(set) var gameState: UnscrambleGameState = .notStarted
    @Published private(set) var keyboardStates: [String: LetterState] = [:]
    @Published var showResult = false
    @Published var showInvalidWord = false
    
    private let maxGuesses = 6
    
    init(game: UnscrambleGame? = nil) {
        if let game = game {
            self.game = game
        } else {
            self.game = UnscrambleGenerator.generateDailyGame()
        }
        // Start the game immediately
        self.gameState = .inProgress
    }
    
    // MARK: - Game Actions
    
    func startGame() {
        gameState = .inProgress
    }
    
    func addLetter(_ character: Character) {
        guard gameState == .inProgress else { return }
        guard game.currentGuess.letters.count < game.word.count else { return }
        
        game.currentGuess.addLetter(character)
        game.currentGuess.isComplete = game.currentGuess.letters.count == game.word.count
        objectWillChange.send()
    }
    
    func removeLastLetter() {
        guard gameState == .inProgress else { return }
        guard !game.currentGuess.letters.isEmpty else { return }
        
        game.currentGuess.removeLastLetter()
        game.currentGuess.isComplete = game.currentGuess.letters.count == game.word.count
        objectWillChange.send()
    }
    
    func submitGuess() {
        guard gameState == .inProgress else { return }
        guard game.currentGuess.isComplete else { return }
        guard game.remainingGuesses > 0 else { return }
        
        let guessWord = game.currentGuess.word
        
        // Check if it's the correct word
        if guessWord.lowercased() == game.word.lowercased() {
            handleCorrectGuess()
        } else {
            handleIncorrectGuess()
        }
    }
    
    func resetGame() {
        game = UnscrambleGenerator.generateDailyGame()
        gameState = .notStarted
        keyboardStates.removeAll()
        showResult = false
        showInvalidWord = false
    }
    
    func revealWord() {
        // Treat reveal as a correct completion
        // Populate a final guess equal to the target word for consistent UI
        let revealedGuess = UnscrambleGuess(word: game.word)
        let analyzed = analyzeGuess(revealedGuess)
        game.guesses.append(analyzed)
        updateKeyboardStates(for: analyzed)
        game.isSolved = true
        game.isGameOver = true
        gameState = .won
        showResult = true
    }
    
    // MARK: - Private Methods
    
    private func handleCorrectGuess() {
        // Analyze the guess to color the letters properly
        var analyzedGuess = analyzeGuess(game.currentGuess)
        analyzedGuess.isCorrect = true
        game.guesses.append(analyzedGuess)
        game.isSolved = true
        game.isGameOver = true
        gameState = .won
        showResult = true
        
        // Update keyboard states for final guess
        updateKeyboardStates(for: analyzedGuess)
    }
    
    private func handleIncorrectGuess() {
        // Check if word is valid (basic validation)
        guard UnscrambleGenerator.isValidWord(game.currentGuess.word) else {
            showInvalidWord = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showInvalidWord = false
            }
            return
        }
        
        // Analyze the guess and update letter states
        let analyzedGuess = analyzeGuess(game.currentGuess)
        game.guesses.append(analyzedGuess)
        
        // Update keyboard states
        updateKeyboardStates(for: analyzedGuess)
        
        // Check if game is over
        if game.remainingGuesses <= 0 {
            game.isGameOver = true
            gameState = .lost
            showResult = true
        } else {
            // Start new guess
            game.currentGuess = UnscrambleGuess(word: "")
        }
    }
    
    private func analyzeGuess(_ guess: UnscrambleGuess) -> UnscrambleGuess {
        var analyzedGuess = guess
        let guessWord = guess.word.lowercased()
        let targetWord = game.word.lowercased()
        
        // Create arrays to track which letters have been used
        var targetUsed = Array(repeating: false, count: targetWord.count)
        var guessUsed = Array(repeating: false, count: guessWord.count)
        
        // First pass: mark correct positions (green)
        for i in 0..<min(guessWord.count, targetWord.count) {
            if guessWord[guessWord.index(guessWord.startIndex, offsetBy: i)] == 
               targetWord[targetWord.index(targetWord.startIndex, offsetBy: i)] {
                analyzedGuess.letters[i].state = .correct
                analyzedGuess.letters[i].position = i
                targetUsed[i] = true
                guessUsed[i] = true
            }
        }
        
        // Second pass: mark wrong positions (yellow)
        for i in 0..<guessWord.count {
            if guessUsed[i] { continue } // Skip already marked letters
            
            let guessChar = guessWord[guessWord.index(guessWord.startIndex, offsetBy: i)]
            
            for j in 0..<targetWord.count {
                if targetUsed[j] { continue } // Skip already used target letters
                
                let targetChar = targetWord[targetWord.index(targetWord.startIndex, offsetBy: j)]
                
                if guessChar == targetChar {
                    analyzedGuess.letters[i].state = .wrongPosition
                    analyzedGuess.letters[i].position = j
                    targetUsed[j] = true
                    guessUsed[i] = true
                    break
                }
            }
        }
        
        // Third pass: mark absent letters (gray)
        for i in 0..<guessWord.count {
            if !guessUsed[i] {
                analyzedGuess.letters[i].state = .notInWord
            }
        }
        
        return analyzedGuess
    }
    
    private func updateKeyboardStates(for guess: UnscrambleGuess) {
        for letter in guess.letters {
            let key = String(letter.character)
            
            // Only update if current state is better (correct > wrong position > not in word)
            let currentState = keyboardStates[key] ?? .empty
            let newState = letter.state
            
            let shouldUpdate = currentState == .empty || 
                              (currentState == .notInWord && newState != .notInWord) ||
                              (currentState == .wrongPosition && newState == .correct)
            
            if shouldUpdate {
                keyboardStates[key] = newState
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var canSubmitGuess: Bool {
        return gameState == .inProgress &&
               game.currentGuess.isComplete &&
               game.remainingGuesses > 0 &&
               !game.isSolved
    }
    
    var currentGuessWord: String {
        return game.currentGuess.word
    }
    
    var scrambledWord: String {
        return game.scrambledWord
    }
    
    var targetWord: String {
        return game.word
    }
    
    var remainingGuesses: Int {
        return game.remainingGuesses
    }
    
    var isGameWon: Bool {
        return gameState == .won
    }
    
    var isGameLost: Bool {
        return gameState == .lost
    }
    
    var isGameOver: Bool {
        return game.isGameOver
    }
}
