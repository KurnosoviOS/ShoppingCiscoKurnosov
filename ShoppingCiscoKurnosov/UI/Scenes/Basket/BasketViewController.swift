//
//  BasketViewController.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 27.03.2022.
//

import UIKit

class BasketViewController:
    UIViewController,
    BasketCollectionView,
    UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var checkoutButton: UIButton?
    
    var presenter: CategoriesPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let presenter = presenter,
            let collectionView = collectionView,
            let checkoutButton = checkoutButton
        else {
            return
        }
        
        checkoutButton.backgroundColor = .blue
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.addTarget(self, action: #selector(checkoutButtonClick), for: .touchUpInside)
        
        preferredContentSize = .init(
            width: width,
            height: 200
        )
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = .init(
            width: itemSide,
            height: itemSide
        )
        
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = .init(
            top: margin,
            left: margin,
            bottom: margin,
            right: margin
        )
        
        collectionView.layer.cornerRadius = 20
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.register(
            UINib(nibName: "ItemCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: ItemCollectionViewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        
        presenter.basketCollectionView = self
        presenter.requestBasketItems()
    }
    
    @objc func checkoutButtonClick() {
        presenter?.sendCheckout()
    }
    
    // MARK: - BasketCollectionView
    
    func updateCategoryItems(_ items: [(Item, Category)]) {
        DispatchQueue.global(qos: .utility).async {
            self.categoryItems = items.sorted { $0.0.name < $1.0.name }
            
            let rowsCount = items.count / 2 + items.count % 2
            
            let height = CGFloat(rowsCount) * (self.itemSide + self.margin) + 70
            
            DispatchQueue.main.async {
                self.preferredContentSize = .init(
                    width: self.width,
                    height: height
                )
                
                self.collectionView?.reloadData()
            }
        }
    }
    
    private var categoryItems: [(Item, Category)] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        
        return categoryItems.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ItemCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        
        cell.backgroundColor = categoryItems[indexPath.row].1.color
        
        if let itemCell = cell as? ItemCollectionViewCell {
            itemCell.nameLabel?.text = categoryItems[indexPath.row].0.name
        }
        
        return cell
    }
    
    private lazy var width: CGFloat = .screenWidth - 100
    
    private lazy var itemSide = width * 0.4
    private lazy var margin = width * 0.05
}

