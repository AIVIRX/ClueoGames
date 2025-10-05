//
//  PaywallView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct CustomPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchases = PurchasesService.shared
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            if let offerings = purchases.offerings, let currentOffering = offerings.current {
                PaywallView(offering: currentOffering)
                    .onPurchaseCompleted { customerInfo in
                        // Handle successful purchase
                        dismiss()
                    }
                    .onPurchaseFailure { error in
                        // Handle purchase failure
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                    .onRestoreCompleted { customerInfo in
                        // Handle successful restore
                        dismiss()
                    }
                    .onRestoreFailure { error in
                        // Handle restore failure
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                    .onPurchaseCancelled {
                        // Handle purchase cancellation
                        dismiss()
                    }
            } else {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading subscription...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Refresh offerings when paywall appears
            Task {
                await purchases.loadOfferings()
            }
        }
    }
}

#Preview {
    CustomPaywallView()
}
