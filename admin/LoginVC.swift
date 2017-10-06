//
//  LoginVC.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController {
    // MARK: Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var passwdText: UITextField!
    @IBOutlet weak var vcodeText: UITextField!
    @IBOutlet weak var vcodeView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: admin.Method.getVCode)
        Alamofire.request(url!).responseData{[weak self] response in
            if let data = response.data {
                self?.vcodeView.image = UIImage(data: data)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func LoginAction(_ sender: Any) {
        // 表格检验
        if (phoneText.text?.isEmpty)!{
            alert(error: "登录失败", message: "请输入管理员账号")
            return 
        }
        if (passwdText.text?.isEmpty)! {
            alert(error: "登录失败", message: "请输入密码")
            return
        }
        if (vcodeText.text?.isEmpty)! {
            alert(error: "登录失败", message: "请输入验证码")
            return
        }
        let url = URL(string: admin.Method.login)
        let parameter : Parameters = ["adminName": phoneText.text!, "adminVCode": vcodeText.text!, "password": passwdText.text!]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String: Any] {
                if json["errors"] == nil {
                    UserDefaults.standard.set(self?.phoneText.text! ,forKey: "phoneNum")
                    self?.saveCookies(response: response)
                    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                } else {
                    let error = json["errors"] as! [String : String]
                    // 这里有bug,有三种错误情况
                    if let vcodeError = error["adminVCode"]{
                        self?.alert(error: "登录失败", message: vcodeError)
                    }
                    if let passwordError = error["password"] {
                        self?.alert(error: "登录失败", message: passwordError)
                    }
                    if let adminError = error["adminName"]{
                        self?.alert(error: "登录失败", message: adminError)
                    }
                }
            }
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.login()
    }
    
    // 刷新验证码
    @IBAction func refreshVCode(_ sender: Any) {
        let url = URL(string: admin.Method.getVCode)
        Alamofire.request(url!).responseData{[weak self] response in
            if let data = response.data {
                self?.vcodeView.image = UIImage(data: data)
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
    
    // 保存登录状态
    func saveCookies(response: DataResponse<Any>) {
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        let  cookies = HTTPCookieStorage.shared.cookies!
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        print("保存cookieArray\(cookieArray)")
        UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
        print("保存cookie成功")
        UserDefaults.standard.synchronize()
    }
}
