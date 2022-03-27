//
//  CategoriesViewController.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

protocol PrepareDropTargetDelegate: AnyObject {
    func setPreparedForDropEnabled(_ enabled: Bool)
}

class CategoriesViewController: UIViewController, CategoriesView, PrepareDropTargetDelegate {
    
    @IBOutlet weak var itemsCollectionView: UICollectionView?
    @IBOutlet weak var categoriesCollectionView: UICollectionView?
    @IBOutlet weak var basketButtonCollectionView: UICollectionView?
    @IBOutlet weak var basketButton: UIButton?
    @IBOutlet weak var basketBadgeLabel: UILabel?
    
    @IBOutlet weak var basketYOffset: NSLayoutConstraint?
    @IBOutlet weak var basketXOffset: NSLayoutConstraint?
    
    var presenter: CategoriesPresenter?
    
    private let itemsCollectionHandler = ItemsCollectionHandler()
    private let categoriesCollectionHandler = CategoriesCollectionHandler()
    private let basketCollectionHandler = BasketCollectionHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
#if DEBUG
#else
#error ("todo handler")
#endif
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragBasket(_:)))
        basketButton?.addGestureRecognizer(panGesture)
        basketBadgeLabel?.layer.cornerRadius = 10
        basketBadgeLabel?.clipsToBounds = true
        
        if let itemsCollectionView = itemsCollectionView {
            itemsCollectionHandler.configureCollectionView(itemsCollectionView)
            itemsCollectionHandler.prepareDropTargetDelegate = self
        }
        
        if let categoryCollectionView = categoriesCollectionView {
            categoriesCollectionHandler.configureCollectionView(categoryCollectionView)
            categoriesCollectionHandler.presenter = presenter
        }
        
        if let basketButtonCollectionView = basketButtonCollectionView {
            basketCollectionHandler.configureCollectionView(basketButtonCollectionView)
            basketCollectionHandler.presenter = presenter
        }
        
        configureGestures()
    }
    
    @objc func dragBasket(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        
        guard sender.state != .ended
            && sender.state != .cancelled
            && sender.state != .failed
        else {
            alignBasket()
            return
        }
        
        basketXOffset?.constant -= translation.x
        basketYOffset?.constant -= translation.y
        
        sender.setTranslation(CGPoint.zero, in: view)
#if DEBUG
#else
#error ("todo remove")
#endif
        /*
        viewDrag.center = CGPoint(x: viewDrag.center.x + translation.x, y: viewDrag.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
         */
    }
    
    private func alignBasket() {
        guard let basketButton = basketButton else {
            return
        }
        
        if basketButton.center.x < UIScreen.main.bounds.width / 2 {
            basketXOffset?.constant = UIScreen.main.bounds.width - basketButton.frame.width - 15
        }
        else {
            basketXOffset?.constant = 15
        }
        
        if basketButton.center.y < UIScreen.main.bounds.height / 2 {
            basketYOffset?.constant = UIScreen.main.bounds.height
                - basketButton.frame.height
                - view.safeAreaInsets.top
                - 30
        }
        else {
            basketYOffset?.constant = 15
        }
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
    
    func showBasketBagdeNumber(_ number: Int) {
        DispatchQueue.main.async {
            self.basketBadgeLabel?.isHidden = (number <= 0)
            
            self.basketBadgeLabel?.text = "\(number)"
        }
    }
    
    
    // MARK: - PrepareDropTargetDelegate
    
    func setPreparedForDropEnabled(_ enabled: Bool) {
        basketButtonCollectionView?.isUserInteractionEnabled = enabled
        basketButton?.isUserInteractionEnabled = !enabled
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
        
        func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
            prepareDropTargetDelegate?.setPreparedForDropEnabled(true)
        }
        
        func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
            prepareDropTargetDelegate?.setPreparedForDropEnabled(false)
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

extension UICollectionViewCell {
    func setSelected(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 3 : 0
        layer.borderColor = UIColor.green.cgColor
    }
}
