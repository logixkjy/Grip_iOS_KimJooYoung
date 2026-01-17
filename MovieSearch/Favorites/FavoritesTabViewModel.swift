//
//  FavoritesTabViewModel.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/17/26.
//

import Foundation
import Combine

@MainActor
final class FavoritesTabViewModel: ObservableObject {
    @Published private(set) var favorites: [MovieItem] = []
    private var favoritesIDs: Set<String> = []
    @Published private(set) var version: Int = 0
    
    func isFavorite(_ id: String) -> Bool {
        favoritesIDs.contains(id)
    }
    
    func add(_ item: MovieItem) {
        guard favoritesIDs.insert(item.imdbID).inserted else { return }
        favorites.append(item)
        version &+= 1
    }
    
    func remove(id: String) {
        guard favoritesIDs.remove(id) != nil else { return }
        favorites.removeAll { $0.imdbID == id }
        version &+= 1
    }
    
    func toggle(_ item: MovieItem) {
        if isFavorite(item.imdbID) {
            remove(id: item.imdbID)
        } else {
            add(item)
        }
    }
}
