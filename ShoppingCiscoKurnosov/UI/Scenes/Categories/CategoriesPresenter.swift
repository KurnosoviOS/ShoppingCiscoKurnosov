//
//  CategoriesPresenter.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

// TODO: This should be separated into several presenters and the models should be extracted from here
class CategoriesPresenter {
    private weak var view: CategoriesView?
    weak var basketCollectionView: BasketCollectionView?
    private let service: CategoriesService
    private let persistenceService: PersistenceService
    
    var selectedPage = 0
    var categories: [Category] = []
    var itemsInBasket: [CategoryItem] = []
    
    init(
        view: CategoriesView,
        service: CategoriesService,
        persistenceService: PersistenceService
    ) {
        self.view = view
        self.service = service
        self.persistenceService = persistenceService
    }
    
    func requestData() {
        service.loadCategories { [weak self, weak view] categories, error in
            if let error = error {
                view?.showAlert(text: error.localizedDescription, okCallback: nil)
            }
            
            self?.categories = categories.sorted { $0.name < $1.name }
            
            self?.persistenceService.loadItems(loaded: { savedItems in
                self?.itemsInBasket = savedItems
                self?.showAll()
            })
        }
    }
    
    func requestBasketItems() {
        basketCollectionView?.updateCategoryItems(itemsInBasket)
    }
    
    func showNextPage() {
        guard selectedPage < categories.count - 1 else {
            return
        }
        
        selectedPage += 1
        showPage(animation: .right)
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
    
    func showPrevPage() {
        guard selectedPage > 0 else {
            return
        }
        
        selectedPage -= 1
        showPage(animation: .left)
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
    
    func showPage(number: Int) {
        guard number >= 0, number < categories.count else {
            return
        }
        
        var animation: PagingAnimation? = nil
        
        if selectedPage > number {
            animation = .left
        }
        else if selectedPage < number {
            animation = .right
        }
        
        selectedPage = number
        showPage(animation: animation)
    }
    
    func addItemToBasket(item: Item) {
        let category = categories[selectedPage]
        
        let categoryItem = CategoryItem(item: item, category: category.title)
        itemsInBasket.append(categoryItem)
        view?.showBasketBagdeNumber(itemsInBasket.count)
        persistenceService.addItem(categoryItem)
    }
    
    func showBasket(isVisible: Bool) {
        view?.showBasket(isVisible: isVisible)
    }
    
    func sendCheckout() {
        let isSuccess = Bool.random()
        
        view?.showBasket(isVisible: false)
        
        if isSuccess {
            // TODO: do we need it?
            itemsInBasket = []
            view?.showBasketBagdeNumber(0)
            persistenceService.clearItems()
            
            view?.showAlert(text: "Order completed", timeout: 2, okCallback: nil)
        }
        else {
            view?.showAlert(text: "Something went wrong", timeout: 5, okCallback: nil)
        }
    }
    
    
    // MARK: - private funcs
    
    private func showAll() {
        showCategories()
        showPage(animation: nil)
        view?.showBasketBagdeNumber(itemsInBasket.count)
    }
    
    private func showPage(animation: PagingAnimation?) {
        let category = categories[selectedPage]
        
        DispatchQueue.global(qos: .utility).async {
            let items = category.items.sorted { $0.name < $1.name }
            
            self.view?.showItems(
                list: items,
                color: category.color,
                animation: animation
            )
        }
    }
    
    private func showCategories() {
        view?.showCategories(list: categories)
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
}

// TODO: move it to separated file(s)?
protocol CanShowAlert {
    func showAlert(text: String, okCallback: (() -> Void)?)
    func showAlert(text: String, timeout: TimeInterval, okCallback: (() -> Void)?)
}

protocol CategoriesView: AnyObject, CanShowAlert {
    func showCategories(list: [Category])
    func showItems(
        list: [Item],
        color: UIColor,
        animation: PagingAnimation?
    )
    func setSelectedCategory(selectedNumber: Int)
    func showBasketBagdeNumber(_ number: Int)
    func showBasket(isVisible: Bool)
}

protocol BasketCollectionView: AnyObject, CanShowAlert {
    func updateCategoryItems(_ items: [CategoryItem])
}

enum PagingAnimation {
    case left
    case right
}
