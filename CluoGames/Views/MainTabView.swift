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
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }
            MeView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Me")
                }
        }
    }
}

#Preview {
    MainTabView()
}


