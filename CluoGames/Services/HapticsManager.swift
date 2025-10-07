//
//  HapticsManager.swift
//  CluoGames
//
//  Created by Assistant on 10/06/25.
//

import Foundation
import UIKit

enum HapticEvent {
    case success
    case warning
    case error
    case lightImpact
    case mediumImpact
    case heavyImpact
}

final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    func trigger(_ event: HapticEvent) {
        switch event {
        case .success:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        case .warning:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.warning)
        case .error:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.error)
        case .lightImpact:
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
        case .mediumImpact:
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
        case .heavyImpact:
            let gen = UIImpactFeedbackGenerator(style: .heavy)
            gen.impactOccurred()
        }
    }
}


