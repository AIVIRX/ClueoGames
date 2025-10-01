//
//  ConnectionsGameView.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import SwiftUI

struct ConnectionsGameView: View {
    @StateObject private var viewModel: ConnectionsGameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingResult = false
    
    init(puzzle: ConnectionsPuzzle) {
        self._viewModel = StateObject(wrappedValue: ConnectionsGameViewModel(puzzle: puzzle))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Progress Bar
                progressSection
                
                // Game Grid
                gameGridSection
                
                // Bottom Controls
                bottomControlsSection
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        viewModel.resetGame()
                    }
                    .disabled(viewModel.gameState == .completed)
                }
            }
        }
        .sheet(isPresented: $showingResult) {
            PuzzleResultView(
                puzzle: viewModel.puzzle,
                timeToSolve: viewModel.puzzle.timeToSolve ?? 0,
                mistakes: viewModel.mistakes,
                streak: 0 // This would come from the service
            )
        }
        .onChange(of: viewModel.showingResult) { _, newValue in
            showingResult = newValue
        }
        .alert("Wrong Group", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.puzzle.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(viewModel.puzzle.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.formattedTime)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                    
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Label("\(viewModel.mistakes)/4", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("Find groups of 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(viewModel.completedGroups.count)/\(viewModel.puzzle.groups.count)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: viewModel.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // MARK: - Game Grid Section
    private var gameGridSection: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(viewModel.availableWords, id: \.self) { word in
                    WordChip(
                        word: word,
                        isSelected: viewModel.isWordSelected(word),
                        isCompleted: viewModel.isWordCompleted(word),
                        group: viewModel.getGroupForWord(word),
                        onTap: {
                            viewModel.selectWord(word)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Bottom Controls Section
    private var bottomControlsSection: some View {
        VStack(spacing: 16) {
            if !viewModel.selectedWords.isEmpty {
                selectedWordsSection
            }
            
            HStack(spacing: 16) {
                Button("Deselect All") {
                    viewModel.deselectAll()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.selectedWords.isEmpty)
                
                Spacer()
                
                Text("\(viewModel.selectedWords.count)/4 selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Selected Words Section
    private var selectedWordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected Words")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(Array(viewModel.selectedWords), id: \.self) { word in
                    Text(word)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Word Chip View
struct WordChip: View {
    let word: String
    let isSelected: Bool
    let isCompleted: Bool
    let group: ConnectionsPuzzle.WordGroup?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(word)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(word) word")
        .accessibilityHint(isCompleted ? "Completed" : isSelected ? "Selected" : "Tap to select")
    }
    
    private var backgroundColor: Color {
        if isCompleted, let group = group {
            return Color(hex: group.color) ?? .blue
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .white
        } else if isSelected {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var borderColor: Color {
        if isCompleted, let group = group {
            return Color(hex: group.color) ?? .blue
        } else if isSelected {
            return .blue
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        return isSelected || isCompleted ? 2 : 0
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    let samplePuzzle = ConnectionsPuzzle(
        id: "preview",
        date: Date(),
        difficulty: .medium,
        words: ["APPLE", "BANANA", "ORANGE", "GRAPE", "CAR", "TRUCK", "BIKE", "BUS", "RED", "BLUE", "GREEN", "YELLOW", "DOG", "CAT", "BIRD", "FISH"],
        groups: [
            ConnectionsPuzzle.WordGroup(id: "fruits", words: ["APPLE", "BANANA", "ORANGE", "GRAPE"], category: "Fruits", difficulty: 1, color: "#FF6B6B"),
            ConnectionsPuzzle.WordGroup(id: "vehicles", words: ["CAR", "TRUCK", "BIKE", "BUS"], category: "Vehicles", difficulty: 2, color: "#4ECDC4"),
            ConnectionsPuzzle.WordGroup(id: "colors", words: ["RED", "BLUE", "GREEN", "YELLOW"], category: "Colors", difficulty: 3, color: "#45B7D1"),
            ConnectionsPuzzle.WordGroup(id: "animals", words: ["DOG", "CAT", "BIRD", "FISH"], category: "Animals", difficulty: 4, color: "#96CEB4")
        ],
        title: "Daily Connections",
        description: "Group the words into 4 categories of 4"
    )
    
    ConnectionsGameView(puzzle: samplePuzzle)
}
