//
//  FavoritesTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct FavoritesTabView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView("즐겨찾기한 영화가 없습니다.", systemImage: "star")
            }
            .navigationTitle("내 즐겨찾기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
