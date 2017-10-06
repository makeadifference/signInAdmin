//
//  ManageClassVC.swift
//  admin
//
//  Created by drf on 2017/10/2.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class ManageClassVC: UITableViewController {

    var searchBar = UISearchBar()
    var CourseArray = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllCourse()
        self.navigationItem.title = "课程管理"
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addClass))
        self.navigationItem.leftBarButtonItem = addItem
        //  searchbar
        searchBar.delegate = self
        searchBar.placeholder = "搜索课程"
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        self.navigationController?.navigationBar.addSubview(searchBar)
        let settingImage = UIImage(named: "settings_white")
        let originImage = settingImage?.withRenderingMode(.alwaysOriginal)
        
        /*
        // 修复图标灰色
        let frame = addItem.frame
        let settingBtn = UIButton(frame: frame!)
        settingBtn.setBackgroundImage(originImage, for: .normal)
        let settingItem = UIBarButtonItem(customView: settingBtn)
        */
        let settingItem = UIBarButtonItem(image: originImage, style: .plain, target: self, action: #selector(classSetting))
        self.navigationItem.rightBarButtonItems = [searchItem, settingItem]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CourseArray.count
    }
    
    // header view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height :CGFloat = 30
        let width = self.view.frame.width
        let frame = CGRect(x: 0, y: 0, width: height, height: width)
        let view = UIView(frame: frame)
        // 更加优雅的写法，使用初始化闭包
        let nameLblWidth = self.view.frame.width/3
        let phoneNumWidth = self.view.frame.width/3*2
        let nameFram = CGRect(x: 5, y: 5, width: nameLblWidth, height: 15)
        let phoneFram = CGRect(x: nameLblWidth+5, y: 5, width: phoneNumWidth, height: 15)
        let nameLbl = UILabel(frame: nameFram)
        let phoneNum = UILabel(frame: phoneFram)
        nameLbl.text = "课程名"
        phoneNum.text = "教室"
        view.addSubview(nameLbl)
        view.addSubview(phoneNum)
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // footer view
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let width = self.view.frame.width
        let frame = CGRect(x: 0, y: 0, width: width, height: 30)
        let view = UIView(frame: frame)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 15))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "共有\(CourseArray.count)门课程"
        
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! studentCell
        cell.nameLbl.text = CourseArray[indexPath.row]["courseName"] as? String
        cell.phoneNum.text = (CourseArray[indexPath.row]["classroom"] as! [String : Any])["classroomName"] as? String
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // 获取点击的单元格, 正向传值
        let cell = tableView.cellForRow(at: indexPath) as!studentCell
        let classRoomID = (self.CourseArray[indexPath.row]["classroom"] as! [String: Any])["id"] as! Int
        let courseID = self.CourseArray[indexPath.row]["id"] as! Int
        print("courseID:\(courseID)")
        let delete = UITableViewRowAction(style: .destructive, title: "删除"){(TableViewRowAction , indexPath) in
        }
        
        // 使用weak self避免循环引用
        let edit = UITableViewRowAction(style: .normal, title: "编辑"){[weak self](RowAction, indexPath) in
            let editVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditClassVC") as! EditClassVC
            editVC.type = "修改课程"
            editVC.imformation = ["courseName": cell.nameLbl.text!,"classroomName": cell.phoneNum.text!,"roomId" : String(classRoomID) , "id" : String(courseID)]
            self?.navigationController?.pushViewController(editVC, animated: true)
        }
        
        return [delete, edit]
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   
    func addClass(){
       let addVC = storyboard?.instantiateViewController(withIdentifier: "EditClassVC") as! EditClassVC
        addVC.type = "添加课程"
        //addVC.imformation =
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    func classSetting(){
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchStudentVC") as! searchStudentVC
        self.navigationController?.pushViewController(searchVC, animated: true)
        
    }

}

extension ManageClassVC : UISearchBarDelegate {
    func search(){
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        searchBar.showsCancelButton = true
        // 暂时隐藏搜索按钮与设置按钮
        for item in self.navigationItem.rightBarButtonItems! {
            item.tintColor = UIColor.clear
            item.isEnabled = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let url = URL(string: admin.weteam.baseURL+admin.Method.searchCourse)
        let parameter : Parameters = ["keyword":text , "pageSize" : 20, "curPage" : 1]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    // 注意，取消后loadAllStudent?
                    self?.CourseArray = json["data"] as! [[String : Any]]
                    self?.tableView.reloadData()
                } else {
                    if let errer = json["error"] {
                        self?.alert(error: "提示", message: errer as! String)
                    }
                }
            }
        }
        
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadAllCourse()
        searchBar.resignFirstResponder()
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        // 显示搜索按钮
        for item in self.navigationItem.rightBarButtonItems! {
            item.tintColor = UIColor.white
            item.isEnabled = true
        }
    }
    
    // 获取所有课程
    func loadAllCourse(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getAllCourse)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    self?.CourseArray = json["data"] as! [[String : Any]]
                    self?.tableView.reloadData()
                } else {
                    // 无需登录，无错误信息返回
                _ = json["errors"] as! [String:String]
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


extension UIBarButtonItem {
    // 获取barbutton 的frame
    
    var frame: CGRect? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view.frame
    }
    
}

