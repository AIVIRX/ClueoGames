//
//  CluoGamesApp.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import SwiftUI

@main
struct CluoGamesApp: App {
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
            await NotificationService.shared.requestPermission()
            await GameCenterService.shared.authenticate()
        }
        
        // Setup notification categories
        NotificationService.shared.setupNotificationCategories()
        
        // Schedule daily reminder (9 AM)
        NotificationService.shared.scheduleDailyReminder(at: 9, minute: 0)
    }
}
