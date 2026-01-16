//
//  MovieSearchAPI.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/17/26.
//

import Foundation

struct MovieSearchAPI {
    struct ResponseDTO: Decodable {
        let response: String
        let totalResults: String?
        let search: [MovieDTO]?
        
        enum CodingKeys: String, CodingKey {
            case response = "Response"
            case totalResults = "totalResults"
            case search = "Search"
        }
    }
    
    struct MovieDTO: Decodable {
        let imdbID: String
        let title: String
        let year: String
        let type: String
        let poster: String?
        
        enum CodingKeys: String, CodingKey {
            case imdbID
            case title = "Title"
            case year = "Year"
            case type = "Type"
            case poster = "Poster"
        }
    }
    
    enum APIError: Error {
        case invalidURL
        case invalidResponce
        case httpStatus(Int)
        case decodingFailed
    }
    
    static func searchMovie(
        query: String,
        page: Int
    ) async throws -> (items: [MovieItem], total: String) {
       
        var comps = URLComponents(string: "https://www.omdbapi.com/")
        let query: [URLQueryItem] = [
            .init(name: "apikey", value: "92e32667"),
            .init(name: "s", value: query),
            .init(name: "page", value: String(page))
        ]
        
        comps?.queryItems = query
        
        guard let url = comps?.url else {
            throw APIError.invalidURL
        }
        
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse else {
            throw APIError.invalidResponce
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        
        let decode: ResponseDTO
        do {
            decode = try JSONDecoder().decode(ResponseDTO.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
        
        guard let search = decode.search else {
            throw APIError.decodingFailed
        }
                
        let mapped: [MovieItem] = search.map { u in
            return MovieItem(
                title: u.title,
                year: u.year,
                imdbID: u.imdbID,
                type: u.type,
                poster: u.poster
            )
        }
        
        return (mapped, decode.totalResults ?? "0")
    }
}
