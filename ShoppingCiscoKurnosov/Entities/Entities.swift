//
//  Entities.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 28.03.2022.
//

import UIKit

struct CategoryList: Codable {
    let categories: [Category]
}

struct Item: Codable {
    let name: String
}

struct Category: Codable {
    let name: String
    fileprivate let colour: String
    let items: [Item]
    
    var color: UIColor {
        colour.color
    }
    
    var title: CategoryTitle {
        return .init(
            name: name,
            colour: colour
        )
    }
}

struct CategoryTitle {
    let name: String
    let colour: String
    
    var color: UIColor {
        colour.color
    }
}

struct CategoryItem {
    let item: Item
    let category: CategoryTitle
    
    var color: UIColor {
        category.color
    }
}

extension String {
    func substring(_ range: Range<Int>) -> String {
        let lower = index(startIndex, offsetBy: range.lowerBound)
        let upper = index(startIndex, offsetBy: range.upperBound)
        
        return String(self[lower ..< upper])
    }
}

private extension String {
    var color: UIColor {
        let rStr = self.substring(1 ..< 3)
        let gStr = self.substring(3 ..< 5)
        let bStr = self.substring(5 ..< 7)
        
        guard
            let r = Int(rStr, radix: 16),
            let g = Int(gStr, radix: 16),
            let b = Int(bStr, radix: 16) else {
            return .white
        }
        
        return .init(
            red: CGFloat(r) / 256,
            green: CGFloat(g) / 256,
            blue: CGFloat(b) / 256,
            alpha: 1
        )
    }
}
