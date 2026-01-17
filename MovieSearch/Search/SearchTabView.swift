//
//  SearchTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct SearchTabView: View {
    @StateObject private var viewModel = SearchTabViewModel()
    @State private var favorites: Set<String> = []
    @State private var selectedMovie: MovieItem?
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
                        isFavorite: { favorites.contains($0) },
                        onSelect: { movie in
                            self.selectedMovie = movie
                        },
                        onReachedBottom: {
                            Task {
                                await self.viewModel.loadNextPageIfNeeded()
                            }
                        },
                        scrollToTopTrigger: scrollToTopTrigger
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
    }
}
