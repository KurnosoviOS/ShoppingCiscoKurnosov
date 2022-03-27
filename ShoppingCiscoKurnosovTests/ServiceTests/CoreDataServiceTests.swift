//
//  CoreDataServiceTests.swift
//  ShoppingCiscoKurnosovTests
//
//  Created by Алексей Курносов on 28.03.2022.
//

import XCTest
@testable import ShoppingCiscoKurnosov

class CoreDataServiceTests: XCTestCase {

    private var service: CoreDataService?
    
    override func setUpWithError() throws {
        service = CoreDataService()
    }
    
    func testAddTwoLoadAndDelete() throws {
        
        let item1 = CategoryItem.create(
            itemName: "itemName1",
            categoryName: "categoryName1",
            color: "color1"
        )
        
        let item2 = CategoryItem.create(
            itemName: "itemName2",
            categoryName: "categoryName2",
            color: "color2"
        )
        
        addArrayAndDelete(categoryItems: [item1, item2])
    }
    
    func testAdd3TimesLoadAndDelete() throws {
        
        let item1 = CategoryItem.create(
            itemName: "itemName1",
            categoryName: "categoryName1",
            color: "color1"
        )
        
        addArrayAndDelete(categoryItems: [item1, item1, item1])
    }
    
    private func addArrayAndDelete(categoryItems: [CategoryItem]) {
        guard let service = service else {
            XCTFail()
            return
        }
        
        let names = categoryItems.map {
            $0.item.name
        }
        
        service.clearItems()
        
        let load0Expect = XCTestExpectation(description: "Loading 0")
        service.loadItems { items in
            XCTAssert(items.count == 0)
            
            load0Expect.fulfill()
        }
        
        for item in categoryItems {
            service.addItem(item)
        }
        
        let load1Expect = XCTestExpectation(description: "Loading 1")
        
        service.loadItems { items in
            XCTAssert(items.count == categoryItems.count)
            
            if items.count > 0 {
                let itemName = items[0].item.name
                
                XCTAssert(names.contains(itemName))
            }
            
            load1Expect.fulfill()
        }
        
        service.clearItems()
        
        let load2Expect = XCTestExpectation(description: "Loading 2")
        
        service.loadItems { items in
            XCTAssert(items.count == 0)
            
            load2Expect.fulfill()
        }
        
        wait(
            for: [load0Expect, load1Expect, load2Expect],
            timeout: 0.1 * Double(categoryItems.count)
        )
    }
}

private extension CategoryItem {
    static func create(
        itemName: String,
        categoryName: String,
        color: String
    ) -> Self {
        .init(
            item: Item(name: itemName),
            category: CategoryTitle(
                name: categoryName,
                colour: color
            )
        )
    }
}
