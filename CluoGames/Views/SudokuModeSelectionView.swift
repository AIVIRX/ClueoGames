//
//  SudokuModeSelectionView.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import SwiftUI

struct SudokuModeSelectionView: View {
    @State private var completedDifficulties: Set<SudokuDifficulty> = []
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Sudoku icon
            VStack(spacing: 20) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .outline(.black, lineWidth: 1.5)
                
                Text("Sudoku")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Text("Fill each row & column with digits 1–9 without repeats.")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 20) {
                Text("Pick a Difficulty.")
                    .font(.headline)
                    .foregroundStyle(.black)

                VStack(spacing: 12) {
                    DifficultyButton(
                        title: "Easy",
                        difficulty: .easy,
                        isCompleted: completedDifficulties.contains(.easy),
                        isDisabled: completedDifficulties.contains(.easy),
                        onComplete: { markCompleted(difficulty: .easy) }
                    )
                    
                    DifficultyButton(
                        title: "Medium",
                        difficulty: .medium,
                        isCompleted: completedDifficulties.contains(.medium),
                        isDisabled: completedDifficulties.contains(.medium),
                        onComplete: { markCompleted(difficulty: .medium) }
                    )
                    
                    DifficultyButton(
                        title: "Hard",
                        difficulty: .hard,
                        isCompleted: completedDifficulties.contains(.hard),
                        isDisabled: completedDifficulties.contains(.hard),
                        onComplete: { markCompleted(difficulty: .hard) }
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
        .ignoresSafeArea()
        .onAppear {
            loadCompletedDifficulties()
        }
    }
    
    private func generateSeed(for difficulty: SudokuDifficulty) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(difficulty.rawValue)-\(formatter.string(from: Date()))"
    }
    
    private func startGame(difficulty: SudokuDifficulty) {
        // Navigate to game
        // This will be handled by NavigationLink in the button
    }
    
    private func loadCompletedDifficulties() {
        let today = getTodayString()
        let key = "sudoku_completed_\(today)"
        if let data = UserDefaults.standard.data(forKey: key),
           let completed = try? JSONDecoder().decode(Set<SudokuDifficulty>.self, from: data) {
            completedDifficulties = completed
        }
    }
    
    private func markCompleted(difficulty: SudokuDifficulty) {
        completedDifficulties.insert(difficulty)
        let today = getTodayString()
        let key = "sudoku_completed_\(today)"
        if let data = try? JSONEncoder().encode(completedDifficulties) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct DifficultyButton: View {
    let title: String
    let difficulty: SudokuDifficulty
    let isCompleted: Bool
    let isDisabled: Bool
    let onComplete: () -> Void
    
    var body: some View {
        NavigationLink {
            SudokuGameView(seed: generateSeed(for: difficulty), difficulty: difficulty, onComplete: onComplete)
        } label: {
            HStack {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isDisabled {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(isCompleted ? .bold : .regular)
                    .foregroundColor(isCompleted ? .green : (isDisabled ? .gray : .primary))
                
                if isCompleted {
                    Text("Completed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isCompleted ? Color.green.opacity(0.2) : (isDisabled ? Color.gray.opacity(0.1) : Color(.systemBackground)))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
    
    private func generateSeed(for difficulty: SudokuDifficulty) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(difficulty.rawValue)-\(formatter.string(from: Date()))"
    }
}
