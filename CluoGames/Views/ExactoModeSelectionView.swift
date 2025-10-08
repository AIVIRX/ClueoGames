//
//  ExactoModeSelectionView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI

struct ExactoModeSelectionView: View {
    @State private var completed: Set<ExactoDifficulty> = []
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "equal")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .outline(.black, lineWidth: 1.5)
            Text("Exacto")
                .font(.largeTitle).bold()
                .foregroundStyle(.black)
            Text("Use six numbers and basic math to hit the target.")
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            VStack(spacing: 12) {
                modeButton("Easy", .easy)
                modeButton("Medium", .medium)
                modeButton("Hard", .hard)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pink)
        .ignoresSafeArea()
        .onAppear { loadCompletion() }
    }
    
    private func modeButton(_ title: String, _ difficulty: ExactoDifficulty) -> some View {
        let isDone = completed.contains(difficulty)
        return NavigationLink {
            ExactoGameView(seed: ExactoGenerator.dailySeed(), difficulty: difficulty) {
                loadCompletion()
            }
        } label: {
            HStack {
                if isDone {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
                Text(title).font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isDone ? Color.green.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(isDone)
    }
    
    private func loadCompletion() {
        let key = "exacto_completed_\(ExactoGenerator.dailySeed())"
        if let data = UserDefaults.standard.data(forKey: key),
           let set = try? JSONDecoder().decode(Set<ExactoDifficulty>.self, from: data) {
            completed = set
        } else {
            completed = []
        }
    }
}
