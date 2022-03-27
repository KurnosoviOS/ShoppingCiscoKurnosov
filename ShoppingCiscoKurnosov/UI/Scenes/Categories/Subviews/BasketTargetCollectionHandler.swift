//
//  BasketTargetCollectionHandler.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 26.03.2022.
//

import UIKit

class BasketTargetCollectionHandler:
    NSObject,
    UICollectionViewDataSource,
    UICollectionViewDropDelegate,
    UICollectionViewDelegate {
    
    private let presenter: CategoriesPresenter
    private weak var collectionView: UICollectionView?
    
    init(
        presenter: CategoriesPresenter,
        collectionView: UICollectionView
    ) {
        self.presenter = presenter
        self.collectionView = collectionView
        
        super.init()
        
        configureCollectionView(collectionView)
    }
    
    private func configureCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(
            UINib(nibName: "EmptyGridCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: EmptyGridCollectionViewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dropDelegate = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = .init(width: basketSize, height: basketSize)
        layout.sectionInset = .zero
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        
        collectionView.isUserInteractionEnabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmptyGridCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        guard
            let dragItem = coordinator.items.first,
            let item = dragItem.dragItem.localObject as? Item
        else {
            return
        }
        
        presenter.addItemToBasket(item: item)
    }
    
    private var basketSize: CGFloat = 110
}
