//
//  CombinedProfileView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI

struct CombinedProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Me") {
                    NavigationLink { MeView() } label: {
                        HStack {
                            Image(systemName: "person.crop.circle").foregroundColor(.blue)
                            Text("My Profile")
                        }
                    }
                }
                Section("Settings") {
                    NavigationLink { SettingsView() } label: {
                        HStack {
                            Image(systemName: "gearshape.fill").foregroundColor(.blue)
                            Text("Settings")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    CombinedProfileView()
}


