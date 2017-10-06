//
//  studentSignInVC.swift
//  admin
//
//  Created by drf on 2017/10/6.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire


class studentSignInVC: UICollectionViewController {
    
    var id = 0 // studentId
    // api数据
    var classSchedule = [[Int]]()
    var classImformation = [[String:Any]]()
    var classinfo = [Int:String]()
    var idArray = [Int]()
    var currDate = [String:Int]()
    var signIninfo = [[Int]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "学生签到统计"
        getClassSchedule()
        getClassImformation()
        getCurrDate()
        getStudentSignInDetails()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "signInCell", for: indexPath) as! classcell
        
        if idArray.isEmpty && !classImformation.isEmpty {
            // 获取idArray, 建立id与className的对应关系
            for item in classImformation {
                idArray.append(item["id"] as! Int)
            }
            print("课程表:\(classSchedule)")
            print("idArray:\(idArray)")
            print("clasinfo:\(classinfo)")
            print("signInfo:\(signIninfo)")
        }
        
        // 首列数字
        if indexPath.row == 0 {
            cell.name.text = String(indexPath.section+1)
        } else {
            cell.name.text = ""
        }
        
        // 利用对应关系,标记单元格
        if !classSchedule.isEmpty {
            if indexPath.row>0 {
                if indexPath.section < classSchedule[0].count && (indexPath.row-1)<classSchedule.count {
                    // 标记课程信息
                    cell.id = classSchedule[indexPath.row-1][indexPath.section]
                    // 标记是否签到
                    cell.isSignIned = signIninfo[indexPath.row-1][indexPath.section]
                }
            }
        }
        // 填充课程信息
        for num in idArray {
            if cell.id == num {
                cell.name.text = classinfo[num]
            }
        }
        // 标记签到情况
        if !signIninfo.isEmpty {
            if cell.isSignIned == 1 {
                cell.backgroundColor = UIColor.red
            }
        }
        return cell
    }
    
    // HeaderView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SignInheaderView", for: indexPath) as! classTableHeaderView
        headerview.momthLbl.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        let width = (self.view.frame.width-30)/7
        headerview.mondayLbl.frame.size = CGSize(width: width, height: 25)
        headerview.backgroundColor = UIColor.brown
        return headerview
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // 获取学生课程表
    func getClassSchedule(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getClassSchedule)
        let parameter : Parameters = ["studentId" : id]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value  as? [String:Any]{
                if json["errors"] == nil {
                    self?.classSchedule = json["data"] as! [[Int]]
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    // 有待完善错误信息
                    self?.alert(error: "提示", message: String(describing: errors))
                    
                }
            }
        }
        
    }
    
    // 获取课程信息
    func getClassImformation(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getAllCourse)
        Alamofire.request(url!).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.classImformation = json["data"] as! [[String:Any]]
                    
                    let data = json["data"] as! [[String:Any]]
                    for item in data {
                        self?.classinfo.updateValue(item["courseName"] as! String, forKey: item["id"] as! Int)
                    }
                    // 无课选项
                    self?.classinfo.updateValue("", forKey: 0)
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    // 进一步完善错误信息
                    self?.alert(error: "提示", message: String(describing: errors))
                }
            }
        }
    }
    
    // 获取学生签到信息
    func getStudentSignInDetails(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.signRecordByStudent)
        let parameter : Parameters = ["studentId":id , "week":1]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.signIninfo = json["data"] as! [[Int]]
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    self?.alert(error: "提示", message: String(describing: errors))
                }
            }
        }
    }
    
    // 获取当前日期
    func getCurrDate(){
        let url = URL(string: admin.Method.currTime)
        Alamofire.request(url!).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.currDate = json["data"] as! [String : Int]
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    self?.alert(error: "提示", message: String(describing: errors))
                }
            }
            
        }
    }
    
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}

extension studentSignInVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 首列
        if indexPath.row == 0 {
            return CGSize(width: 30, height: 85)
        } else {
            let width = (self.view.frame.width-30)/7
            let height :CGFloat = 85
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = self.view.frame.width
        let height :CGFloat = 30
        if section == 0 {
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}
