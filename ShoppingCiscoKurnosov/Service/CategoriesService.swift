//
//  CategoriesService.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

struct CategoriesService {
    func loadCategories(handler: @escaping ([Category], Error?) -> Void) -> Void {
        DispatchQueue.global(qos: .utility).async {
            guard let path = Bundle.main.path(forResource: "categories", ofType: "json") else {
                handler([], InnerError.parseError(reason: "Resource file not found"))
                return
            }
            
            guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
                handler([], InnerError.parseError(reason: "Resource file not found"))
                return
            }
            
            let decoder = JSONDecoder()
            
            if let list = try? decoder.decode(CategoryList.self, from: jsonData) {
                handler(list.categories, nil)
            } else {
                handler([], InnerError.parseError(reason: "Incorrect resource file"))
            }
        }
    }
}

private enum InnerError: LocalizedError {
    case parseError(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .parseError(let reason):
            return reason
        }
    }
}
