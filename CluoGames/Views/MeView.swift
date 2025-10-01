//
//  MeView.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import SwiftUI

struct MeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("Profile coming soon")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Me")
        }
    }
}

#Preview {
    MeView()
}


