//
//  studentClassSettingVC.swift
//  admin
//
//  Created by drf on 2017/10/2.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class studentClassSettingVC: UICollectionViewController {

    // 这里应该有一个id,课程的字典  http://123.207.117.67/studentsignin/student/getCourseInfo
    // http://123.207.117.67/studentsignin/admin/course/getAll  这个方法最适合id Yu courseName
    // 用于cellfor indexpath 内容填充
    var pickerView : UIPickerView!
    var alertView : UIAlertController!
    var id = 0 // studentId
    // api数据
    var classSchedule = [[Int]]()
    var classImformation = [[String:Any]]()
    var classinfo = [Int:String]()
    var idArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("id:\(id)")
        getClassSchedule()
        getClassImformation()
        dosomething()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 9
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 8
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classCell", for: indexPath) as! classcell
        
        if idArray.isEmpty && !classImformation.isEmpty {
            // 获取idArray
            for item in classImformation {
                idArray.append(item["id"] as! Int)
            }
            print("课程表:\(classSchedule)")
            print("idArray:\(idArray)")
            print("clasinfo:\(classinfo)")
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
                    cell.id = classSchedule[indexPath.row-1][indexPath.section]
                    
                    // 无课标记为灰色
                    if cell.id == 0 {
                        cell.backgroundColor = UIColor.lightGray
                    } else {
                        cell.backgroundColor = UIColor.cyan
                    }
                }
            }
        }
        // 填充数据
        for num in idArray {
            if cell.id == num {
                cell.name.text = classinfo[num]
            }
        }
        

        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! classcell
        // 可编辑区域
        if indexPath.row == 0 {
            cell.isUserInteractionEnabled = false
        }
        // 使用KVC
        cell.layer.setValue(indexPath, forKey: "indexPath")
        pickerView.selectedCell = cell
        self.present(alertView, animated: true, completion: nil)
    }
    
    // HeaderView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! classTableHeaderView
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
    
    // 修改/设置学生课程表
    func commitChange(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.setClassSchedule)
        let parameter : Parameters = ["studentId": id,"coursesJsonLayout": String(describing: classSchedule)]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: "设置成功")
                } else {
                    let errors = json["errors"] as! [String:String]
                    self?.alert(error: "设置失败", message: String(describing: errors))
                }
                
            }
        }
        
    }
    
    func selected(){
        
    }
    
    func cancel(){
    }
    
    func dosomething(){
        self.navigationItem.title = "学生课程设置"
        let rightItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(commitChange))
        self.navigationItem.backBarButtonItem?.title = "<取消"
        self.navigationItem.rightBarButtonItem = rightItem
        // pickerview
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        alertView = UIAlertController(title: "请选择课程", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        pickerView.sizeToFit()
        //pickerView.frame = CGRect(x: 10 , y: 60, width: 250, height: 140) // 16:9
        pickerView.frame = CGRect(x: 0, y: 52, width: 270, height: 100)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "修改", style: .default, handler: nil)
        alertView.addAction(cancel)
        alertView.addAction(ok)
        alertView.view.addSubview(pickerView)
        
        
        
        // 固定headerview
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    
    
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    

}

extension studentClassSettingVC : UICollectionViewDelegateFlowLayout {
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

extension studentClassSettingVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return classinfo.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return classinfo[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 获取点击的cell
        let  cell = pickerView.selectedCell
        let indexPath = cell?.layer.value(forKey: "indexPath") as! IndexPath
        cell?.name.text = classinfo[row]
        // 获取字典的key值
        for (num , name) in classinfo {
            if name == cell?.name.text {
                cell?.id = num
                // 更新json数组
                if !classSchedule.isEmpty {
                    if indexPath.row>0 {
                        if indexPath.section < classSchedule[0].count && (indexPath.row-1)<classSchedule.count {
                            classSchedule[indexPath.row-1][indexPath.section] = (cell?.id)!
                        }
                        print("New json Array :\(classSchedule)")
                    }
                }
            }
        }
        
    }
    
}

    private var myAssociationKey : UInt = 1998
extension UIPickerView {
    // 使用关联值 objc 关联值
    var selectedCell : classcell! {
        get {
            return objc_getAssociatedObject(self, &myAssociationKey) as! classcell
        }
        set(newValue) {
            objc_setAssociatedObject(self, &myAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

}
