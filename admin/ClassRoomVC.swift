//
//  ClassRoomVC.swift
//  admin
//
//  Created by drf on 2017/10/4.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class ClassRoomVC: UITableViewController {

    var searchBar = UISearchBar()
    var ClassroomArray = [[String : Any]]()
    var temp_layoutArray = [[Int]]() // 用于正向传值

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllClassRoom()
        self.navigationItem.title = "教室管理"
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addClassroom))
        self.navigationItem.leftBarButtonItem = addItem
        searchBar.delegate = self
        searchBar.placeholder = "搜索教室"
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        self.navigationController?.navigationBar.addSubview(searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        // 监听更新消息
        
        
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
        return ClassroomArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classroomCell", for: indexPath) as! classroomCell
        cell.classroomLbl.text = ClassroomArray[indexPath.row]["classroomName"] as? String
        return cell
    }
    
    // HeaderView 

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
        // 获取编辑的单元格
        let cell = tableView.cellForRow(at: indexPath) as! classroomCell
        let edit = UITableViewRowAction(style: .normal, title: "查看/修改"){[weak self] (action) in
            let editVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditClassroomVC") as! EditClassroomVC
            let id = self?.ClassroomArray[indexPath.row]["id"] as? Int
            // layout
            let url = URL(string: admin.weteam.baseURL+admin.Method.getClassLayout+"?id="+String(id!))
            Alamofire.request(url!).responseJSON{[weak self] response in
                if let json = response.result.value as? [String:Any]{
                    if json["errors"] == nil {
                        self?.temp_layoutArray = json["data"] as! [[Int]]
                        self?.tableView.reloadData()
                    }
                }
                
            }
            if !(self?.temp_layoutArray.isEmpty)!{
            editVC.classroomInfo = ["name": cell.classroomLbl.text!, "id": id!, "layout": self?.temp_layoutArray]
            self?.navigationController?.pushViewController(editVC, animated: true)
            }
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "删除"){(action) in
            
        }
        
        return [delete,edit]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func addClassroom(){
        let addClassroomVC = storyboard?.instantiateViewController(withIdentifier: "EditClassroomVC") as! EditClassroomVC
        addClassroomVC.type = "添加教室"
        self.navigationController?.pushViewController(addClassroomVC, animated: true)
    }
    
    // 获取所有教室
    func loadAllClassRoom(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getAllClassRoom)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    self?.ClassroomArray = json["data"] as! [[String : Any]]
                    self?.tableView.reloadData()
                } else {
                    if let error = json["errors"] {
                        // 完善错误提示
                        self?.alert(error: "提示", message: error as! String)
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

}

extension ClassRoomVC : UISearchBarDelegate {
    func search(){
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        searchBar.showsCancelButton = true
        // 暂时隐藏搜索按钮
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let url = URL(string: admin.weteam.baseURL+admin.Method.searchClassRoom)
        let parameter : Parameters = ["keyword": text,"pageSize" : 20, "currPage" : 1]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    // 注意，取消后loadAllStudent?
                    print(json)
                    self?.ClassroomArray = json["data"] as! [[String : Any]]
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadAllClassRoom()
        searchBar.resignFirstResponder()
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        // 显示搜索按钮
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
}
