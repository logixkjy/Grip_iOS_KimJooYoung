//
//  MovieItem.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

struct MovieItem: Hashable, Sendable, Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String?
}
