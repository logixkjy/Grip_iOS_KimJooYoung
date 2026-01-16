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
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.items.isEmpty {
                    ContentUnavailableView("검색결과가 없습니다.", systemImage: "film")
                } else {
                    MovieGridCollectionView(
                        items: viewModel.items,
                        isFavorite: { favorites.contains($0) },
                        onSelect: { movie in
                            self.selectedMovie = movie
                        },
                        onReachedBottom: {
                            Task {
                                await self.viewModel.loadNextPageIfNeeded()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Movie Search")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "영화 검색")
        .submitLabel(.search)
        .onSubmit(of: .search) {
            Task { await viewModel.search(query: query) }
        }
    }
}
