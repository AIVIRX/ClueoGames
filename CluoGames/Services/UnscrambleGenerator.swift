//
//  UnscrambleGenerator.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation

struct UnscrambleGenerator {
    // Daily word list (5-7 letters)
    private static let dailyWords = [
        "APPLE", "BREAD", "CHAIR", "DANCE", "EARTH", "FRUIT", "GLASS", "HEART",
        "IDEAS", "JOKER", "KNIFE", "LIGHT", "MUSIC", "NIGHT", "OCEAN", "PAPER",
        "QUICK", "RIVER", "SMART", "TABLE", "UNITY", "VALUE", "WATER", "YOUTH",
        "ZEBRA", "BEAUTY", "CANDLE", "DREAMS", "EAGLES", "FAMILY", "GARDEN",
        "HAPPY", "ISLAND", "JUNGLE", "KITTEN", "LADDER", "MAGIC", "NATURE",
        "ORANGE", "PURPLE", "QUIET", "RABBIT", "SUNNY", "TIGER", "UNION",
        "VICTOR", "WINTER", "YELLOW", "ZEBRAS", "BEAUTIFUL", "CHRISTMAS",
        "DINOSAUR", "ELEPHANT", "FIREWORK", "GARDENER", "HAPPINESS",
        "IMAGINATION", "JOURNEY", "KINDNESS", "LADYBUG", "MAGNIFICENT",
        "NATURALLY", "ORIGINAL", "PICTURES", "QUESTION", "RAINBOW",
        "SUNSHINE", "TREASURE", "UNIVERSE", "VICTORY", "WONDERFUL",
        "YELLOWISH", "ZEBRAS"
    ]
    
    static func dailyWord(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % dailyWords.count
        return dailyWords[index]
    }
    
    static func scrambleWord(_ word: String) -> String {
        let characters = Array(word.uppercased())
        var scrambled = characters.shuffled()
        
        // Ensure it's not the same as original
        while String(scrambled) == word.uppercased() && characters.count > 1 {
            scrambled = characters.shuffled()
        }
        
        return String(scrambled)
    }
    
    static func generateDailyGame(for date: Date = Date()) -> UnscrambleGame {
        let word = dailyWord(for: date)
        return UnscrambleGame(word: word)
    }
    
    static func isValidWord(_ word: String) -> Bool {
        // Basic validation - could be enhanced with a dictionary
        return word.count >= 5 && word.count <= 7 && word.allSatisfy { $0.isLetter }
    }
}
