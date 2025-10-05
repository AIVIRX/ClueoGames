import SwiftUI

struct PastGamesView<GameType: PastGame>: View {
    let gameTitle: String
    let gameIcon: String
    let gameColor: Color
    let onGameSelected: (GameType) -> Void
    @State private var selectedDate: Date = Date()
    @State private var pastGames: [GameType] = []
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
    
    private var calendarView: some View {
        CalendarView(selectedDate: $selectedDate, gameColor: gameColor) { date in
            if let game = pastGames.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                ModernGameDayView(game: game, gameColor: gameColor, selectedDate: selectedDate) {
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
    
    
    private func loadPastGames() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let games = try await generateSamplePastGames()
                await MainActor.run {
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
    
    private func generateSamplePastGames() async throws -> [GameType] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // This will be overridden by specific game types
        return []
    }
}

// MARK: - Calendar Components

struct CalendarView<DayView: View>: View {
    @Binding var selectedDate: Date
    let dayView: (Date) -> DayView
    let gameColor: Color
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(selectedDate: Binding<Date>, gameColor: Color, @ViewBuilder dayView: @escaping (Date) -> DayView) {
        self._selectedDate = selectedDate
        self.gameColor = gameColor
        self.dayView = dayView
        dateFormatter.dateFormat = "MMMM yyyy"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: selectedDate).uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(gameColor)
            
            // Calendar grid
            VStack(spacing: 0) {
                // Day headers
                HStack(spacing: 0) {
                    ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Calendar days grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                    ForEach(calendarDays, id: \.self) { date in
                        dayView(date)
                    }
                }
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// MARK: - Modern Day Views

struct ModernGameDayView<GameType: PastGame>: View {
    let game: GameType
    let gameColor: Color
    let selectedDate: Date
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: {
            print("DEBUG: ModernGameDayView button tapped - isFutureDate: \(isFutureDate), game.date: \(game.date)")
            if !isFutureDate {
                onTap()
            }
        }) {
            Text("\(calendar.component(.day, from: game.date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(circleColor)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFutureDate)
    }
    
    private var isSelected: Bool {
        calendar.isDate(game.date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(game.date)
    }
    
    private var isFutureDate: Bool {
        calendar.isDate(game.date, inSameDayAs: Date()) == false && game.date > Date()
    }
    
    private var circleColor: Color {
        if isFutureDate {
            return .clear
        } else if isToday {
            return .green
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isFutureDate {
            return .gray
        } else if circleColor == .clear {
            return .primary
        } else {
            return .white
        }
    }
}

struct ModernEmptyDayView: View {
    let date: Date
    let selectedDate: Date
    let gameColor: Color
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: isFutureDate ? {} : onTap) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(circleColor)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFutureDate)
    }
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var isFutureDate: Bool {
        calendar.isDate(date, inSameDayAs: Date()) == false && date > Date()
    }
    
    private var circleColor: Color {
        if isFutureDate {
            return .clear
        } else if isToday {
            return .green
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isFutureDate {
            return .gray
        } else if circleColor == .clear {
            return .primary
        } else {
            return .white
        }
    }
}

struct GameCompletionIcon: View {
    let gameColor: Color
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Game icon background
            Circle()
                .fill(isSelected ? Color.white : gameColor)
                .frame(width: 20, height: 20)
            
            // Game icon
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? gameColor : .white)
        }
    }
}

// MARK: - Tile Views

struct GameTileView<GameType: PastGame>: View {
    let game: GameType
    let gameColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(game.dateString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(gameColor)
                        .font(.caption)
                }
                
                Text(game.difficulty.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let score = game.score {
                    Text("Score: \(score)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(gameColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(gameColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Past Game Protocol

protocol PastGame {
    associatedtype DifficultyType: GameDifficulty
    var date: Date { get }
    var dateString: String { get }
    var difficulty: DifficultyType { get }
    var score: Int? { get }
}

// GameDifficulty protocol is now defined in Models/GoalModels.swift

// MARK: - Sample Implementations

struct SamplePastGame: PastGame {
    typealias DifficultyType = SampleDifficulty
    
    let date: Date
    let difficulty: SampleDifficulty
    let score: Int?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum SampleDifficulty: String, GameDifficulty, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - New Modern Views

extension PastGamesView {
    
    
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
}

// MARK: - Modern Game Tile View

struct ModernGameTileView<GameType: PastGame>: View {
    let game: GameType
    let gameColor: Color
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with date and status
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.dateString)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(game.difficulty.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(gameColor)
                        .font(.title3)
                }
                
                // Score or completion info
                if let score = game.score {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(score)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                } else {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("In Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Game number indicator
                HStack {
                    Spacer()
                    Text("#\(index + 1)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(gameColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(gameColor.opacity(0.2))
                        )
                }
            }
            .padding(16)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(gameColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
