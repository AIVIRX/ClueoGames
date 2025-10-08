//
//  HomeView.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import SwiftUI
import StoreKit

struct HomeView: View {
    @StateObject private var purchases = PurchasesService.shared
    @State private var showingGame = false
    @State private var showPaywall = false
    @State private var goPastSudoku = false
    @State private var goPastUnscramble = false
    @State private var goPastExacto = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 5) {
                    welcomeHeader
                        .padding(.bottom)
                    
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
                    
                    Button {
                        if purchases.hasPremium {
                            goPastSudoku = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        SmallActionButtonView(title: "Past Sudoku", systemImage: "archivebox.fill", color: .yellow)
                    }
                    .padding(.bottom)
                                        
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
                    
                    Button {
                        if purchases.hasPremium {
                            goPastUnscramble = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        SmallActionButtonView(title: "Past Unscramble", systemImage: "archivebox.fill", color: .blue)
                    }
                    .padding(.bottom)
                    
                    NavigationLink {
                        ExactoModeSelectionView()
                    } label: {
                        GameHeroCard(
                            title: "Exacto",
                            subtitle: "Use two numbers and multiplication to match the target",
                            dateText: "Today",
                            icon: "equal.circle.fill",
                            tint: Color(.systemPink),
                            isLocked: false,
                            height: 200
                        )
                    }
                    
                    Button {
                        if purchases.hasPremium {
                            goPastExacto = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        SmallActionButtonView(title: "Past Exacto", systemImage: "archivebox.fill", color: .pink)
                    }
                    .padding(.bottom)

                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $goPastSudoku) { PastSudokuView() }
            .navigationDestination(isPresented: $goPastUnscramble) { PastUnscrambleView() }
            .navigationDestination(isPresented: $goPastExacto) { PastExactoView() }
        }
        .fullScreenCover(isPresented: $showPaywall) { CustomPaywallView() }
    }
    
    private var welcomeHeader: some View {
        VStack(alignment: .center, spacing: 12) {
            if purchases.hasPremium {
                // Content for subscribed users
                Text("Hey there")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("Play a puzzle to keep your mind working")
                    .foregroundColor(.secondary)
            } else {
                // Content for non-subscribed users
                Text("Play with no ads and access past puzzles")
                    .foregroundColor(.secondary)
                Button(action: { showPaywall = true }) {
                    Text("Subscribe to Clueo Games+")
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
                .offset(y: 6)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .offset(y: 4)
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
    let statusText: String?
    let icon: String
    let tint: Color
    let isLocked: Bool
    var height: CGFloat? = nil
    
    init(title: String, subtitle: String, dateText: String?, statusText: String? = nil, icon: String, tint: Color, isLocked: Bool, height: CGFloat? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.dateText = dateText
        self.statusText = statusText
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
                    HStack {
                        Text(dateText)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.black)
                        Spacer()
                        if let statusText, !statusText.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.black)
                                Text(statusText)
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.black)
                            }
                        }
                    }
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
}

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

