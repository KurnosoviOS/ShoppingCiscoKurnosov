//
//  Persistence.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 28.03.2022.
//

import Foundation
import CoreData

protocol PersistenceServiceProtocol {
    func addItem(_ item: CategoryItem)
    func loadItems(loaded: @escaping ([CategoryItem]) -> Void)
    func clearItems()
}

// TODO: handle errors
class CoreDataService: PersistenceServiceProtocol {
    func addItem(_ item: CategoryItem) {
        DispatchQueue.global(qos: .utility).async {
            let context = self.persistentContainer.viewContext
            
            let managedItem = ItemManaged(context: context)
            managedItem.name = item.item.name
            managedItem.categoryName = item.category.name
            managedItem.categoryColor = item.category.colour
            
            do {
                try context.save()
            }
            catch let error {
                // TODO: handle errors
            }
        }
    }
    
    func loadItems(loaded: @escaping ([CategoryItem]) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let context = self.persistentContainer.viewContext
            let request = ItemManaged.fetchRequest()
            
            guard let items = try? context.fetch(request) else {
                // TODO: handle errors
                loaded([])
                return
            }
            
            let categoryItems = items.map { managed -> CategoryItem in
                let item = Item(name: managed.name ?? "")
                
                let category = CategoryTitle(
                    name: managed.categoryName ?? "",
                    colour: managed.categoryColor ?? ""
                )
                
                return CategoryItem(
                    item: item,
                    category: category
                )
            }
            
            loaded(categoryItems)
        }
    }
    
    func clearItems() {
        DispatchQueue.global(qos: .utility).async {
            let context = self.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemManaged")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch let error {
                // TODO: handle errors
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ShoppingCiscoKurnosov")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // TODO: handle errors
            }
        })
        return container
    }()
}
