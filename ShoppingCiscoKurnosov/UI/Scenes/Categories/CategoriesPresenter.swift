//
//  CategoriesPresenter.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

protocol CategoriesView: AnyObject {
    func showCategories(list: [Category])
    func showItems(list: [Item], color: UIColor)
    func setSelectedCategory(selectedNumber: Int)
    func showBasketBagdeNumber(_ number: Int)
}

class CategoriesPresenter {
    private weak var view: CategoriesView?
    private let service: CategoriesService
    
    var selectedPage = 0
    var categories: [Category] = []
    var itemsInBasket: [Item] = []
    
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
        itemsInBasket.append(item)
        view?.showBasketBagdeNumber(itemsInBasket.count)
    }
    
    // MARK: - private funcs
    
    private func showPage() {
        let category = categories[selectedPage]
        
        view?.showItems(list: category.items + category.items + category.items, color: category.color)
    }
    
    private func showCategories() {
        view?.showCategories(list: categories)
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
}
