//
//  CluoGamesApp.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import SwiftUI
import RevenueCat

@main
struct CluoGamesApp: App {
    init() {
            Purchases.logLevel = .debug
            Purchases.configure(withAPIKey: <public_apple_api_key>, appUserID: <app_user_id>)
        }
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Request notification permissions
        Task {
            _ = await NotificationService.shared.requestPermission()
        }
        
        // Setup notification categories
        NotificationService.shared.setupNotificationCategories()
        
        // Schedule daily reminder (9 AM)
        NotificationService.shared.scheduleDailyReminder(at: 9, minute: 0)
    }
}
