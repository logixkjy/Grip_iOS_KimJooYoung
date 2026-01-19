//
//  FavoritesTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct FavoritesTabView: View {
    @ObservedObject var viewModel: FavoritesTabViewModel
    @State private var selectedMovie: MovieItem?
    @State private var showAlert = false
    @State private var favoritesVersion: Int = 0
    
    @State private var scrollToTopTrigger: Int = 0
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.favorites.isEmpty {
                    ContentUnavailableView("즐겨찾기한 영화가 없습니다.", systemImage: "star")
                } else {
                    MovieCollectionView(
                        items: viewModel.favorites,
                        isFavorite: { viewModel.isFavorite($0) },
                        onSelect: { movie in
                            self.selectedMovie = movie
                            self.showAlert = true
                        },
                        scrollToTopTrigger: scrollToTopTrigger,
                        favoritesVersion: viewModel.version,
                        isReorderEnable: true) { from, to in
                            viewModel.move(from, to)
                        }
                }
            }
            .navigationTitle("내 즐겨찾기")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(
            "\(selectedMovie?.title ?? "") (\(selectedMovie?.year ?? ""))",
            isPresented: $showAlert
        ) {
            Button("취소", role: .cancel) { 
                selectedMovie = nil
            }
            
            if let movie = selectedMovie {
                if viewModel.isFavorite(movie.imdbID) {
                    Button("즐겨찾기 제거", role: .destructive) {
                        viewModel.toggle(movie)
                        selectedMovie = nil
                    }
                } else {
                    Button("즐겨찾기") {
                        viewModel.toggle(movie)
                        selectedMovie = nil
                    }
                }
            }
        }
    }
}
