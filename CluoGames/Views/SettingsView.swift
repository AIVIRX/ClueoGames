//
//  SettingsView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var hapticsEnabled = true
    @State private var darkModeEnabled = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingTerms = false
    
    var body: some View {
        NavigationStack {
            List {
                // App Settings Section
                Section("Preferences") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Toggle("Notifications", isOn: $notificationsEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Toggle("Sound Effects", isOn: $soundEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Toggle("Dark Mode", isOn: $darkModeEnabled)
                    }
                }
                
                // Game Settings Section
                Section("Game Settings") {
                    NavigationLink {
                        Text("Difficulty Settings")
                            .navigationTitle("Difficulty")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Default Difficulty")
                            Spacer()
                            Text("Medium")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        Text("Game Preferences")
                            .navigationTitle("Game Preferences")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Game Preferences")
                        }
                    }
                }
                
                // Account Section
                Section("Account") {
                    NavigationLink {
                        Text("Profile Settings")
                            .navigationTitle("Profile")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Profile")
                        }
                    }
                    
                    Button {
                        // Handle subscription
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            Text("Manage Subscription")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Support Section
                Section("Support") {
                    Button {
                        showingAbout = true
                    } label: {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("About")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button {
                        // Handle feedback
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Send Feedback")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button {
                        // Handle help
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Help & FAQ")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Legal Section
                Section("Legal") {
                    Button {
                        showingPrivacy = true
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button {
                        showingTerms = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $showingTerms) {
            TermsView()
        }
    }
}

// MARK: - Supporting Views

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("CluoGames")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("A collection of puzzle games including Sudoku, Exacto, and Connections. Play daily puzzles and challenge yourself with different difficulty levels.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Last updated: October 1, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Your privacy is important to us. This app does not collect personal information or share data with third parties. All game progress is stored locally on your device.")
                        .font(.body)
                    
                    Text("Data Collection")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("We do not collect, store, or transmit any personal information. All game data remains on your device.")
                        .font(.body)
                    
                    Text("Contact")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("If you have any questions about this privacy policy, please contact us through the app's feedback feature.")
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Last updated: October 1, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("By using CluoGames, you agree to these terms of service.")
                        .font(.body)
                    
                    Text("Use of the App")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("This app is provided for entertainment purposes. You may not use the app for any illegal or unauthorized purpose.")
                        .font(.body)
                    
                    Text("Intellectual Property")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("All content and features of the app are owned by CluoGames and are protected by copyright laws.")
                        .font(.body)
                    
                    Text("Limitation of Liability")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("CluoGames shall not be liable for any damages arising from the use of this app.")
                        .font(.body)
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
