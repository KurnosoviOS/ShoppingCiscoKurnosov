//
//  CategoriesCollectionHandler.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 27.03.2022.
//

import UIKit

/// Configuring items for categoriesCollectionView
class CategoriesCollectionHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var categories: [Category] = []
    var presenter: CategoriesPresenter?
    
    var selectedNumber = 0 {
        didSet {
            if previousSelectedNumber != selectedNumber {
                DispatchQueue.main.async { [selectedNumber, previousSelectedNumber, collectionView] in
                    collectionView?.scrollToItem(
                        at: .init(row: selectedNumber, section: 0),
                        at: .centeredHorizontally,
                        animated: true
                    )
                    
                    collectionView?.reloadItems(
                        at: [
                            .init(row: previousSelectedNumber, section: 0),
                            .init(row: selectedNumber, section: 0)
                        ]
                    )
                }
                
                previousSelectedNumber = selectedNumber
            }
        }
    }
    
    private var previousSelectedNumber = 0
    private weak var collectionView: UICollectionView?
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        collectionView.register(
            UINib(nibName: "ItemCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: ItemCollectionViewCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = .init(width: .categoryCellSize, height: .categoryCellSize)
        layout.minimumInteritemSpacing = .categoryCellMargin
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = .init(
            top: .categoryCellMargin,
            left: .categoryCellMargin,
            bottom: .categoryCellMargin,
            right: .categoryCellMargin
        )
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ItemCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        
        guard
            indexPath.row < categories.count,
            let categoryCell = cell as? ItemCollectionViewCell
        else {
            return cell
        }
        
        let category = categories[indexPath.row]
        
        categoryCell.backgroundColor = category.color
        categoryCell.nameLabel?.text = category.name
        
        cell.setSelected(indexPath.row == selectedNumber)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedNumber = indexPath.row
        
        presenter?.showPage(number: indexPath.row)
    }
}

private extension CGFloat {
    static let categoryCellSize: CGFloat = 120
    static let categoryCellMargin: CGFloat = 10
}

private extension UICollectionViewCell {
    func setSelected(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 3 : 0
        layer.borderColor = UIColor.green.cgColor
    }
}
