//
//  siteCell.swift
//  admin
//
//  Created by drf on 2017/10/4.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit

class siteCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        }
    }
    
}
