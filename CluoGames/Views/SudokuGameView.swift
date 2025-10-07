//
//  SudokuGameView.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import SwiftUI

struct SudokuGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SudokuViewModel
    private let seed: String
    private let difficulty: SudokuDifficulty
    private let onComplete: (() -> Void)?
    @State private var isCompleted: Bool = false
    
    init(seed: String, difficulty: SudokuDifficulty, onComplete: (() -> Void)? = nil) {
        self.seed = seed
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: SudokuViewModel(seed: seed, difficulty: difficulty))
    }
    
    init(puzzle: SudokuGrid, solution: SudokuGrid, difficulty: SudokuDifficulty, onComplete: (() -> Void)? = nil) {
        self.seed = ""
        self.difficulty = difficulty
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: SudokuViewModel(puzzle: puzzle, solution: solution))
    }
    
    @State private var startTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                // Timer
                timerView
                
                // Grid
                grid
                
                // Number Pad
                numberPad
                    .disabled(isCompleted)
            }
            .padding(3)
            .navigationTitle("Sudoku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Reveal all") {
                            viewModel.revealAll()
                        }
                    } label: {
                        Image(systemName: "questionmark")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .disabled(isCompleted)
                }
            }
        }
        .onAppear {
            startTimer()
            selectFirstEditableCell()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: viewModel.grid) { _, _ in
            checkForCompletion()
        }
        .sheet(isPresented: $isCompleted) {
            completionSheet
        }
    }
    
    private var grid: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 32 // 16 padding on each side
            let maxSize: CGFloat = 450 // Maximum size for iPad/computer
            let cellSize = min(availableWidth / 9, maxSize / 9)
            
            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { c in
                            cell(r, c, size: cellSize)
                        }
                    }
                }
            }
            .frame(width: cellSize * 9, height: cellSize * 9)
            .overlay(
                Rectangle()
                    .stroke(Color.primary, lineWidth: 5)
            )
            .overlay(
                renderOverlayLines(width: cellSize)
                    .allowsHitTesting(false)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 400) // Give it a reasonable height
    }
    
    private var timerView: some View {
        VStack(spacing: 4) {
            Text(difficulty.rawValue.capitalized)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(formatTime(elapsedTime))
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func checkForCompletion() {
        // Check if all cells are filled and valid
        let isComplete = isBoardComplete()
        if isComplete && !isCompleted {
            isCompleted = true
            stopTimer()
            CompletionService.shared.markCompleted(gameType: .sudoku, date: completionDate())
            onComplete?()
        }
    }
    
    private func isBoardComplete() -> Bool {
        // Check if all cells are filled
        for r in 0..<9 {
            for c in 0..<9 {
                if viewModel.grid.cells[r][c].value == 0 {
                    return false
                }
            }
        }
        
        // Check if there are no conflicts
        for r in 0..<9 {
            for c in 0..<9 {
                if hasConflict(at: r, col: c) {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func selectFirstEditableCell() {
        // Find the first empty cell (editable cell)
        for r in 0..<9 {
            for c in 0..<9 {
                if viewModel.grid.cells[r][c].value == 0 {
                    viewModel.select(row: r, col: c)
                    return
                }
            }
        }
    }

    private func completionDate() -> Date {
        // Past Sudoku uses seeds like "MMM d, yyyy" from DailyGame.dateString.
        let pretty = DateFormatter()
        pretty.dateFormat = "MMM d, yyyy"
        if let d = pretty.date(from: seed) { return d }
        
        // Fallback: try ISO-like tokens inside seed
        let iso = DateFormatter()
        iso.dateFormat = "yyyy-MM-dd"
        if let d = iso.date(from: seed) { return d }
        
        // Last resort
        return Date()
    }
    
    private func cell(_ r: Int, _ c: Int, size: CGFloat) -> some View {
        let cell = viewModel.grid.cells[r][c]
        let isSelected = r == viewModel.selectedRow && c == viewModel.selectedCol
        let hasConflict = hasConflict(at: r, col: c)
        
        return ZStack {
            Rectangle()
                .fill(backgroundForCell(cell, isSelected: isSelected))
                .frame(width: size, height: size)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            
            Text(cell.value == 0 ? "" : String(cell.value))
                .font(.system(size: size * 0.5, weight: .heavy))
                .foregroundColor(.primary)
                .opacity(cell.value == 0 ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: cell.value)
            
            // Conflict indicator (red dot in top right)
            if hasConflict && cell.value != 0 {
                Circle()
                    .fill(Color.red)
                    .frame(width: size * 0.15, height: size * 0.15)
                    .position(x: size * 0.80, y: size * 0.30)
                    .scaleEffect(hasConflict ? 1.2 : 1.0)
                    .opacity(hasConflict ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: hasConflict)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .onTapGesture {
            print("Cell tapped: row \(r), col \(c)")
            // Only allow selection if cell can be modified
            if canModifyCell(at: r, col: c) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.select(row: r, col: c)
                }
            }
        }
        .allowsHitTesting(!isCompleted)
    }
    
    private func renderOverlayLines(width: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                // 3x3 Block separators (thick gray lines)
                Path { path in
                    let factor: CGFloat = width * 3
                    let blockLines: [CGFloat] = [1, 2]
                    
                    // Draw vertical block separators
                    for i: CGFloat in blockLines {
                        let vpos: CGFloat = i * factor
                        path.move(to: CGPoint(x: vpos, y: 4))
                        path.addLine(to: CGPoint(x: vpos, y: geometry.size.height - 4))
                    }
                    
                    // Draw horizontal block separators
                    for i: CGFloat in blockLines {
                        let hpos: CGFloat = i * factor
                        path.move(to: CGPoint(x: 4, y: hpos))
                        path.addLine(to: CGPoint(x: geometry.size.width - 4, y: hpos))
                    }
                }
                .stroke(lineWidth: 4.0)
                .foregroundColor(.gray)
                
                // Individual cell borders (thin gray lines)
                Path { path in
                    // Draw vertical cell separators
                    for i in 1..<9 {
                        let vpos: CGFloat = CGFloat(i) * width
                        path.move(to: CGPoint(x: vpos, y: 4))
                        path.addLine(to: CGPoint(x: vpos, y: geometry.size.height - 4))
                    }
                    
                    // Draw horizontal cell separators
                    for i in 1..<9 {
                        let hpos: CGFloat = CGFloat(i) * width
                        path.move(to: CGPoint(x: 4, y: hpos))
                        path.addLine(to: CGPoint(x: geometry.size.width - 4, y: hpos))
                    }
                }
                .stroke(lineWidth: 2.0)
                .foregroundColor(.gray.opacity(0.6))
            }
        }
    }
    
    private func backgroundForCell(_ cell: SudokuCell, isSelected: Bool) -> Color {
        if isSelected {
            return Color.yellow.opacity(0.8)
        } else if cell.isGiven {
            return Color.gray.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private func hasConflict(at row: Int, col: Int) -> Bool {
        let currentValue = viewModel.grid.cells[row][col].value
        guard currentValue != 0 else { return false }
        
        // Count how many times this value appears in the same row
        var rowCount = 0
        for c in 0..<9 {
            if viewModel.grid.cells[row][c].value == currentValue {
                rowCount += 1
            }
        }
        if rowCount > 1 { return true }
        
        // Count how many times this value appears in the same column
        var colCount = 0
        for r in 0..<9 {
            if viewModel.grid.cells[r][col].value == currentValue {
                colCount += 1
            }
        }
        if colCount > 1 { return true }
        
        // Count how many times this value appears in the same 3x3 block
        let blockRow = (row / 3) * 3
        let blockCol = (col / 3) * 3
        var blockCount = 0
        
        for r in blockRow..<(blockRow + 3) {
            for c in blockCol..<(blockCol + 3) {
                if viewModel.grid.cells[r][c].value == currentValue {
                    blockCount += 1
                }
            }
        }
        if blockCount > 1 { return true }
        
        return false
    }
    
    private func canModifyCell(at row: Int, col: Int) -> Bool {
        let cell = viewModel.grid.cells[row][col]
        
        // Can modify if:
        // 1. Cell is empty
        // 2. Cell is given (predetermined) 
        // 3. Cell has conflicts (incorrect)
        // 4. Cell is user-entered (any value)
        if cell.isGiven {
            return false // Can always modify given cells
        }
        
        if cell.value == 0 {
            return true // Can modify empty cells
        }
        
        if hasConflict(at: row, col: col) {
            return true // Can modify conflicting cells
        }
        
        // Can modify any user-entered cell
        return true
    }
    
    private func canModifySelectedCell() -> Bool {
        guard let selectedRow = viewModel.selectedRow, let selectedCol = viewModel.selectedCol else {
            return false
        }
        return canModifyCell(at: selectedRow, col: selectedCol)
    }
    
    private var numberPad: some View {
        VStack(spacing: 12) {
            // Row 1: Numbers 1-5
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { n in
                    numberButton(n)
                }
            }
            
            // Row 2: Numbers 6-9 + Backspace
            HStack(spacing: 12) {
                ForEach(6...9, id: \.self) { n in
                    numberButton(n)
                }
                
                // Backspace button
                Button(action: { 
                    if canModifySelectedCell() {
                        viewModel.clear() 
                    }
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(canModifySelectedCell() ? .red : .gray)
                        .frame(width: 60, height: 60)
                        .background(canModifySelectedCell() ? Color(.gray.opacity(0.5)) : Color.gray.opacity(0.3))
                        .cornerRadius(16)
                }
                .disabled(!canModifySelectedCell())
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func numberButton(_ number: Int) -> some View {
        Button(action: { 
            if canModifySelectedCell() {
                viewModel.set(value: number) 
                // Trigger warning haptic if current placement causes a conflict
                if let r = viewModel.selectedRow, let c = viewModel.selectedCol {
                    if hasConflict(at: r, col: c) {
                        HapticsManager.shared.trigger(.warning)
                    }
                }
            }
        }) {
            Text(String(number))
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(canModifySelectedCell() ? .primary : .gray)
                .frame(width: 60, height: 60)
                .background(canModifySelectedCell() ? Color(.gray.opacity(0.5)) : Color.gray.opacity(0.3))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .disabled(!canModifySelectedCell())
    }

    private var completionSheet: some View {
        GameCompletionView(
            gameType: "Sudoku",
            isWon: true,
            primaryInfo: "Puzzle Complete!",
            secondaryInfo: "Time: \(formatTime(elapsedTime))",
            additionalChips: [
                CompletionChip(title: "Time", value: formatTime(elapsedTime), icon: "clock.fill"),
                CompletionChip(title: "Difficulty", value: difficulty.rawValue.capitalized, icon: "bolt.fill")
            ],
            onDone: { isCompleted = false },
            onBackToList: { dismiss() }
        )
    }
}

#Preview {
    SudokuGameView(seed: "daily-2025-09-29", difficulty: .easy)
}



