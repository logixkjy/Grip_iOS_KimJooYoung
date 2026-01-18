//
//  FavoritesTabViewModel.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/17/26.
//

import Foundation
import Combine

struct FavoritesContainer: Codable {
    var favorites: [MovieItem]
}

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
        save()
    }
    
    func load() {
        let url = fileURL()
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            favorites = []
            favoritesIDs = []
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decode = try JSONDecoder().decode(FavoritesContainer.self, from: data)
            
            var seen = Set<String>()
            var cleaned: [MovieItem] = []
            for m in decode.favorites {
                if seen.insert(m.imdbID).inserted {
                    cleaned.append(m)
                }
            }
            
            favorites = cleaned
            favoritesIDs = Set(cleaned.map(\.imdbID))
            version &+= 1
        } catch {
            favorites = []
            favoritesIDs = []
        }
    }
    
    func save() {
        let url = fileURL()
        
        do {
            let container = FavoritesContainer(favorites: favorites)
            let data = try JSONEncoder().encode(container)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("error \(error.localizedDescription)")
        }
    }
    
    
    
    private func fileURL() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? fm.createDirectory(at: base, withIntermediateDirectories: true)

        return base.appendingPathComponent("favorites.json")
    }
}
