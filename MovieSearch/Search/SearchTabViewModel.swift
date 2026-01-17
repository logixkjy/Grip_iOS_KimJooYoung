//
//  SearchTabViewModel.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/17/26.
//

import Foundation
import Combine

@MainActor
final class SearchTabViewModel: ObservableObject {
    @Published private(set) var items: [MovieItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var hasNextPage = true

    private var currentQuery: String = ""
    private var nextPage: Int = 1
    private var requestToken = UUID()

    func search(query: String) async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        let token = UUID()
        requestToken = token

        isLoading = true
        isLoadingNextPage = false
        currentQuery = q
        nextPage = 1
        hasNextPage = true
        defer { isLoading = false }

        do {
            let res = try await MovieSearchAPI.searchMovie(query: q, page: nextPage)
            guard requestToken == token else { return }

            items = dedupePreservingOrder(res.items)
            nextPage += 1

            let total = Int(res.total) ?? items.count
            hasNextPage = total > items.count
        } catch {
            guard requestToken == token else { return }
            items = []
            hasNextPage = false
        }
    }

    func loadNextPageIfNeeded() async {
        guard hasNextPage, !isLoading, !isLoadingNextPage else { return }
        guard !currentQuery.isEmpty else { return }

        let token = requestToken

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let res = try await MovieSearchAPI.searchMovie(query: currentQuery, page: nextPage)
            guard requestToken == token else { return }

            let newItems = dedupePreservingOrder(res.items)
            
            let existing = Set(items.map(\.imdbID))
            let filtered = newItems.filter { !existing.contains($0.imdbID) }
            
            items.append(contentsOf: filtered)
            nextPage += 1

            let total = Int(res.total) ?? items.count
            hasNextPage = total > items.count
        } catch {

        }
    }
    
    private func dedupePreservingOrder(_ items: [MovieItem]) -> [MovieItem] {
        var seen = Set<String>()
        seen.reserveCapacity(items.count)
        var result: [MovieItem] = []
        result.reserveCapacity(items.count)
        
        for item in items {
            if seen.insert(item.imdbID).inserted {
                result.append(item)
            }
        }
        return result
    }

    func resetSearch() {
        requestToken = UUID() 
        items.removeAll()
        currentQuery = ""
        nextPage = 1
        hasNextPage = true
        isLoading = false
        isLoadingNextPage = false
    }
}
