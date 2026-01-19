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
    
    var favoritesVersion: Int
    
    var isReorderEnable: Bool = false
    var onMove:((Int, Int) -> Void)? = nil
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = Self.makeLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        cv.delegate = context.coordinator
        
        context.coordinator.configureDataSource(collectionView: cv)
        
        let longPress = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        cv.addGestureRecognizer(longPress)
        cv.dragInteractionEnabled = isReorderEnable
        cv.dragDelegate = context.coordinator
        cv.dropDelegate = context.coordinator
        return cv
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.applySnapshot(items: items, animating: true)
        
        if context.coordinator.lastScrollToTopTrigger != scrollToTopTrigger {
            context.coordinator.lastScrollToTopTrigger = scrollToTopTrigger
            uiView.setContentOffset(.zero, animated: true)
        }
        
        if context.coordinator.lastFavoritesVersion != favoritesVersion {
            context.coordinator.lastFavoritesVersion = favoritesVersion
            
            context.coordinator.reloadAllVisibleItems()
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
    
    final class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
        var parent: MovieCollectionView
        private var dataSource: UICollectionViewDiffableDataSource<Int, MovieItem>?
        private var currentItems: [MovieItem] = []
        var lastScrollToTopTrigger: Int = 0
        var lastFavoritesVersion: Int = 0
        
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
        
        func reloadAllVisibleItems() {
            guard let dataSource else { return }
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems(snapshot.itemIdentifiers)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard parent.isReorderEnable else { return }
            guard let cv = gesture.view as? UICollectionView else { return }
            
            let location = gesture.location(in: cv)
            
            switch gesture.state {
            case .began:
                guard let indexPath = cv.indexPathForItem(at: location) else { return }
                cv.beginInteractiveMovementForItem(at: indexPath)
                
            case .changed:
                cv.updateInteractiveMovementTargetPosition(location)
                
            case .ended:
                cv.endInteractiveMovement()
                
            default:
                cv.cancelInteractiveMovement()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            guard parent.isReorderEnable else { return [] }
            let item = currentItems[indexPath.item]
            let provider = NSItemProvider(object: item.imdbID as NSString)
            let dragItem = UIDragItem(itemProvider: provider)
            dragItem.localObject = item.imdbID
            return [dragItem]
        }
        
        func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
            guard parent.isReorderEnable else { return }
            guard coordinator.proposal.operation == .move else { return }
            
            guard let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath else { return }
            
            let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: max(0, currentItems.count - 1), section: 0)
            
            collectionView.performBatchUpdates({
                parent.onMove?(sourceIndexPath.item, destinationIndexPath.item)
            }, completion: nil)
        }
        
        func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
            guard parent.isReorderEnable else {
                return UICollectionViewDropProposal(operation: .forbidden)
            }
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    }
}
