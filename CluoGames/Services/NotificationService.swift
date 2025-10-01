//
//  NotificationService.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation
import UserNotifications

// MARK: - Notification Service Protocol
protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func scheduleDailyReminder(at hour: Int, minute: Int)
    func cancelAllNotifications()
    func isNotificationPermissionGranted() async -> Bool
}

// MARK: - Notification Service Implementation
class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "New Puzzle Available! 🧩"
        content.body = "Your daily Clueo Games puzzle is ready to solve!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "daily-puzzle-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func isNotificationPermissionGranted() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
}

// MARK: - Notification Categories
extension NotificationService {
    
    func setupNotificationCategories() {
        let playAction = UNNotificationAction(
            identifier: "PLAY_ACTION",
            title: "Play Now",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER_ACTION",
            title: "Remind Later",
            options: []
        )
        
        let puzzleCategory = UNNotificationCategory(
            identifier: "PUZZLE_CATEGORY",
            actions: [playAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([puzzleCategory])
    }
}
