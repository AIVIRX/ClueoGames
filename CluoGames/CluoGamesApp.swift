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
    @AppStorage("appearanceMode") private var appearanceMode: String = "auto"

    init() {
        #if DEBUG
        let logLevel: LogLevel = .debug
        #else
        let logLevel: LogLevel = .warn
        #endif

        PurchasesService.shared.configure(appUserID: nil, logLevel: logLevel)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    setupApp()
                }
                .preferredColorScheme(colorSchemeFromSetting())
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

    private func colorSchemeFromSetting() -> ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil // auto follows system
        }
    }
}
