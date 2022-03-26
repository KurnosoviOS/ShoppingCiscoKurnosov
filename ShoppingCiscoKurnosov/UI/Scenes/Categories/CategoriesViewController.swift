//
//  CategoriesViewController.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

class CategoriesViewController: UIViewController, CategoriesView {
    
    @IBOutlet weak var itemsCollectionView: UICollectionView?
    @IBOutlet weak var categoriesCollectionView: UICollectionView?
    
    var presenter: CategoriesPresenter?
    
    private var itemsCollectionHandler = ItemsCollectionHandler()
    private var categoriesCollectionHandler = CategoriesCollectionHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let itemsCollectionView = itemsCollectionView {
            itemsCollectionHandler.configureCollectionView(itemsCollectionView)
        }
        
        if let categoryCollectionView = categoriesCollectionView {
            categoriesCollectionHandler.configureCollectionView(categoryCollectionView)
            categoriesCollectionHandler.presenter = presenter
        }
        
        configureGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.requestData()
    }
    
    
    // MARK: - CategoriesView
    
    func showCategories(list: [Category]) {
        categoriesCollectionHandler.categories = list
        
        DispatchQueue.main.async {
            self.categoriesCollectionView?.reloadData()
        }
    }
    
    func showItems(list: [Item], color: UIColor) {
        itemsCollectionHandler.items = list
        itemsCollectionHandler.color = color
        
        DispatchQueue.main.async {
            self.itemsCollectionView?.reloadData()
        }
    }
    
    func setSelectedCategory(selectedNumber: Int) {
        categoriesCollectionHandler.selectedNumber = selectedNumber
    }
    
#if DEBUG
#else
#error ("todo divide into separated files")
#endif
    
    // MARK: - configure items for itemCollectionView
    
    private class ItemsCollectionHandler:
        NSObject,
        UICollectionViewDataSource,
        UICollectionViewDragDelegate,
        UICollectionViewDropDelegate {
        
        var items: [Item] = []
        var color: UIColor = .white
        
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
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        
        func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            let item = items[indexPath.row]
            
            let provider = NSItemProvider(object: item.name as NSString)
            
            let drag = UIDragItem(itemProvider: provider)
            drag.localObject = item
            
            return [drag]
        }
        
        func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        }
    }
    
    
    // MARK: - configure items for categoriesCollectionView
    
    private class CategoriesCollectionHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        
        var categories: [Category] = []
        var presenter: CategoriesPresenter?
        
        var selectedNumber = 0 {
            didSet {
                if previousSelectedNumber != selectedNumber {
                    DispatchQueue.main.async { [selectedNumber, previousSelectedNumber, collectionView] in
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
    
    
    // MARK: - swipe main screen
    
    @objc func swipeMainCollection(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            presenter?.showPrevPage()
        case .left:
            presenter?.showNextPage()
        default:
            break
        }
    }
    
    
    // MARK: - gesture recognizers
    
    func configureGestures() {
        if let itemsCollectionView = itemsCollectionView {
            let leftScrollMainHorizontal = UISwipeGestureRecognizer(
                target: self,
                action: #selector(swipeMainCollection(_:))
            )
            
            let rightScrollMainHorizontal = UISwipeGestureRecognizer(
                target: self,
                action: #selector(swipeMainCollection(_:))
            )
            
            leftScrollMainHorizontal.direction = .left
            rightScrollMainHorizontal.direction = .right
            
            itemsCollectionView.addGestureRecognizer(leftScrollMainHorizontal)
            itemsCollectionView.addGestureRecognizer(rightScrollMainHorizontal)
        }
    }
}

private extension CGFloat {
    static let itemCellSize = UIScreen.main.bounds.width * 0.4
    static let itemCellMargin = UIScreen.main.bounds.width * 0.05
    
    static let categoryCellSize: CGFloat = 120
    static let categoryCellMargin: CGFloat = 10
}

private extension UICollectionViewCell {
    func setSelected(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 3 : 0
        layer.borderColor = UIColor.green.cgColor
    }
}
