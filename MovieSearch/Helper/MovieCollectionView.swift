//
//  MovieCollectionView.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import SwiftUI
import UIKit

struct MovieCollectionView: UIViewRepresentable {
    typealias UIViewType = UICollectionView
    
    var items: [MovieItem]
    
    var isFavorite: (String) -> Bool
    
    var onSelect: (MovieItem) -> Void
    
    var onReachedBottom: (() -> Void)?
    
    var scrollToTopTrigger: Int
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = Self.makeLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        cv.delegate = context.coordinator
        
        context.coordinator.configureDataSource(collectionView: cv)
        
        return cv
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.applySnapshot(items: items, animating: true)
        
        if context.coordinator.lastScrollToTopTrigger != scrollToTopTrigger {
            context.coordinator.lastScrollToTopTrigger = scrollToTopTrigger
            uiView.setContentOffset(.zero, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    static func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(360)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    final class Coordinator: NSObject, UICollectionViewDelegate {
        var parent: MovieCollectionView
        private var dataSource: UICollectionViewDiffableDataSource<Int, MovieItem>?
        private var currentItems: [MovieItem] = []
        var lastScrollToTopTrigger: Int = 0
        
        init(parent: MovieCollectionView) {
            self.parent = parent
        }
        
        func configureDataSource(collectionView: UICollectionView) {
            dataSource = UICollectionViewDiffableDataSource<Int, MovieItem>(
                collectionView: collectionView
            ) { [weak self] cv, indexPath, item in
                guard
                    let cell = cv.dequeueReusableCell(
                        withReuseIdentifier: MovieCell.identifier,
                        for: indexPath
                    ) as? MovieCell,
                    let self
                else { return UICollectionViewCell() }
                
                cell.setupData(
                    item: item,
                    isFavorite: self.parent.isFavorite(item.imdbID)
                )
                return cell
            }
        }
        
        func applySnapshot(items: [MovieItem], animating: Bool) {
            currentItems = items
            var snapshot = NSDiffableDataSourceSnapshot<Int, MovieItem>()
            snapshot.appendSections([0])
            snapshot.appendItems(items, toSection: 0)
            dataSource?.apply(snapshot, animatingDifferences: animating)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard indexPath.item < currentItems.count else { return }
            parent.onSelect(currentItems[indexPath.item])
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            willDisplay cell: UICollectionViewCell,
            forItemAt indexPath: IndexPath
        ) {
            guard let onReachedBottom = parent.onReachedBottom else { return }
            
            if indexPath.item >= max(0, currentItems.count - 4) {
                onReachedBottom()
            }
        }
    }
}
