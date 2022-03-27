//
//  CategoriesServiceTests.swift
//  ShoppingCiscoKurnosovTests
//
//  Created by Алексей Курносов on 28.03.2022.
//

import XCTest
@testable import ShoppingCiscoKurnosov

class CategoriesServiceTests: XCTestCase {

    private var service: CategoriesService?
    
    override func setUpWithError() throws {
        service = CategoriesService()
    }

    func testLoadCategories() throws {
        guard let service = service else {
            XCTFail()
            return
        }
        
        let expect = XCTestExpectation(description: "loading categories")
        service.loadCategories { categories, error in
            XCTAssertNil(error)
            
            XCTAssertEqual(categories.count, 6)
            
            if categories.count == 6 {
                let category = categories[2]
                
                //(174,105,68)
                let color = UIColor(
                    red: CGFloat(174)/256.0,
                    green: CGFloat(105)/256.0,
                    blue: CGFloat(68)/256.0,
                    alpha: 1
                )
                
                XCTAssertEqual(category.name, "Shorty")
                XCTAssertEqual(category.color, color)
                XCTAssertEqual(category.items.count, 3)
                
                if category.items.count == 3 {
                    XCTAssertEqual(category.items[1].name, "ItemName2")
                }
            }
            
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1)
    }
}
