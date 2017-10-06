//
//  TarBarVC.swift
//  simple
//
//  Created by drf on 2017/9/24.
//  Copyright © 2017年 drf. All rights reserved.
//  需要维护的全局变量dot , newsCount


import UIKit

class TarBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置 tabBar 图标选中时的颜色
        self.tabBar.tintColor = UIColor.blue
        //遍历全部 tabBarItem，设置 badege 值
        for one in self.tabBar.items! {
            one.badgeValue = "1"
        }
        // 设置图片背景
        for two in self.tabBar.items! {
            two.image = two.image?.withRenderingMode(.alwaysOriginal)
            two.selectedImage = two.image?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
