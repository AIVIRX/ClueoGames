import SwiftUI

struct PastGamesView<GameType: PastGame>: View {
    let gameTitle: String
    let gameIcon: String
    let gameColor: Color
    let onGameSelected: (GameType) -> Void
    @State private var selectedDate: Date = Date()
    @State private var viewMode: ViewMode = .calendar
    @State private var pastGames: [GameType] = []
    @State private var isLoading = false
    
    enum ViewMode: CaseIterable {
        case calendar, tiles
        
        var icon: String {
            switch self {
            case .calendar: return "calendar"
            case .tiles: return "square.grid.2x2"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // View mode picker
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on view mode
                if viewMode == .calendar {
                    calendarView
                } else {
                    tilesView
                }
            }
            .navigationTitle(gameTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        selectedDate = Date()
                    }
                }
            }
            .onAppear {
                loadPastGames()
            }
        }
    }
    
    private var calendarView: some View {
        CalendarView(selectedDate: $selectedDate) { date in
            if let game = pastGames.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                GameDayView(game: game, gameColor: gameColor) {
                    onGameSelected(game)
                }
            } else {
                EmptyDayView()
            }
        }
        .padding()
    }
    
    private var tilesView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(pastGames, id: \.date) { game in
                    GameTileView(game: game, gameColor: gameColor) {
                        onGameSelected(game)
                    }
                }
            }
            .padding()
        }
    }
    
    private func loadPastGames() {
        isLoading = true
        // Simulate loading past games
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pastGames = generateSamplePastGames()
            isLoading = false
        }
    }
    
    private func generateSamplePastGames() -> [GameType] {
        // This will be overridden by specific game types
        return []
    }
}

// MARK: - Calendar Components

struct CalendarView<DayView: View>: View {
    @Binding var selectedDate: Date
    let dayView: (Date) -> DayView
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(selectedDate: Binding<Date>, @ViewBuilder dayView: @escaping (Date) -> DayView) {
        self._selectedDate = selectedDate
        self.dayView = dayView
        dateFormatter.dateFormat = "MMMM yyyy"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // Calendar days
                ForEach(calendarDays, id: \.self) { date in
                    dayView(date)
                }
            }
        }
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

// MARK: - Day Views

struct GameDayView<GameType: PastGame>: View {
    let game: GameType
    let gameColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: game.date))")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Circle()
                    .fill(gameColor)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(gameColor.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyDayView: View {
    var body: some View {
        Text("\(Calendar.current.component(.day, from: Date()))")
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(width: 32, height: 32)
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
    var date: Date { get }
    var dateString: String { get }
    var difficulty: any GameDifficulty { get }
    var score: Int? { get }
}

// GameDifficulty protocol is now defined in Models/GoalModels.swift

// MARK: - Sample Implementations

struct SamplePastGame: PastGame {
    let date: Date
    let difficulty: any GameDifficulty
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
