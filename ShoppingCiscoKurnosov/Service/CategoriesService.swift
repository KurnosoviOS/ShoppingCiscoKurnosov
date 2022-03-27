//
//  CategoriesService.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
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

struct CategoriesService {
    func loadCategories(handler: @escaping ([Category], Error?) -> Void) -> Void {
        DispatchQueue.global(qos: .utility).async {
            let decoder = JSONDecoder()
            guard let jsonData = json.data(using: .utf8) else {
                // TODO: return an error
                handler([], nil)
                return
            }
            
            if let list = try? decoder.decode(CategoryList.self, from: jsonData) {
                handler(list.categories, nil)
            }
        }
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

private let json = """
{
  "categories": [
    {
      "name": "PurpleCat",
      "colour": "#b794c2",
      "items": [
        {
          "name": "ItemName1"
        },
        {
          "name": "ItemName2"
        },
        {
          "name": "Short"
        },
        {
          "name": "VeryLongItemName_VeryLongItemName"
        },
        {
          "name": "Very Long Item Name With Spaces"
        },
        {
          "name": "Purple Name"
        },
        {
          "name": "Айде един на български"
        },
        {
          "name": "中文文章"
        },
        {
          "name": "Tricky"
        },
        {
          "name": "ItemName1 copied"
        },
        {
          "name": "ItemName2 copied"
        },
        {
          "name": "Short copied"
        },
        {
          "name": "VeryLongItemName_VeryLongItemName copied"
        },
        {
          "name": "Very Long Item Name With Spaces copied"
        },
        {
          "name": "Purple Name copied"
        },
        {
          "name": "Айде един на български copied"
        },
        {
          "name": "中文文章 copied"
        },
        {
          "name": "Tricky"
        }
      ]
    },
    {
      "name": "Зелената категория",
      "colour": "#82a36f",
      "items": [
        {
          "name": "ItemName1"
        },
        {
          "name": "ItemName2"
        },
        {
          "name": "Short"
        },
        {
          "name": "VeryLongItemName_VeryLongItemName"
        },
        {
          "name": "Very Long Item Name With Spaces"
        },
        {
          "name": "Purple Name"
        },
        {
          "name": "Айде един на български"
        }
      ]
    },
    {
      "name": "Shorty",
      "colour": "#ae6944",
      "items": [
        {
          "name": "ItemName1"
        },
        {
          "name": "ItemName2"
        },
        {
          "name": "Short"
        }
      ]
    },
    {
      "name": "Category with larger name than expected",
      "colour": "#9c2828",
      "items": [
        {
          "name": "ItemName1"
        },
        {
          "name": "ItemName2"
        },
        {
          "name": "Short"
        },
        {
          "name": "VeryLongItemName_VeryLongItemName"
        },
        {
          "name": "Very Long Item Name With Spaces"
        },
        {
          "name": "Purple Name"
        },
        {
          "name": "Айде един на български"
        }
      ]
    },
    {
      "name": "Category5",
      "colour": "#af5353",
      "items": [
        {
          "name": "ItemName1"
        },
        {
          "name": "ItemName2"
        },
        {
          "name": " "
        },
        {
          "name": "ItemName4"
        }
      ]
    },
    {
      "name": "Empty Cat",
      "colour": "#7c7c7c",
      "items": []
    }
  ]
}
"""
