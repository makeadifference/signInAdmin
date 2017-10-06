//
//  classcell.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit

class classcell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    // 课程标记
    var id :Int = 0
    // 签到标记
    var isSignIned = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
