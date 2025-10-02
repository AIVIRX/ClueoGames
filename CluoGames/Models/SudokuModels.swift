//
//  SudokuModels.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import Foundation

public enum SudokuDifficulty: String, CaseIterable, Codable, GameDifficulty {
    case easy
    case medium
    case hard
    
    public var displayName: String {
        rawValue.capitalized
    }
}

public struct SudokuCell: Hashable, Codable {
    public let row: Int
    public let col: Int
    public var value: Int
    public var isGiven: Bool
}

public struct SudokuGrid: Hashable, Codable {
    public var cells: [[SudokuCell]] // 9x9
    
    public static func empty() -> SudokuGrid {
        var rows: [[SudokuCell]] = []
        for r in 0..<9 {
            var row: [SudokuCell] = []
            for c in 0..<9 {
                row.append(SudokuCell(row: r, col: c, value: 0, isGiven: false))
            }
            rows.append(row)
        }
        return SudokuGrid(cells: rows)
    }
    
    public subscript(r: Int, c: Int) -> SudokuCell {
        get { cells[r][c] }
        set { cells[r][c] = newValue }
    }
}


