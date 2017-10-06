//
//  EditClassVC.swift
//  admin
//
//  Created by drf on 2017/10/2.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class EditClassVC: UIViewController {

    @IBOutlet weak var item1Lbl: UILabel!
    @IBOutlet weak var item1Text: UITextField!
    @IBOutlet weak var item2Lbl: UILabel!
    @IBOutlet weak var item2Text: UITextField!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    var type = "" // 用于复用controller
    var  imformation  = [String : String]()
    var pickerView : UIPickerView!
    // api 数据
    var Classroominfo = [[String : Any]]()
    var ClassRoomArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pickerView
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        item2Text.inputView = pickerView
        setContent(type: type)
        loadAllClassRoom()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func comfireEdit(_ sender: Any) {
        if type == "修改课程" {
            editCourse()
        } else {
            addCourse()
        }
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func setContent(type :String){
        if type == "修改课程" {
            item1Lbl.text = "课程名："
            item1Text.text = imformation["courseName"]
            item2Lbl.text = "所在教室："
            item2Text.text = imformation["classroomName"]
            item2Text.accessibilityNavigationStyle = .automatic
            leftBtn.setTitle("修改", for: .normal)
            rightBtn.setTitle("取消", for: .normal)
            self.navigationItem.title = "修改课程"
        } else {
            item1Lbl.text = "课程名："
            item1Text.placeholder = "请输入课程名"
            item2Lbl.text = "所在教室："
            item2Text.placeholder = "请选择教室"
            leftBtn.setTitle("添加", for: .normal)
            rightBtn.setTitle("取消", for: .normal)
            self.navigationItem.title = "添加课程"
        }
    }
    
    // 添加课程
    func addCourse(){
        // 检验数据有效性
        if (item1Text.text?.isEmpty)! {
            alert(error: "提示", message: "课程名不能为空")
            return
        }
        
        if (item2Text.text?.isEmpty)! {
            alert(error: "提示", message: "请选择一件教室")
            return
        }

        let url = URL(string: admin.weteam.baseURL+admin.Method.addCourse)
        // 教室id，教室名
        var id : Int = 0
        for item in Classroominfo {
            if item["classroomName"] as? String == item2Text.text {
                id = item["id"] as! Int
            }
        }
        let parameter : Parameters = ["courseName": item1Text.text!,"classroomId" : id]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any] {
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: "添加课程成功")
                    // 发送通知
                } else {
                    let errors = json["errors"] as! [String : String]
                    self?.alert(error: "添加课程失败", message: String(describing: errors) )
                    print(errors)
                }
            }
        }
    }
    
    // 修改课程
    func editCourse(){
        // 检验数据有效性
        if (item1Text.text?.isEmpty)! {
            alert(error: "提示", message: "课程名不能为空")
            return
        }
        
        if (item2Text.text?.isEmpty)! {
            alert(error: "提示", message: "请选择一间教室")
            return
        }
        
        let url = URL(string: admin.weteam.baseURL+admin.Method.updateCourse)
        let parameter : Parameters = ["courseName": item1Text.text!,"classroomId" : imformation["roomId"]! , "id" : imformation["id"]!]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any] {
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: "更新课程信息成功")
                    // 发送通知
                } else {
                    let errors = json["errors"] as! [String : String]
                    // 完善错误提示
                    self?.alert(error: "修改失败", message: String(describing: errors) )
                }
            }
        }
    }
    
    // 获取所有教室
    func loadAllClassRoom(){
        let url = URL(string: admin.weteam.baseURL+admin.Method.getAllClassRoom)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value as? [String : Any]{
                if json["errors"] == nil {
                    let data = json["data"] as! [[String : Any]]
                    self?.Classroominfo = data
                    for item in data {
                        self?.ClassRoomArray.append(item["classroomName"] as! String)
                    }
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

extension EditClassVC : UIPickerViewDelegate , UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return  1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if !ClassRoomArray.isEmpty {
            return ClassRoomArray.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ClassRoomArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.item2Text.text = ClassRoomArray[row]
    }
}
