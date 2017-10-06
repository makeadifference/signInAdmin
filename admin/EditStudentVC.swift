//
//  EditStudentVC.swift
//  admin
//
//  Created by drf on 2017/10/2.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class EditStudentVC: UIViewController {

    @IBOutlet weak var item1Lbl: UILabel!
    @IBOutlet weak var item1Text: UITextField!
    @IBOutlet weak var item2Lbl: UILabel!
    @IBOutlet weak var item2Text: UITextField!
    @IBOutlet weak var item3Lbl: UILabel!
    @IBOutlet weak var item3Text: UITextField!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    var type = "" // 用于复用
    // 正向传值, 需要避免循环引用，否则易出错
    var imformation = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent(type: type)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func comfireEdit(_ sender: Any) {
        if type == "添加学生" {
            addStudent()
        } else {
            editStudent()
        }
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setContent(type:String){
        if type == "添加学生" {
            item1Lbl.text = "学生姓名："
            item1Text.placeholder = "请输入学生姓名"
            item2Lbl.text = "手机号码："
            item2Text.placeholder = "请输入学生手机号码"
            item3Lbl.text = "初始密码："
            item3Text.placeholder = "请输入学生初始密码"
            leftBtn.setTitle("添加", for: .normal)
            rightBtn.setTitle("取消", for: .normal)
            self.navigationItem.title = "添加学生"
        } else {
            item1Lbl.text = "学生姓名："
            item1Text.placeholder = "请输入学生姓名"
            item1Text.text = self.imformation["name"]
            item2Lbl.text = "手机号码："
            item2Text.text = self.imformation["phone"]
            item2Text.placeholder = "请输入新的手机号码"
            item3Lbl.text = "初始密码："
            item3Text.placeholder = "请输入新的密码"
            leftBtn.setTitle("修改", for: .normal)
            rightBtn.setTitle("取消", for: .normal)
            self.navigationItem.title = "修改学生"
        }
    }
    
    // 添加学生
    func addStudent(){
        // 检验数据有效性
        
        if (item1Text.text?.isEmpty)! {
            alert(error: "提示", message: "学生姓名不能为空")
            return 
        }
        
        if (item2Text.text?.isEmpty)! {
            alert(error: "提示", message: "电话号码不能为空")
            return
        }
        
        if !validatePhoneNumber(num: item2Text.text!) {
            alert(error: "提示", message: "无效的电话号码")
        }
        
        if (item3Text.text?.isEmpty)! {
            alert(error: "提示", message: "初始密码不能为空")
            return 
        }
        
        let url = URL(string: admin.weteam.baseURL+admin.Method.addStudent)
        let parameter : Parameters = ["phoneNumber" : item2Text.text!,"studentName": item1Text.text!,"password": item3Text.text!]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String :Any]{
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: json["msg"] as! String)
                    // 通知studentVC 更新数据
                    NotificationCenter.default.post(name: Notification.Name.init(rawValue: "updated"), object: nil)
                } else {
                    let errors = json["errors"] as! [String : String]
                    if let phoneError = errors["phoneNumber"] {
                        self?.alert(error: "添加失败", message: phoneError)
                    }
                    
                    if let passwordError = errors["password"] {
                        self?.alert(error: "添加失败", message: passwordError)
                    }
                    
                    if let nameError = errors["studentName"] {
                        self?.alert(error: "添加失败", message: nameError)
                    }
                }
            }
        }
    }
    
    // 修改学生信息
    func editStudent(){
        
        // 检验数据有效性,要求，手机号唯一(接口有问题？必须得更新手机号?)，名字可重复，
        if (item1Text.text?.isEmpty)! {
            alert(error: "提示", message: "学生姓名不能为空")
            return
        }
        
        if (item2Text.text?.isEmpty)! {
            alert(error: "提示", message: "电话号码不能为空")
            return
        }
        
        if !validatePhoneNumber(num: item2Text.text!) {
            alert(error: "提示", message: "无效的电话号码")
        }
        
        if (item3Text.text?.isEmpty)! {
            alert(error: "提示", message: "新密码不能为空")
            return
        }
        let url = URL(string: admin.weteam.baseURL+admin.Method.updateStu)
        let parameter : Parameters = ["id": 3 ,"phoneNumber" : item2Text.text!,"studentName": item1Text.text!,"password": item3Text.text!]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String :Any]{
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: json["msg"] as! String)
                    // 通知studentVC更新数据
                     NotificationCenter.default.post(name: Notification.Name.init(rawValue: "updated"), object: nil)
                } else {
                    let errors = json["errors"] as! [String : String]
                    self?.alert(error: "错误", message: String(describing: errors))
                    if let phoneError = errors["phoneNumber"] {
                        self?.alert(error: "修改失败", message: phoneError)
                    }
                    
                    if let passwordError = errors["password"] {
                        self?.alert(error: "修改失败", message: passwordError)
                    }
                    
                    if let nameError = errors["studentName"] {
                        self?.alert(error: "修改失败", message: nameError)
                    }
                }
            }
        }

    }
    
    // 检验电话号码是否有效
    func validatePhoneNumber(num : String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = num.range(of: regex,options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
