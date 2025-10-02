import SwiftUI

struct PastSudokuView: View {
    @State private var selectedGame: PastSudokuGame?
    @State private var showingDetail = false
    
    var body: some View {
        PastGamesView<PastSudokuGame>(
            gameTitle: "Past Sudoku",
            gameIcon: "grid.circle.fill",
            gameColor: .yellow,
            onGameSelected: { game in
                selectedGame = game
                showingDetail = true
            }
        )
        .sheet(isPresented: $showingDetail) {
            if let game = selectedGame {
                PastSudokuDetailView(game: game)
            }
        }
    }
}

// MARK: - Past Sudoku Game Model

struct PastSudokuGame: PastGame {
    let date: Date
    let difficulty: any GameDifficulty
    let sudokuDifficulty: SudokuDifficulty
    let score: Int?
    let puzzle: SudokuGrid
    let solution: SudokuGrid
    let completionTime: TimeInterval?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// SudokuDifficulty is defined in Models/SudokuModels.swift

// MARK: - Past Sudoku Generator

class PastSudokuGenerator {
    static func generatePastGames(days: Int = 30) -> [PastSudokuGame] {
        var games: [PastSudokuGame] = []
        let calendar = Calendar.current
        
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            
            let seed = String(Int(date.timeIntervalSince1970 / 86400)) // Daily seed
            let difficulty = SudokuDifficulty.allCases.randomElement() ?? .easy
            
            // Generate puzzle for this date
            let generated = SudokuGenerator.generate(seed: seed, difficulty: difficulty)
            let puzzle = generated.puzzle
            let solution = generated.solution
            
            // Simulate completion data
            let isCompleted = Bool.random()
            let completionTime = isCompleted ? Double.random(in: 60...600) : nil
            let score = isCompleted ? Int.random(in: 1000...5000) : nil
            
            let game = PastSudokuGame(
                date: date,
                difficulty: difficulty as any GameDifficulty,
                sudokuDifficulty: difficulty,
                score: score,
                puzzle: puzzle,
                solution: solution,
                completionTime: completionTime
            )
            
            games.append(game)
        }
        
        return games.sorted { $0.date > $1.date }
    }
}

// MARK: - Past Sudoku View Extension

extension PastGamesView where GameType == PastSudokuGame {
    func generateSamplePastGames() -> [PastSudokuGame] {
        return PastSudokuGenerator.generatePastGames(days: 30)
    }
}
