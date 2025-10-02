import SwiftUI

struct PastExactoView: View {
    @State private var selectedGame: PastExactoGame?
    @State private var showingDetail = false
    
    var body: some View {
        PastGamesView<PastExactoGame>(
            gameTitle: "Past Exacto",
            gameIcon: "multiply.circle.fill",
            gameColor: .pink,
            onGameSelected: { game in
                selectedGame = game
                showingDetail = true
            }
        )
        .sheet(isPresented: $showingDetail) {
            if let game = selectedGame {
                PastExactoDetailView(game: game)
            }
        }
    }
}

// MARK: - Past Exacto Game Model

struct PastExactoGame: PastGame {
    let date: Date
    let difficulty: any GameDifficulty
    let exactoDifficulty: ExactoDifficulty
    let score: Int?
    let puzzle: ExactoPuzzle
    let target: Int
    let numbers: [Int]
    let completionTime: TimeInterval?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// ExactoDifficulty is defined in Models/GoalModels.swift

// MARK: - Past Exacto Generator

class PastExactoGenerator {
    static func generatePastGames(days: Int = 30) -> [PastExactoGame] {
        var games: [PastExactoGame] = []
        let calendar = Calendar.current
        
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            
            let seed = String(Int(date.timeIntervalSince1970 / 86400)) // Daily seed
            let difficulty = ExactoDifficulty.allCases.randomElement() ?? .easy
            
            // Generate puzzle for this date
            let puzzle = ExactoGenerator.generate(seed: seed, difficulty: difficulty)
            
            // Simulate completion data
            let isCompleted = Bool.random()
            let completionTime = isCompleted ? Double.random(in: 30...300) : nil
            let score = isCompleted ? Int.random(in: 500...2000) : nil
            
            let game = PastExactoGame(
                date: date,
                difficulty: difficulty as any GameDifficulty,
                exactoDifficulty: difficulty,
                score: score,
                puzzle: puzzle,
                target: puzzle.target,
                numbers: puzzle.numbers,
                completionTime: completionTime
            )
            
            games.append(game)
        }
        
        return games.sorted { $0.date > $1.date }
    }
}

// MARK: - Past Exacto View Extension

extension PastGamesView where GameType == PastExactoGame {
    func generateSamplePastGames() -> [PastExactoGame] {
        return PastExactoGenerator.generatePastGames(days: 30)
    }
}
