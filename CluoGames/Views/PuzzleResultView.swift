//
//  PuzzleResultView.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import SwiftUI

struct PuzzleResultView: View {
    let puzzle: ConnectionsPuzzle
    let timeToSolve: TimeInterval
    let mistakes: Int
    let streak: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingShare = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Success Animation
                successSection
                
                // Results
                resultsSection
                
                // Actions
                actionsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Puzzle Complete!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(items: [shareText])
        }
    }
    
    // MARK: - Success Section
    private var successSection: some View {
        VStack(spacing: 16) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.green)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
            
            Text("Congratulations!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You solved today's puzzle!")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(spacing: 20) {
            // Time and Mistakes
            HStack(spacing: 32) {
                ResultItem(
                    title: "Time",
                    value: formattedTime,
                    icon: "clock.fill",
                    color: .blue
                )
                
                ResultItem(
                    title: "Mistakes",
                    value: "\(mistakes)",
                    icon: mistakes == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                    color: mistakes == 0 ? .green : .orange
                )
            }
            
            // Streak
            if streak > 0 {
                ResultItem(
                    title: "Current Streak",
                    value: "\(streak) 🔥",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            // Perfect Score Badge
            if mistakes == 0 {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Perfect Score!")
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(20)
            }
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 16) {
            // Share Button
            Button(action: { showingShare = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Result")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            // Play Again Button (if not today's puzzle)
            if !Calendar.current.isDateInToday(puzzle.date) {
                Button("Play Another Puzzle") {
                    // Navigate to puzzle selection
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var formattedTime: String {
        let minutes = Int(timeToSolve) / 60
        let seconds = Int(timeToSolve) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var shareText: String {
        let emoji = mistakes == 0 ? "🎉" : "✅"
        let mistakeString = mistakes == 0 ? "Perfect!" : "\(mistakes) mistake\(mistakes == 1 ? "" : "s")"
        
        return """
        \(emoji) Clueo Games - Connections
        Solved in \(formattedTime) with \(mistakeString)
        Streak: \(streak) 🔥
        """
    }
}

// MARK: - Result Item View
struct ResultItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    let samplePuzzle = ConnectionsPuzzle(
        id: "preview",
        date: Date(),
        difficulty: .medium,
        words: [],
        groups: [],
        title: "Daily Connections",
        description: "Group the words into 4 categories of 4"
    )
    
    PuzzleResultView(
        puzzle: samplePuzzle,
        timeToSolve: 180, // 3 minutes
        mistakes: 1,
        streak: 5
    )
}
