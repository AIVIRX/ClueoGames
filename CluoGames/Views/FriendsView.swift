//
//  FriendsView.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var gc = GameCenterService.shared
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCard
                    actionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Game Center")
            .task {
                await gc.authenticate()
            }
        }
    }
}

#Preview {
    FriendsView()
}

// MARK: - Sections
extension FriendsView {
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: gc.isAuthenticated ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .foregroundColor(gc.isAuthenticated ? .green : .red)
                Text(gc.isAuthenticated ? "Signed in as \(gc.playerAlias)" : "Not signed in to Game Center")
                    .fontWeight(.semibold)
            }
            Text("Game Center lets you compare scores with friends and track achievements.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                gc.presentDashboard()
            } label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                    Text("Dashboard")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            Button {
                gc.presentLeaderboards()
            } label: {
                HStack {
                    Image(systemName: "rosette")
                    Text("Leaderboards")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            Button {
                gc.presentAchievements()
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Achievements")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}


