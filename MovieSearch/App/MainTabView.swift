//
//  MainTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var favoritesViewModel = FavoritesTabViewModel()
    
    var body: some View {
        TabView {
            SearchTabView(favoritesViewModel: favoritesViewModel)
                .tabItem {
                    Label("검색", systemImage: "magnifyingglass")
                }
            
            FavoritesTabView(viewModel: favoritesViewModel)
                .tabItem {
                    Label("즐겨찾기", systemImage: "star.fill")
                }
        }
        .onAppear {
            favoritesViewModel.load()
        }
    }
}
