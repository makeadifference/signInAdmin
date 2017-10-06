
//
//  SignInVC.swift
//  admin
//
//  Created by drf on 2017/10/5.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class SignInVC: UITableViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    var searchBar = UISearchBar()
    var type = ""
    // 接口数据
    var studentArray = [[String:Any]]()
    var courseArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "签到统计"
        self.type = "学生"
        loadAllStudent()
        // searchBar
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        searchBar.placeholder = "搜索学生"
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        self.navigationItem.rightBarButtonItem = searchItem
        self.navigationController?.navigationBar.addSubview(searchBar)

    }

    // MARK: Actions
    @IBAction func segementControll(_ sender: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            self.type = "学生"
            searchBar.placeholder = "搜索学生"
        case 1:
            self.type = "课程"
            searchBar.placeholder = "搜索课程"
            loadAllCourse()
        default:
            break
        }
        self.tableView.reloadData()
        
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
        if self.type == "学生"{
        return studentArray.count
        } else {
            return courseArray.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "signInCell", for: indexPath) as! studentCell
        if self.type == "学生" {
            cell.nameLbl.text = studentArray[indexPath.row]["studentName"] as? String
            cell.phoneNum.text = studentArray[indexPath.row]["phoneNumber"] as? String
        } else {
            cell.phoneNum.text = ""
              cell.nameLbl.text = courseArray[indexPath.row]["courseName"] as? String
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = studentArray[indexPath.row]["id"] as? Int
        let detainsVC = storyboard?.instantiateViewController(withIdentifier: "studentSignInVC") as! studentSignInVC
        detainsVC.id = id!
        self.navigationController?.pushViewController(detainsVC, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // 获取所有课程
    func loadAllCourse(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getAllCourse)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    self?.courseArray = json["data"] as! [[String : Any]]
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

extension SignInVC : UISearchBarDelegate {
    func search(){
        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        searchBar.showsCancelButton = true
        print("search")
        // 暂时隐藏搜索按钮
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if type == "学生" {
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
            }
        
        if type == "课程" {
            let url = URL(string: admin.weteam.baseURL+admin.Method.searchCourse)
            let parameter : Parameters = ["keyword":text , "pageSize" : 20, "curPage" : 1]
            Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
                if let json = response.result.value as? [String : Any]{
                    if json["errors"] == nil {
                        // 注意，取消后loadAllStudent?
                        self?.courseArray = json["data"] as! [[String : Any]]
                        self?.tableView.reloadData()
                    } else {
                        if let errer = json["error"] {
                            self?.alert(error: "提示", message: errer as! String)
                        }
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
        searchBar.resignFirstResponder()
        searchBar.frame = CGRect(x: 0, y: -80, width: self.view.frame.width, height: 40)
        // 显示搜索按钮
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
