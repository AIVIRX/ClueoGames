//
//  HomeViewModel.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation
import Combine
import UIKit

class HomeViewModel: ObservableObject {
    @Published var userProgress: UserGameProgress = UserGameProgress()
    @Published var todaysPuzzle: ConnectionsPuzzle?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let puzzleService: PuzzleServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        puzzleService: PuzzleServiceProtocol = PuzzleService()
    ) {
        self.puzzleService = puzzleService
        
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadTodaysPuzzle() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let puzzle = try await puzzleService.getTodaysPuzzle()
                await MainActor.run {
                    self.todaysPuzzle = puzzle
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load today's puzzle"
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func playTodaysPuzzle() {
        guard todaysPuzzle != nil else { return }
        // Navigation is handled by the view
    }
    
    @MainActor
    func shareResult() {
        guard let puzzle = todaysPuzzle else { return }
        
        let shareResult = ShareResult(
            puzzleType: .connections,
            timeToSolve: puzzle.timeToSolve ?? 0,
            mistakes: puzzle.mistakes,
            isPerfect: puzzle.mistakes == 0,
            streak: userProgress.currentStreak,
            date: puzzle.date
        )
        
        // Present share sheet with the result text
        let activityViewController = UIActivityViewController(
            activityItems: [shareResult.shareText],
            applicationActivities: nil
        )
        
        // Present from the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func setupBindings() {
        // Listen to puzzle service updates
        if let puzzleService = puzzleService as? PuzzleService {
            puzzleService.$userProgress
                .receive(on: DispatchQueue.main)
                .assign(to: \.userProgress, on: self)
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    private func loadInitialData() {
        loadTodaysPuzzle()
    }
}

// MARK: - Computed Properties
extension HomeViewModel {
    
    var canPlayTodaysPuzzle: Bool {
        return todaysPuzzle != nil && !(todaysPuzzle?.isSolved ?? false)
    }
    
    var todaysPuzzleStatus: String {
        guard let puzzle = todaysPuzzle else { return "Loading..." }
        
        if puzzle.isSolved {
            let timeString = formatTime(puzzle.timeToSolve ?? 0)
            let mistakeString = puzzle.mistakes == 0 ? "Perfect!" : "\(puzzle.mistakes) mistake\(puzzle.mistakes == 1 ? "" : "s")"
            return "Completed in \(timeString) with \(mistakeString)"
        } else {
            return "Ready to play"
        }
    }
    
    var streakText: String {
        if userProgress.currentStreak > 0 {
            return "🔥 \(userProgress.currentStreak) day streak"
        } else {
            return "Start your streak today!"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func dailySeed(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "sudoku-" + formatter.string(from: date)
    }
}
