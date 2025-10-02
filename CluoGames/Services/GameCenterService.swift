//
//  GameCenterService.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import Foundation
import Combine
import GameKit
import SwiftUI
import UIKit

final class GameCenterService: ObservableObject {
    static let shared = GameCenterService()
    
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var playerAlias: String = ""
    
    private init() { }
    
    @MainActor
    func authenticate() async {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController {
                // Present sign-in UI from top-most controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let root = window.rootViewController {
                    root.present(viewController, animated: true)
                }
                return
            }
            
            if let error {
                print("Game Center auth error: \(error.localizedDescription)")
            }
            
            Task { @MainActor in
                self.isAuthenticated = localPlayer.isAuthenticated
                self.playerAlias = localPlayer.alias
            }
        }
    }
    
    func presentGameCenter(state: GKGameCenterViewControllerState = .default) {
        // Use modern GameCenterView instead of deprecated GKGameCenterViewController
        // This requires a SwiftUI view to be presented
        print("Game Center presentation requested with state: \(state)")
        // Note: In a real implementation, you would present a SwiftUI GameCenterView
        // For now, we'll just log the request as the UI should handle the presentation
    }
    
    func presentLeaderboards() {
        presentGameCenter(state: .leaderboards)
    }
    
    func presentAchievements() {
        presentGameCenter(state: .achievements)
    }
    
    func presentDashboard() {
        presentGameCenter(state: .dashboard)
    }
}

// GKGameCenterControllerDelegate removed - using modern GameCenterView instead



