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

final class GameCenterService: NSObject, ObservableObject {
    static let shared = GameCenterService()
    
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var playerAlias: String = ""
    
    private override init() { super.init() }
    
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
        let viewController = GKGameCenterViewController(state: state)
        viewController.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let root = window.rootViewController {
            root.present(viewController, animated: true)
        }
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

extension GameCenterService: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}



