//
//  SearchTabView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI

struct SearchTabView: View {
    @State private var query: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView("검색결과가 없습니다.", systemImage: "film")
            }
            .navigationTitle("Movie Search")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "영화 검색")
        .submitLabel(.search)
        .onSubmit(of: .search) {
            
        }
    }
}
