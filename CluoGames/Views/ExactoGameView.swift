//
//  ExactoGameView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI

struct ExactoGameView: View {
    @Environment(\.dismiss) private var dismiss
    private let seed: String
    private let difficulty: ExactoDifficulty
    @StateObject private var viewModel: ExactoViewModel
    
    private enum Stage { case pickFirstNumber, pickSecondNumber }
    
    private let onComplete: (() -> Void)?
    @State private var showCompletion: Bool = false

    init(seed: String? = nil, difficulty: ExactoDifficulty = .medium, onComplete: (() -> Void)? = nil) {
        let seedToUse = seed ?? ExactoGenerator.dailySeed()
        self.seed = seedToUse
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: ExactoViewModel(seed: seedToUse, difficulty: difficulty))
    }
    
    init(puzzle: ExactoPuzzle, difficulty: ExactoDifficulty, onComplete: (() -> Void)? = nil) {
        self.seed = ""
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: ExactoViewModel(puzzle: puzzle))
    }
    @State private var selectedLeftIndex: Int? = nil
    @State private var selectedRightIndex: Int? = nil
    @State private var stage: Stage = .pickFirstNumber
    
    var body: some View {
        VStack(spacing: 16) {
            header
            workArea
            numbersGrid
            solvedBanner
        }
        .padding()
        .navigationTitle("Exacto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    viewModel.reset()
                    selectedLeftIndex = nil
                    selectedRightIndex = nil
                    stage = .pickFirstNumber
                }
            }
        }
        .onChange(of: viewModel.isSolved) { _, solved in
            if solved {
                CompletionService.shared.markCompleted(gameType: .exacto, date: completionDate())
                markDifficultyCompleted()
                showCompletion = true
                onComplete?()
            }
        }
        .sheet(isPresented: $showCompletion) {
            completionSheet
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("Target")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(viewModel.puzzle.target)")
                .font(.system(size: 44, weight: .heavy))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private var numbersGrid: some View {
        let cols = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(Array(viewModel.availableNumbers.enumerated()), id: \.offset) { idx, n in
                Button(action: { handleNumberTap(idx) }) {
                    Text("\(n)")
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(selectionColor(forIndex: idx))
                        .cornerRadius(12)
                }
                .disabled(viewModel.isSolved || !isNumberEnabled(idx))
            }
        }
    }
    
    private func selectionColor(forIndex idx: Int) -> Color {
        if selectedLeftIndex == idx || selectedRightIndex == idx { return Color.yellow.opacity(0.5) }
        return Color(.systemGray6)
    }
    
    private func isNumberEnabled(_ idx: Int) -> Bool {
        switch stage {
        case .pickFirstNumber:
            return true
        case .pickSecondNumber:
            return idx != selectedLeftIndex
        }
    }
    
    private func handleNumberTap(_ idx: Int) {
        switch stage {
        case .pickFirstNumber:
            selectedLeftIndex = idx
            selectedRightIndex = nil
            stage = .pickSecondNumber
        case .pickSecondNumber:
            if idx == selectedLeftIndex { return }
            selectedRightIndex = idx
            performWithCurrentSelectionIfReady()
        }
    }
    
    private func performWithCurrentSelectionIfReady() {
        guard let leftIdx = selectedLeftIndex, let rightIdx = selectedRightIndex, leftIdx != rightIdx else { return }
        let a = viewModel.availableNumbers[leftIdx]
        let b = viewModel.availableNumbers[rightIdx]
        let wasSolvedBefore = viewModel.isSolved
        let _ = viewModel.attempt(.multiply, left: a, right: b)
        if viewModel.isSolved {
            // keep selection shown
        } else {
            if !wasSolvedBefore {
                HapticsManager.shared.trigger(.error)
            }
            selectedLeftIndex = nil
            selectedRightIndex = nil
            stage = .pickFirstNumber
        }
    }
    
    private var solvedBanner: some View {
        Group {
            if viewModel.isSolved {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("Exact! You hit the target.")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.green.opacity(0.15))
                .cornerRadius(12)
            }
        }
    }

    private var workArea: some View {
        VStack(spacing: 8) {
            Text("Your attempt")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                if let leftIdx = selectedLeftIndex {
                    let a = viewModel.availableNumbers.indices.contains(leftIdx) ? viewModel.availableNumbers[leftIdx] : nil
                    outlinedTile(text: a.map { String($0) } ?? "?")
                } else {
                    outlinedTile(text: "?")
                }
                outlinedTile(text: "×")
                if let rightIdx = selectedRightIndex {
                    let b = viewModel.availableNumbers.indices.contains(rightIdx) ? viewModel.availableNumbers[rightIdx] : nil
                    outlinedTile(text: b.map { String($0) } ?? "?")
                } else {
                    outlinedTile(text: "?")
                }
                Image(systemName: "arrow.right").foregroundColor(.secondary)
                outlinedTile(text: String(viewModel.puzzle.target))
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 2)
        .opacity(selectedLeftIndex == nil && selectedRightIndex == nil ? 0.8 : 1)
        .animation(.easeInOut(duration: 0.25), value: selectedLeftIndex)
        .animation(.easeInOut(duration: 0.25), value: selectedRightIndex)
    }

    private func outlinedTile(text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.primary)
            .frame(minWidth: 52, minHeight: 44)
            .padding(.horizontal, 4)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.separator).opacity(0.35), lineWidth: 1.5)
            )
            .cornerRadius(10)
    }

    // MARK: - Completion & Persistence
    private func completionDate() -> Date {
        // Past views pass a seed like "MMM d, yyyy". Try to parse that first.
        let pretty = DateFormatter()
        pretty.dateFormat = "MMM d, yyyy"
        if let d = pretty.date(from: seed) { return d }
        
        // Fallback: try ISO format
        let iso = DateFormatter()
        iso.dateFormat = "yyyy-MM-dd"
        if let d = iso.date(from: seed) { return d }
        
        // Last resort: today
        return Date()
    }

    private func markDifficultyCompleted() {
        let key = "exacto_completed_\(ExactoGenerator.dailySeed())"
        var set: Set<ExactoDifficulty> = []
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Set<ExactoDifficulty>.self, from: data) {
            set = decoded
        }
        set.insert(difficulty)
        if let data = try? JSONEncoder().encode(set) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private var completionSheet: some View {
        GameCompletionView(
            gameType: "Exacto",
            isWon: true,
            primaryInfo: "Target Hit!",
            secondaryInfo: "Target: \(viewModel.puzzle.target)",
            additionalChips: [
                CompletionChip(title: "Target", value: "\(viewModel.puzzle.target)", icon: "target"),
                CompletionChip(title: "Difficulty", value: difficulty.rawValue.capitalized, icon: "bolt.fill")
            ],
            onDone: { showCompletion = false },
            onBackToList: { dismiss() }
        )
    }
}
