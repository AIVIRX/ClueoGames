//
//  UnscrambleGameView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI

struct UnscrambleGameView: View {
    @StateObject private var viewModel: UnscrambleViewModel
    @Environment(\.dismiss) private var dismiss
    private let seed: String?
    
    init(game: UnscrambleGame? = nil, seed: String? = nil) {
        self.seed = seed
        if let game = game {
            _viewModel = StateObject(wrappedValue: UnscrambleViewModel(game: game))
        } else if let seed = seed {
            let generated = UnscrambleGenerator.generateGame(seed: seed)
            _viewModel = StateObject(wrappedValue: UnscrambleViewModel(game: generated))
        } else {
            _viewModel = StateObject(wrappedValue: UnscrambleViewModel(game: nil))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                header
                gameBoard
                customKeyboard
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Unscramble")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Reveal word") {
                            viewModel.revealWord()
                        }
                    } label: {
                        Image(systemName: "questionmark")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .disabled(viewModel.isGameOver)
                }
            }
            .alert("Invalid Word", isPresented: $viewModel.showInvalidWord) {
                Button("OK") { }
            } message: {
                Text("That's not a valid word. Try again!")
            }
            .sheet(isPresented: $viewModel.showResult) {
                UnscrambleResultView(
                    isWon: viewModel.isGameWon,
                    targetWord: viewModel.targetWord,
                    guesses: viewModel.game.guesses,
                    onDismiss: { 
                        if viewModel.isGameWon {
                            CompletionService.shared.markCompleted(gameType: .unscramble, date: viewModel.game.date)
                        }
                        dismiss()
                    }
                )
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 12) {
            Text("Unscramble the word")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(viewModel.scrambledWord)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            
            HStack {
                Text("Guesses left: \(viewModel.remainingGuesses)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Length: \(viewModel.targetWord.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Game Board
    private var gameBoard: some View {
        VStack(spacing: 8) {
            // Previous guesses
            ForEach(viewModel.game.guesses) { guess in
                GuessRow(guess: guess, targetLength: viewModel.targetWord.count)
            }
            
            // Current guess
            if !viewModel.isGameOver {
                CurrentGuessRow(
                    guess: viewModel.game.currentGuess,
                    targetLength: viewModel.targetWord.count
                )
            }
            
            // Empty rows for remaining guesses
            ForEach(0..<viewModel.remainingGuesses, id: \.self) { _ in
                EmptyGuessRow(targetLength: viewModel.targetWord.count)
            }
        }
    }
    
    // MARK: - Custom Keyboard
    
    private var customKeyboard: some View {
        VStack(spacing: 8) {
            ForEach(Array(KeyboardLayout.qwerty.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 6) {
                    if rowIndex == 2 {
                        // Backspace button
                        KeyboardButton(
                            text: "⌫",
                            action: { viewModel.removeLastLetter() },
                            isEnabled: !viewModel.game.currentGuess.letters.isEmpty,
                            backgroundColor: .gray.opacity(0.2)
                        )
                        .frame(width: 60)
                    }
                    
                    ForEach(row, id: \.self) { letter in
                        KeyboardButton(
                            text: letter,
                            action: { viewModel.addLetter(Character(letter)) },
                            isEnabled: viewModel.gameState == .inProgress && !viewModel.isGameOver,
                            backgroundColor: keyboardColor(for: letter)
                        )
                    }
                    
                    if rowIndex == 2 {
                        // Submit button
                        KeyboardButton(
                            text: "ENTER",
                            action: { viewModel.submitGuess() },
                            isEnabled: viewModel.canSubmitGuess,
                            backgroundColor: viewModel.canSubmitGuess ? .blue : .gray.opacity(0.2)
                        )
                        .frame(width: 60)
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func keyboardColor(for letter: String) -> Color {
        guard let state = viewModel.keyboardStates[letter] else {
            return Color(.systemGray5)
        }
        
        switch state {
        case .correct:
            return .green
        case .wrongPosition:
            return .yellow
        case .notInWord:
            return .gray
        case .empty:
            return Color(.systemGray5)
        }
    }
}

// MARK: - Supporting Views

struct GuessRow: View {
    let guess: UnscrambleGuess
    let targetLength: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<targetLength, id: \.self) { index in
                if index < guess.letters.count {
                    let letter = guess.letters[index]
                    LetterBox(
                        letter: letter.character,
                        state: letter.state,
                        isAnimating: false
                    )
                } else {
                    LetterBox(letter: " ", state: .empty, isAnimating: false)
                }
            }
        }
    }
}

struct CurrentGuessRow: View {
    let guess: UnscrambleGuess
    let targetLength: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<targetLength, id: \.self) { index in
                if index < guess.letters.count {
                    LetterBox(
                        letter: guess.letters[index].character,
                        state: .empty,
                        isAnimating: true
                    )
                } else {
                    LetterBox(letter: " ", state: .empty, isAnimating: false)
                }
            }
        }
    }
}

struct EmptyGuessRow: View {
    let targetLength: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { _ in
                LetterBox(letter: " ", state: .empty, isAnimating: false)
            }
        }
    }
}

struct LetterBox: View {
    let letter: Character
    let state: LetterState
    let isAnimating: Bool
    
    var body: some View {
        Text(String(letter))
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(letter == " " ? .clear : .primary)
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isAnimating)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .correct:
            return .green
        case .wrongPosition:
            return .yellow
        case .notInWord:
            return .gray
        case .empty:
            return letter == " " ? .clear : Color(.systemGray6)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .correct, .wrongPosition, .notInWord:
            return .clear
        case .empty:
            return letter == " " ? .clear : Color(.separator)
        }
    }
}

struct KeyboardButton: View {
    let text: String
    let action: () -> Void
    let isEnabled: Bool
    let backgroundColor: Color
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isEnabled ? .primary : .secondary)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .disabled(!isEnabled)
    }
}

struct UnscrambleResultView: View {
    let isWon: Bool
    let targetWord: String
    let guesses: [UnscrambleGuess]
    let onDismiss: () -> Void
    
    var body: some View {
        GameCompletionView(
            gameType: "Unscramble",
            isWon: isWon,
            primaryInfo: isWon ? "Word Solved!" : "Game Over",
            secondaryInfo: "The word was: \(targetWord)",
            additionalChips: [
                CompletionChip(title: "Guesses", value: "\(guesses.count)", icon: "number"),
                CompletionChip(title: "Length", value: "\(targetWord.count)", icon: "textformat.size")
            ],
            onDone: { onDismiss() },
            onBackToList: { onDismiss() }
        )
    }
}

#Preview {
    UnscrambleGameView()
}
