//
//  HomeView.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import SwiftUI
import StoreKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingGame = false
    @State private var showManageSubscriptionSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    welcomeHeader
                    
                    NavigationLink {
                        SudokuModeSelectionView()
                    } label: {
                        GameHeroCard(
                            title: "Sudoku",
                            subtitle: "Fill each row & column with digits 1–9 without repeats.",
                            dateText: "Today",
                            icon: "square.grid.3x3.fill",
                            tint: Color(.systemYellow),
                            isLocked: false,
                            height: 200
                        )
                    }
                    
                        NavigationLink {
                            PastSudokuView()
                        } label: {
                            SmallActionButtonView(title: "Past Sudoku", systemImage: "archivebox.fill", color: .yellow)
                        }
                                        
                    NavigationLink {
                        UnscrambleGameView()
                    } label: {
                        GameHeroCard(
                            title: "Unscramble",
                            subtitle: "Unscramble today's word in 6 tries. Quick, clever, one puzzle a day.",
                            dateText: "Today",
                            icon: "questionmark.square.fill",
                            tint: Color(.systemBlue),
                            isLocked: false,
                            height: 200
                        )
                    }
                    
                    NavigationLink {
                        PastSudokuView()
                    } label: {
                        SmallActionButtonView(title: "Past Sudoku", systemImage: "archivebox.fill", color: .yellow)
                    }
                    
                    NavigationLink {
                        ExactoModeSelectionView()
                    } label: {
                        GameHeroCard(
                            title: "Exacto",
                            subtitle: "Use six numbers and multiplication to match the target",
                            dateText: "Today",
                            icon: "equal",
                            tint: Color(.systemPink),
                            isLocked: false,
                            height: 200
                        )
                    }
                    
                        NavigationLink {
                            PastExactoView()
                        } label: {
                            SmallActionButtonView(title: "Past Exacto", systemImage: "archivebox.fill", color: .pink)
                        }
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
        .fullScreenCover(isPresented: $showingGame) {
            if let puzzle = viewModel.todaysPuzzle {
                ConnectionsGameView(puzzle: puzzle)
            }
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptionSheet)
    }
    
    private var welcomeHeader: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Play with no ads and access past puzzles")
                .foregroundColor(.secondary)
            Button(action: { showManageSubscriptionSheet = true }) {
                Text("Subscribe to Games")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(24)
            }
        }
    }
}

// MARK: - Supporting Views

struct SmallActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    var action: () -> Void
    
    init(title: String, systemImage: String, color: Color = .blue, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                // Back layers (stacked cards)
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .offset(y: 10)
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .offset(y: 5)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                // Front content card
                HStack {
                    Text(title).font(.headline)
                    Spacer()
                    Image(systemName: systemImage)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom)
    }
}

struct SmallActionButtonView: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Back layers (stacked cards)
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .offset(y: 10)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .offset(y: 5)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            // Front content card
            HStack {
                Text(title).font(.headline)
                Spacer()
                Image(systemName: systemImage)
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct GameHeroCard: View {
    let title: String
    let subtitle: String
    let dateText: String?
    let icon: String
    let tint: Color
    let isLocked: Bool
    var height: CGFloat? = nil
    
    init(title: String, subtitle: String, dateText: String?, icon: String, tint: Color, isLocked: Bool, height: CGFloat? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.dateText = dateText
        self.icon = icon
        self.tint = tint
        self.isLocked = isLocked
        self.height = height
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
        VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 34, weight: .heavy, design: .default))
                            .foregroundColor(.black)
                        Text(subtitle)
                            .foregroundColor(.black.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .outline(.black, lineWidth: 1.5)
                }
                
                if let dateText {
                    Text(dateText)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)
                }
            }
            .padding(20)
            .background(tint)
            .cornerRadius(24)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                if isLocked {
                    lockBadge
                        .padding(10)
                }
            }
        }
    }
    
    private var lockBadge: some View {
        ZStack {
            Circle().fill(Color.white)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
            Image(systemName: "lock.fill")
                .foregroundColor(.black.opacity(0.8))
        }
    }
    
    private func capsuleBadge(text: String) -> some View {
        Text(text)
            .font(.caption).bold()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.35))
            .clipShape(Capsule())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct GameModeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isAvailable: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isAvailable ? color : .gray)
                
                Spacer()
                
                if !isAvailable {
                    Text("Soon")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isAvailable ? .primary : .gray)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .opacity(isAvailable ? 1.0 : 0.6)
    }
}


// MARK: - View Utilities
extension View {
    func outline(_ color: Color, lineWidth: CGFloat) -> some View {
        let r = max(lineWidth, 0.5)
        return self
            .shadow(color: color, radius: 0, x: 0, y: r)
            .shadow(color: color, radius: 0, x: 0, y: -r)
            .shadow(color: color, radius: 0, x: r, y: 0)
            .shadow(color: color, radius: 0, x: -r, y: 0)
            .shadow(color: color, radius: 0, x: r, y: r)
            .shadow(color: color, radius: 0, x: -r, y: r)
            .shadow(color: color, radius: 0, x: r, y: -r)
            .shadow(color: color, radius: 0, x: -r, y: -r)
    }
}

