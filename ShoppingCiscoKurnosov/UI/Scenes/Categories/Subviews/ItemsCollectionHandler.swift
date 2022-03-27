//
//  ItemsCollectionHandler.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 27.03.2022.
//

import UIKit

/// Configuring items for itemCollectionView
class ItemsCollectionHandler:
    NSObject,
    UICollectionViewDataSource,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate {
    
    var items: [Item] = []
    var color: UIColor = .white
    weak var prepareDropTargetDelegate: PrepareDropTargetDelegate?
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(
            UINib(nibName: "ItemCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: ItemCollectionViewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = .init(width: .itemCellSize, height: .itemCellSize)
        layout.minimumInteritemSpacing = .itemCellMargin
        layout.sectionInset = .init(
            top: .itemCellMargin,
            left: .itemCellMargin,
            bottom: .itemCellMargin,
            right: .itemCellMargin
        )
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        
        return items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ItemCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        
        cell.backgroundColor = color
        
        if let itemCell = cell as? ItemCollectionViewCell {
            itemCell.nameLabel?.text = items[indexPath.row].name
        }
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let item = items[indexPath.row]
        
        let provider = NSItemProvider(object: item.name as NSString)
        
        let drag = UIDragItem(itemProvider: provider)
        drag.localObject = item
        
        return [drag]
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dragSessionWillBegin session: UIDragSession
    ) {
        prepareDropTargetDelegate?.setPreparedForDropEnabled(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        prepareDropTargetDelegate?.setPreparedForDropEnabled(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
    }
}

private extension CGFloat {
    static let itemCellSize = screenWidth * 0.4
    static let itemCellMargin = screenWidth * 0.05
}
