//
//  GoalModels.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation

public protocol GameDifficulty: CaseIterable, RawRepresentable where RawValue == String {
    var displayName: String { get }
}

public enum ExactoDifficulty: String, CaseIterable, Codable, GameDifficulty {
    case easy
    case medium
    case hard
    
    public var displayName: String {
        rawValue.capitalized
    }
}

public struct ExactoPuzzle: Codable, Hashable {
    public let id: String
    public let date: Date
    public let target: Int
    public let numbers: [Int] // six numbers
}

public enum ExactoOperation: String, CaseIterable, Codable {
    case multiply = "×"
}

public struct ExactoStep: Codable, Hashable {
    public let left: Int
    public let right: Int
    public let operation: ExactoOperation
    public let result: Int
    public var description: String {
        return "\(left) \(operation.rawValue) \(right) = \(result)"
    }
}

public struct ExactoScore: Codable, Hashable {
    public let distance: Int // |result - target|
    public let points: Int
    public let exact: Bool
}


