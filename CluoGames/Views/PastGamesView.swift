//
//  PastGamesView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI

// MARK: - Universal Past Games List View

enum GameType {
    case sudoku
    case exacto
    case unscramble
}

struct PastGamesListView: View {
    let gameTitle: String
    let gameIcon: String
    let gameColor: Color
    let gameType: GameType
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(generateDailyGames(), id: \.id) { dailyGame in
                        NavigationLink {
                            destinationView(for: dailyGame)
                        } label: {
                            GameHeroCard(
                                title: gameTitle,
                                subtitle: gameSubtitle,
                                dateText: dailyGame.dateString,
                                icon: gameIcon,
                                tint: gameColor,
                                isLocked: false,
                                height: 120
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle(gameTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func generateDailyGames() -> [DailyGame] {
        let calendar = Calendar.current
        let today = Date()
        var games: [DailyGame] = []
        
        // Generate games for the last 365 days (excluding today)
        for i in 1..<366 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Skip future dates
            if date > today { continue }
            
            // Create a game for every day in the last 365 days
            let game = DailyGame(
                id: UUID().uuidString,
                date: date,
                hasEasy: true, // All days have easy
                hasMedium: true, // All days have medium
                hasHard: true // All days have hard
            )
            games.append(game)
        }
        
        return games
    }
    
    // MARK: - Game Type Helpers
    
    private func destinationView(for dailyGame: DailyGame) -> some View {
        switch gameType {
        case .sudoku:
            return AnyView(SudokuGameView(seed: dailyGame.dateString, difficulty: .medium))
        case .exacto:
            return AnyView(ExactoGameView(seed: dailyGame.dateString, difficulty: .medium))
        case .unscramble:
            return AnyView(UnscrambleGameView())
        }
    }
    
    private var gameSubtitle: String {
        switch gameType {
        case .sudoku:
            return "Fill each row & column with digits 1–9 without repeats."
        case .exacto:
            return "Use six numbers and multiplication to match the target"
        case .unscramble:
            return "Unscramble today's word in 6 tries. Quick, clever, one puzzle a day."
        }
    }
}

// MARK: - Daily Game Model

struct DailyGame: Identifiable {
    let id: String
    let date: Date
    let hasEasy: Bool
    let hasMedium: Bool
    let hasHard: Bool
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - Individual Past Game Views

struct PastSudokuView: View {
    var body: some View {
        PastGamesListView(
            gameTitle: "Past Sudoku",
            gameIcon: "square.grid.3x3.fill",
            gameColor: .yellow,
            gameType: .sudoku
        )
    }
}

struct PastExactoView: View {
    var body: some View {
        PastGamesListView(
            gameTitle: "Past Exacto",
            gameIcon: "equal.circle.fill",
            gameColor: .pink,
            gameType: .exacto
        )
    }
}

struct PastUnscrambleView: View {
    var body: some View {
        PastGamesListView(
            gameTitle: "Past Unscramble",
            gameIcon: "questionmark.circle.fill",
            gameColor: .blue,
            gameType: .unscramble
        )
    }
}

#Preview {
    PastSudokuView()
}
