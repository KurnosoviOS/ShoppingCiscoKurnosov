//
//  ItemCollectionViewCell.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    static let reuseIdentifier = "ItemCollectionViewCell_identifier"

    @IBOutlet weak var nameLabel: UILabel?
}
