//
//  MainTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            SearchTabView()
                .tabItem {
                    Label("검색", systemImage: "magnifyingglass")
                }
            
            FavoritesTabView()
                .tabItem {
                    Label("즐겨찾기", systemImage: "star.fill")
                }
        }
    }
}
