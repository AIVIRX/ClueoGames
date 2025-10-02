//
//  MainTabView.swift
//  CluoGames
//
//  Created by Assistant on 9/29/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Games")
                }
            CombinedProfileView()
                .tabItem {
                    Image(systemName: "person.3.sequence.fill")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    MainTabView()
}


