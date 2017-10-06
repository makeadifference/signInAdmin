//
//  NaviVC.swift
//  simple
//
//  Created by drf on 2017/9/18.
//  Copyright © 2017年 drf. All rights reserved.
// 用于美化导航栏

import UIKit

class NaviVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航栏标题颜色
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        // 导航栏按钮文本颜色
        self.navigationBar.tintColor = UIColor.white
        // 导航栏背景色
        self.navigationBar.barTintColor = UIColor(red: 18.0/255.0, green: 86.0/255.0, blue: 136.0/255.0, alpha: 1)
        // 不透明
        self.navigationBar.isTranslucent = false
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 状态栏风格
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
