//
//  SearchTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct SearchTabView: View {
    @ObservedObject var favoritesViewModel: FavoritesTabViewModel
    @StateObject private var viewModel = SearchTabViewModel()
    @State private var selectedMovie: MovieItem?
    @State private var showAlert = false
    
    @State private var query: String = ""
    @State private var scrollToTopTrigger: Int = 0
    @FocusState private var isSearchFocused: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.items.isEmpty {
                    ContentUnavailableView("검색결과가 없습니다.", systemImage: "film.circle")
                } else {
                    MovieCollectionView(
                        items: viewModel.items,
                        isFavorite: { favoritesViewModel.isFavorite($0) },
                        onSelect: { movie in
                            self.selectedMovie = movie
                            self.showAlert = true
                        },
                        onReachedBottom: {
                            Task {
                                await self.viewModel.loadNextPageIfNeeded()
                            }
                        },
                        scrollToTopTrigger: scrollToTopTrigger,
                        favoritesVersion: favoritesViewModel.version
                    )
                }
            }
            .navigationTitle("Movie Search")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "영화 검색")
        .focused($isSearchFocused)
        .submitLabel(.search)
        .onSubmit(of: .search) {
            isSearchFocused = false
            Task {
                await viewModel.search(query: query)
                scrollToTopTrigger &+= 1
            }
        }
        .onChange(of: query) { _, newValue in
            if newValue.isEmpty {
                isSearchFocused = false
                viewModel.resetSearch()
                scrollToTopTrigger &+= 1
            }
        }
        .alert(
            "\(selectedMovie?.title ?? "") (\(selectedMovie?.year ?? ""))",
            isPresented: $showAlert
        ) {
            Button("취소", role: .cancel) {
                selectedMovie = nil
            }
            
            if let movie = selectedMovie {
                if favoritesViewModel.isFavorite(movie.imdbID) {
                    Button("즐겨찾기 제거", role: .destructive) {
                        favoritesViewModel.toggle(movie)
                        selectedMovie = nil
                    }
                } else {
                    Button("즐겨찾기") {
                        favoritesViewModel.toggle(movie)
                        selectedMovie = nil
                    }
                }
            }
        }
    }
}
