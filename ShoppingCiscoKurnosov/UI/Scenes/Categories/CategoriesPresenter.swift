//
//  CategoriesPresenter.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

protocol CanShowAlert {
    func showAlert(text: String, okCallback: (() -> Void)?)
}

protocol CategoriesView: AnyObject, CanShowAlert {
    func showCategories(list: [Category])
    func showItems(list: [Item], color: UIColor)
    func setSelectedCategory(selectedNumber: Int)
    func showBasketBagdeNumber(_ number: Int)
    func showBasket(isVisible: Bool)
}

protocol BasketCollectionView: AnyObject, CanShowAlert {
    func updateCategoryItems(_ items: [(Item, Category)])
}

// TODO: This should be separated into several presenters and the models should be extracted from here
class CategoriesPresenter {
    private weak var view: CategoriesView?
    weak var basketCollectionView: BasketCollectionView?
    private let service: CategoriesService
    
    var selectedPage = 0
    var categories: [Category] = []
    var itemsInBasket: [(Item, Category)] = []
    
    init(
        view: CategoriesView,
        service: CategoriesService
    ) {
        self.view = view
        self.service = service
    }
    
    func requestData() {
        //TODO: show an error
        service.loadCategories { [weak self, weak view] categories, _ in
            self?.categories = categories.sorted { $0.name < $1.name }
            
            self?.showCategories()
            self?.showPage()
            view?.showBasketBagdeNumber(0)
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
        showPage()
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
    
    func showPrevPage() {
        guard selectedPage > 0 else {
            return
        }
        
        selectedPage -= 1
        showPage()
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
    
    func showPage(number: Int) {
        guard number >= 0, number < categories.count else {
            return
        }
        
        selectedPage = number
        showPage()
    }
    
    func addItemToBasket(item: Item) {
        let category = categories[selectedPage]
        
        itemsInBasket.append((item, category))
        view?.showBasketBagdeNumber(itemsInBasket.count)
    }
    
    func showBasket(isVisible: Bool) {
        view?.showBasket(isVisible: isVisible)
    }
    
    func sendCheckout() {
        basketCollectionView?.showAlert(text: "Successfully saved!") {
            self.view?.showBasket(isVisible: false)
            
            // TODO: do we need it?
            self.itemsInBasket = []
            self.view?.showBasketBagdeNumber(0)
        }
    }
    
    
    // MARK: - private funcs
    
    private func showPage() {
        let category = categories[selectedPage]
        
        DispatchQueue.global(qos: .utility).async {
            let items = category.items.sorted { $0.name < $1.name }
            
            self.view?.showItems(list: items, color: category.color)
        }
    }
    
    private func showCategories() {
        view?.showCategories(list: categories)
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
}
