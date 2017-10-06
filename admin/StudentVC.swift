//
//  StudentVC.swift
//  admin
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//  这个Controller可以进行多次复用

import UIKit
import Alamofire

class StudentVC: UITableViewController {
    
    var searchBar = UISearchBar()
    var studentArray = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "学生管理"
        loadAllStudent()
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStudent))
        self.navigationItem.leftBarButtonItem = addItem
        searchBar.delegate = self
        searchBar.placeholder = "搜索学生"
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        self.navigationController?.navigationBar.addSubview(searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        // 监听更新消息
         NotificationCenter.default.addObserver(self, selector: #selector(updated(notification:)), name: Notification.Name.init(rawValue: "updated"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //searchBar.removeFromSuperview()
        print("viewwilldisappear")
        NotificationCenter.default.removeObserver(self)
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
        return studentArray.count
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
        nameLbl.text = "学生姓名"
        phoneNum.text = "电话号码"
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
        label.text = "共有\(studentArray.count)个学生"
        
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! studentCell
        cell.nameLbl.text = studentArray[indexPath.row]["studentName"] as? String
        cell.phoneNum.text = studentArray[indexPath.row]["phoneNumber"] as? String
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
        // 获取编辑中的单元格
        let cell = tableView.cellForRow(at: indexPath) as! studentCell
        // 获取学生id
        let id = studentArray[indexPath.row]["id"] as? Int
        let delete = UITableViewRowAction(style: .destructive, title: "删除"){(TableViewRowAction , indexPath) in
            let url = URL(string: admin.weteam.baseURL+admin.Method.deleteStudent)
            let parameter : Parameters = ["id": id!]
            Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
                if let json = response.result.value as? [String :Any] {
                    if json["errors"] == nil {
                        self?.studentArray.remove(at: indexPath.row)
                        self?.tableView.reloadData()
                        self?.alert(error: "提示", message: json["msg"] as! String)
                        // 发送更新消息
                    } else {
                        let errors = json["errors"] as! [String : String]
                        if let idError = errors["id"]{
                            self?.alert(error: "提示", message: idError)
                        }
                    }
                }
            }
        }
        
        // 使用weak self避免循环引用
        // 更新学生信息
        
        let edit = UITableViewRowAction(style: .normal, title: "编辑"){[weak self](RowAction, indexPath) in
            let editVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditStudentVC") as! EditStudentVC
            editVC.type = "修改学生"
            editVC.imformation = ["id": String(id!) ,"name": cell.nameLbl.text!, "phone" : cell.phoneNum.text!]
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

    func addStudent(){
        let addStudVC = storyboard?.instantiateViewController(withIdentifier: "EditStudentVC") as! EditStudentVC
        addStudVC.type = "添加学生"
        self.navigationController?.pushViewController(addStudVC, animated: true)
    }
    
    // 获取所有学生
    func loadAllStudent(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getAllStu)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value  as? [String : Any]{
                if json["errors"] == nil {
                    self?.studentArray = json["data"] as! [[String : Any]]
                    self?.tableView.reloadData()
                } else {
                    if let errer = json["error"] {
                        self?.alert(error: "提示", message: errer as! String)
                    }
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
    
    // 处理更新数据消息， 有bug啊
    func updated(notification: Notification){
        print("成功接收消息")
        loadAllStudent()
        print("重新加载数据")
    }

}

extension StudentVC : UISearchBarDelegate {
    func search(){
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        searchBar.showsCancelButton = true
        // 暂时隐藏搜索按钮
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let url = URL(string: admin.weteam.baseURL+admin.Method.searchStudent)
        let parameter : Parameters = ["keyword": text,"pageSize" : 50, "currPage" : 1]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    // 注意，取消后loadAllStudent?
                    self?.studentArray = json["data"] as! [[String : Any]]
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
        loadAllStudent()
        searchBar.resignFirstResponder()
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        // 显示搜索按钮
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
