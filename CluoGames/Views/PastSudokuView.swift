import SwiftUI

struct PastSudokuView: View {
    var body: some View {
        PastGamesListView(
            gameTitle: "Past Sudoku",
            gameIcon: "grid.circle.fill",
            gameColor: .yellow,
            gameType: .sudoku
        )
    }
}

// MARK: - Custom Past Sudoku View with Real Data
struct PastSudokuGamesView: View {
    let gameTitle: String
    let gameIcon: String
    let gameColor: Color
    let onGameSelected: (PastSudokuGame) -> Void
    @State private var selectedDate: Date = Date()
    @State private var pastGames: [PastSudokuGame] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Content
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if pastGames.isEmpty {
                    emptyStateView
                } else {
                    calendarView
                }
            }
            .navigationTitle(gameTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        selectedDate = Date()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadPastGames()
            }
            .refreshable {
                await refreshPastGames()
            }
        }
    }

    // MARK: - View Components
    
    
    private var calendarView: some View {
        CalendarView(selectedDate: $selectedDate, gameColor: gameColor) { date in
            if let game = pastGames.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                ModernGameDayView(game: game, gameColor: gameColor, selectedDate: selectedDate) {
                    print("DEBUG: Game selected - \(game.dateString)")
                    onGameSelected(game)
                }
            } else {
                ModernEmptyDayView(date: date, selectedDate: selectedDate, gameColor: gameColor) {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(gameColor)
            Text("Loading past games...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unable to load games")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Try Again") {
                loadPastGames()
            }
            .buttonStyle(.bordered)
            .tint(gameColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: gameIcon)
                .font(.system(size: 64))
                .foregroundColor(gameColor.opacity(0.6))
            
            Text("No past games yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start playing to see your game history here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Data Loading
    
    private func loadPastGames() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let games = try await generateSampleSudokuGames()
                await MainActor.run {
                    print("DEBUG: Loaded \(games.count) past games")
                    pastGames = games
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func refreshPastGames() async {
        await withCheckedContinuation { continuation in
            loadPastGames()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                continuation.resume()
            }
        }
    }
    
    private func generateSampleSudokuGames() async throws -> [PastSudokuGame] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let calendar = Calendar.current
        let today = Date()
        var games: [PastSudokuGame] = []
        
        // Generate games for the last 30 days
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Randomly decide if this day has a game (80% chance)
            if Int.random(in: 1...10) <= 8 {
                let difficulty = SudokuDifficulty.allCases.randomElement() ?? .medium
                let score = Int.random(in: 100...1000)
                let completionTime = TimeInterval.random(in: 60...600) // 1-10 minutes
                
                let game = PastSudokuGame(
                    date: date,
                    difficulty: difficulty,
                    sudokuDifficulty: difficulty,
                    score: score,
                    puzzle: SudokuGrid.empty(),
                    solution: SudokuGrid.empty(),
                    completionTime: completionTime
                )
                games.append(game)
            }
        }
        
        return games.sorted { $0.date > $1.date }
    }
}

// MARK: - Past Sudoku Game Model

struct PastSudokuGame: PastGame {
    typealias DifficultyType = SudokuDifficulty
    
    let date: Date
    let difficulty: SudokuDifficulty
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
                difficulty: difficulty,
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

// MARK: - Past Games List View

enum GameType {
    case sudoku
    case exacto
    case unscramble
    case connections
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
                            SudokuGameView(seed: dailyGame.dateString, difficulty: .medium)
                        } label: {
                            GameHeroCard(
                                title: "Sudoku",
                                subtitle: "Fill each row & column with digits 1–9 without repeats.",
                                dateText: dailyGame.dateString,
                                icon: "square.grid.3x3.fill",
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


