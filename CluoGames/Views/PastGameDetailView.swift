import SwiftUI

struct PastGameDetailView<GameType: PastGame>: View {
    let game: GameType
    let gameColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Game info header
                VStack(spacing: 12) {
                    Text(game.dateString)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(game.difficulty.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(gameColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(gameColor.opacity(0.1))
                        )
                    
                    if let score = game.score {
                        Text("Score: \(score)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Game content
                gameContentView
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: playGame) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play Game")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(gameColor)
                        .cornerRadius(12)
                    }
                    
                    if game.score != nil {
                        Button(action: viewSolution) {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("View Solution")
                            }
                            .font(.subheadline)
                            .foregroundColor(gameColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(gameColor, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Game Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var gameContentView: some View {
        // This will be overridden by specific game types
        VStack {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(gameColor.opacity(0.6))
            
            Text("Game Preview")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(gameColor.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private func playGame() {
        // This will be overridden by specific game types
        print("Playing game for \(game.dateString)")
    }
    
    private func viewSolution() {
        // This will be overridden by specific game types
        print("Viewing solution for \(game.dateString)")
    }
}

// MARK: - Past Sudoku Detail View

struct PastSudokuDetailView: View {
    let game: PastSudokuGame
    @Environment(\.dismiss) private var dismiss
    @State private var showingGame = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Game info header
                VStack(spacing: 12) {
                    Text(game.dateString)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(game.difficulty.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.yellow.opacity(0.1))
                        )
                    
                    if let score = game.score {
                        Text("Score: \(score)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let completionTime = game.completionTime {
                        Text("Time: \(formatTime(completionTime))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Sudoku preview
                SudokuPreviewView(puzzle: game.puzzle)
                    .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: { showingGame = true }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play Game")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(12)
                    }
                    
                    if game.score != nil {
                        Button(action: viewSolution) {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("View Solution")
                            }
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Sudoku Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingGame) {
            SudokuGameView(
                puzzle: game.puzzle,
                solution: game.solution,
                difficulty: game.sudokuDifficulty
            )
        }
    }
    
    private func viewSolution() {
        // Show solution in a sheet
        print("Viewing Sudoku solution for \(game.dateString)")
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Sudoku Preview View

struct SudokuPreviewView: View {
    let puzzle: SudokuGrid
    
    private let gridSize: CGFloat = 200
    private let cellSize: CGFloat = 200 / 9
    
    var body: some View {
        VStack {
            Text("Puzzle Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack {
                // Grid background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                
                // Sudoku grid
                VStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<9, id: \.self) { col in
                                let cell = puzzle.cells[row][col]
                                Text(cell.value == 0 ? "" : "\(cell.value)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(cell.isGiven ? .primary : .blue)
                                    .frame(width: cellSize, height: cellSize)
                                    .background(
                                        Rectangle()
                                            .fill(cell.isGiven ? Color(.systemGray6) : Color.clear)
                                    )
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(width: gridSize, height: gridSize)
        }
    }
}

// MARK: - Past Exacto Detail View

struct PastExactoDetailView: View {
    let game: PastExactoGame
    @Environment(\.dismiss) private var dismiss
    @State private var showingGame = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Game info header
                VStack(spacing: 12) {
                    Text(game.dateString)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(game.difficulty.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(.pink)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.pink.opacity(0.1))
                        )
                    
                    if let score = game.score {
                        Text("Score: \(score)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let completionTime = game.completionTime {
                        Text("Time: \(formatTime(completionTime))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Exacto preview
                ExactoPreviewView(target: game.target, numbers: game.numbers)
                    .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: { showingGame = true }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play Game")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(12)
                    }
                    
                    if game.score != nil {
                        Button(action: viewSolution) {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("View Solution")
                            }
                            .font(.subheadline)
                            .foregroundColor(.pink)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.pink, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Exacto Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingGame) {
            ExactoGameView(
                puzzle: game.puzzle,
                difficulty: game.exactoDifficulty
            )
        }
    }
    
    private func viewSolution() {
        // Show solution in a sheet
        print("Viewing Exacto solution for \(game.dateString)")
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Exacto Preview View

struct ExactoPreviewView: View {
    let target: Int
    let numbers: [Int]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Puzzle Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                // Target
                Text("Target: \(target)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                
                // Numbers
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(numbers, id: \.self) { number in
                        Text("\(number)")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.pink.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pink.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}
