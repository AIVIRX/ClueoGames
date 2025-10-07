//
//  CompletionService.swift
//  CluoGames
//
//  Created by Assistant on 10/06/25.
//

import Foundation
import Combine

enum DailyGameType: String, Codable {
    case sudoku
    case exacto
    case unscramble
}

final class CompletionService: ObservableObject {
    static let shared = CompletionService()
    private let userDefaults = UserDefaults.standard
    @Published private(set) var updatedAt: Date = Date()

    private init() {}

    func markCompleted(gameType: DailyGameType, date: Date) {
        let key = keyFor(gameType: gameType, date: date)
        userDefaults.set(true, forKey: key)
        DispatchQueue.main.async { [weak self] in
            self?.updatedAt = Date()
        }
    }

    func isCompleted(gameType: DailyGameType, date: Date) -> Bool {
        let key = keyFor(gameType: gameType, date: date)
        return userDefaults.bool(forKey: key)
    }

    private func keyFor(gameType: DailyGameType, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        return "completed-\(gameType.rawValue)-\(day)"
    }
}


