//
//  GameCompletionView.swift
//  CluoGames
//
//  Created by Assistant on 10/06/25.
//

import SwiftUI

struct GameCompletionView: View {
    let gameType: String
    let isWon: Bool
    let primaryInfo: String
    let secondaryInfo: String?
    let additionalChips: [CompletionChip]
    let onDone: () -> Void
    let onBackToList: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        gameType: String,
        isWon: Bool,
        primaryInfo: String,
        secondaryInfo: String? = nil,
        additionalChips: [CompletionChip] = [],
        onDone: @escaping () -> Void,
        onBackToList: (() -> Void)? = nil
    ) {
        self.gameType = gameType
        self.isWon = isWon
        self.primaryInfo = primaryInfo
        self.secondaryInfo = secondaryInfo
        self.additionalChips = additionalChips
        self.onDone = onDone
        self.onBackToList = onBackToList
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer(minLength: 12)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    VStack(spacing: 16) {
                        Image(systemName: isWon ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(isWon ? .green : .red)
                        
                        Text(isWon ? "\(gameType) Solved" : "Game Over")
                            .font(.system(size: 28, weight: .bold))
                        
                        VStack(spacing: 8) {
                            Text(primaryInfo)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if let secondaryInfo = secondaryInfo {
                                Text(secondaryInfo)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !additionalChips.isEmpty {
                                HStack(spacing: 12) {
                                    ForEach(additionalChips, id: \.title) { chip in
                                        Label(chip.value, systemImage: chip.icon)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.secondarySystemBackground))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

                HStack(spacing: 12) {
                    Button(action: onDone) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    if let onBackToList = onBackToList {
                        Button(action: { 
                            onDone()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                onBackToList()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.uturn.left.circle")
                                Text("Back to List")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.12))
                            .cornerRadius(12)
                        }
                    }
                }

                Spacer(minLength: 12)
            }
            .padding()
            .navigationTitle("Great Job!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CompletionChip {
    let title: String
    let value: String
    let icon: String
}
