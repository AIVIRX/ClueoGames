//
//  SettingsView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI
import StoreKit
import RevenueCatUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var hapticsEnabled = true
    @State private var darkModeEnabled = false
    @StateObject private var purchases = PurchasesService.shared
    @State private var showManageSubscriptionSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // Subscription status
                Section("Subscription") {
                    HStack {
                        Image(systemName: purchases.hasPremium ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundColor(purchases.hasPremium ? .green : .red)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(purchases.hasPremium ? "Clueo Games+ – Active" : "Clueo Games+ – Inactive")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Button("Manage") {
                            showManageSubscriptionSheet = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                // App Settings Section
                Section("Preferences") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Toggle("Notifications", isOn: $notificationsEnabled)
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
                

                
                // Support Section
                Section("Support") {
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
                
                // Version Section
                Section {
                    HStack {
                        Spacer()
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                // Legal Section
                Section("Legal") {
                    Button {
                        if let url = URL(string: "https://www.aivirx.com/clueogames/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
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
                        if let url = URL(string: "https://www.aivirx.com/clueogames/terms-of-service") {
                            UIApplication.shared.open(url)
                        }
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
            .navigationBarTitleDisplayMode(.inline)
        }
        // Removed auto-presenting paywall for a calmer UX
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptionSheet)
    }
}

// MARK: - Supporting Views

// AboutView removed - version now shown at bottom of settings

// PrivacyView and TermsView removed - now using Safari links
#Preview {
    SettingsView()
}
