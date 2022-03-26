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
}

class CategoriesPresenter {
    private weak var view: CategoriesView?
    private let service: CategoriesService
    
    var selectedPage = 0
    var categories: [Category] = []
    
    init(
        view: CategoriesView,
        service: CategoriesService
    ) {
        self.view = view
        self.service = service
    }
    
    func requestData() {
        //TODO: show an error
        service.loadCategories { [weak self] categories, _ in
            self?.categories = categories.sorted { $0.name < $1.name }
            
            self?.showCategories()
            self?.showPage()
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
    
    private func showPage() {
        let category = categories[selectedPage]
        
        view?.showItems(list: category.items + category.items + category.items, color: category.color)
    }
    
    private func showCategories() {
        view?.showCategories(list: categories)
        view?.setSelectedCategory(selectedNumber: selectedPage)
    }
}
