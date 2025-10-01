//
//  LocalizationService.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation

// MARK: - Localization Service
class LocalizationService {
    static let shared = LocalizationService()
    
    private init() {}
    
    func localizedString(for key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }
    
    func localizedString(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys
struct LocalizationKeys {
    
    // MARK: - App General
    struct App {
        static let title = "app.title"
        static let subtitle = "app.subtitle"
        static let tagline = "app.tagline"
    }
    
    // MARK: - Navigation
    struct Navigation {
        static let home = "nav.home"
        static let puzzle = "nav.puzzle"
        static let results = "nav.results"
        static let settings = "nav.settings"
    }
    
    // MARK: - Home Screen
    struct Home {
        static let todaysPuzzle = "home.todays_puzzle"
        static let playButton = "home.play_button"
        static let viewButton = "home.view_button"
        static let shareButton = "home.share_button"
        static let streakTitle = "home.streak_title"
        static let totalSolved = "home.total_solved"
        static let bestStreak = "home.best_streak"
        static let startStreak = "home.start_streak"
        static let gameModes = "home.game_modes"
        static let connections = "home.connections"
        static let crossword = "home.crossword"
        static let comingSoon = "home.coming_soon"
    }
    
    // MARK: - Game Screen
    struct Game {
        static let progress = "game.progress"
        static let time = "game.time"
        static let mistakes = "game.mistakes"
        static let findGroups = "game.find_groups"
        static let selectedWords = "game.selected_words"
        static let deselectAll = "game.deselect_all"
        static let selectedCount = "game.selected_count"
        static let wrongGroup = "game.wrong_group"
        static let correctGroup = "game.correct_group"
        static let gameComplete = "game.game_complete"
    }
    
    // MARK: - Results Screen
    struct Results {
        static let congratulations = "results.congratulations"
        static let solvedToday = "results.solved_today"
        static let time = "results.time"
        static let mistakes = "results.mistakes"
        static let perfectScore = "results.perfect_score"
        static let shareResult = "results.share_result"
        static let playAnother = "results.play_another"
        static let currentStreak = "results.current_streak"
    }
    
    // MARK: - Puzzle Types
    struct Puzzle {
        static let connections = "puzzle.connections"
        static let crossword = "puzzle.crossword"
        static let daily = "puzzle.daily"
    }
    
    // MARK: - Difficulty Levels
    struct Difficulty {
        static let easy = "difficulty.easy"
        static let medium = "difficulty.medium"
        static let hard = "difficulty.hard"
    }
    
    // MARK: - Game States
    struct State {
        static let notStarted = "state.not_started"
        static let inProgress = "state.in_progress"
        static let completed = "state.completed"
        static let failed = "state.failed"
    }
    
    // MARK: - Buttons
    struct Button {
        static let play = "button.play"
        static let close = "button.close"
        static let reset = "button.reset"
        static let share = "button.share"
        static let upgrade = "button.upgrade"
        static let done = "button.done"
        static let cancel = "button.cancel"
        static let ok = "button.ok"
        static let retry = "button.retry"
    }
    
    // MARK: - Errors
    struct Error {
        static let loadingPuzzle = "error.loading_puzzle"
        static let purchaseFailed = "error.purchase_failed"
        static let networkError = "error.network_error"
        static let generic = "error.generic"
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let puzzleWord = "accessibility.puzzle_word"
        static let selectedWord = "accessibility.selected_word"
        static let completedWord = "accessibility.completed_word"
        static let tapToSelect = "accessibility.tap_to_select"
        static let gameProgress = "accessibility.game_progress"
        static let timeElapsed = "accessibility.time_elapsed"
        static let mistakesCount = "accessibility.mistakes_count"
        static let streakCount = "accessibility.streak_count"
    }
    
    // MARK: - Share Text
    struct Share {
        static let connectionsSolved = "share.connections_solved"
        static let crosswordSolved = "share.crossword_solved"
        static let perfect = "share.perfect"
        static let mistakes = "share.mistakes"
    }
    
    // MARK: - Notifications
    struct Notification {
        static let dailyReminderTitle = "notification.daily_reminder_title"
        static let dailyReminderBody = "notification.daily_reminder_body"
        static let playNow = "notification.play_now"
        static let remindLater = "notification.remind_later"
    }
    
    
    // MARK: - Analytics Events
    struct Analytics {
        static let puzzleStarted = "analytics.puzzle_started"
        static let puzzleCompleted = "analytics.puzzle_completed"
        static let puzzleAbandoned = "analytics.puzzle_abandoned"
        static let resultShared = "analytics.result_shared"
        static let streakAchieved = "analytics.streak_achieved"
    }
}
