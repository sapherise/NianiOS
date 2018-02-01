//
//  LogOrRegViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/**
 LogOrRegViewController 上的唯一的复用的 Button 的功能类型
 - confirm:  “确定” --- 检查邮箱是否已注册
 - logIn:
 - register:
 */
enum FunctionType: Int {
    case confirm
    case logIn
    case register
}

class LogOrRegViewController: UIViewController {
    
    // MARK: - 界面上的控件
    
    /// discriotion label 可以设置为 hidden
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: NITextfield!
    /// 暂定 logIn 和 register 使用同一个密码框
    @IBOutlet weak var passwordTextField: NITextfield!
    /// 昵称 -- 在注册的最后一步将重用为“确认昵称”
    @IBOutlet weak var nicknameTextField: NITextfield!
    /// functional Button 可以复用为 “确定” “登录” “注册”
    @IBOutlet weak var functionalButton: CustomButton!
    /// “取消”Button 功能：返回欢迎界面(WelcomeVC)
    @IBOutlet weak var cancelButton: UIButton!
    /// "忘记密码"
    @IBOutlet weak var forgetPWDButton: UIButton!
    /// "隐私政策"的 Container View
    @IBOutlet weak var privacyContainerView: UIView!
    
    // MARK: - 几个需要改变的约束
    
    /// email text field 距离顶部的约束
    @IBOutlet weak var emailTextFieldToTop: NSLayoutConstraint!
    /// password text field 顶部到 email text field 的约束
    @IBOutlet weak var pwdTextFieldTopToEmail: NSLayoutConstraint!
    /// 昵称顶部到 passwoed 的约束 --- nick name 仅在注册时会用到，所以该约束也只有在注册时才有用
    @IBOutlet weak var nicknameTextFieldTopToPwd: NSLayoutConstraint!
    /// 唯一的 button 到 email text field 的约束
    @IBOutlet weak var functionalButtonTopToEmail: NSLayoutConstraint!
    
    // MARK: - Variables
    
    /// functionalType 决定了 functional button 的 text, 并决定 button 的 function
    var functionalType: FunctionType? {
        didSet {
            switch functionalType! {
            case .confirm:
                self.functionalButton?.setTitle("确定", for: UIControlState())
            case .logIn:
                self.functionalButton.setTitle("登录", for: UIControlState())
                self.descriptionLabel.isHidden = true
            case .register:
                self.functionalButton.setTitle("注册", for: UIControlState())
                self.descriptionLabel.isHidden = true
            }
        }
    }
    
    /// 提示用户“重置密码”邮件发送成功
    var niAlert = NIAlert()
    
    // MARK: - view controller life recycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.radius = 22
        self.passwordTextField.radius = 22
        self.nicknameTextField.radius = 22
        
        self.emailTextField.layer.cornerRadius = 22
        self.emailTextField.layer.masksToBounds = true
        self.emailTextField.leftViewMode = .always
        
        // Do any additional setup after loading the view.
        if self.functionalType == .confirm {
            self.passwordTextField.isHidden = true
            self.nicknameTextField.isHidden = true
            self.forgetPWDButton.isHidden = true
            self.privacyContainerView.isHidden = true
        }
        
        /* 设置 all textfields 的 delegate  */
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.nicknameTextField.delegate = self
        
        /// 监听 email textfield 不能有变化
        NotificationCenter.default.addObserver(self,
            selector: #selector(LogOrRegViewController.emailTextFieldDidChange(_:)),
            name: NSNotification.Name.UITextFieldTextDidChange,
            object: self.emailTextField)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.UITextFieldTextDidChange,
            object: self.emailTextField)
    }
    
    
    // MARK: -
    /**
    当在登录或者注册时修改邮箱，将返回 “只有 emailTextField” 的状态
    
    :param: noti <#noti description#>
    */
    func emailTextFieldDidChange(_ noti: Notification) {
        if self.functionalType != .confirm {
            let _textfield = noti.object as! UITextField
            
            if _textfield == self.emailTextField {
                // 返回 “只有 emailTextField” 的状态
                if self.functionalType == .logIn {
                    self.backToOnlyEmailTextField(fromFunctionType: .logIn)
                } else if self.functionalType == .register {
                    self.backToOnlyEmailTextField(fromFunctionType: .register)
                }
            }
        }
    }
    
    /**
     重置密码
     */
    @IBAction func resetPassword(_ sender: UIButton) {
        // 收起键盘
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let _tmpType = self.functionalType
        
        self.functionalButton.startAnimating()
        Api.resetPassword(self.emailTextField.text!) { json in
            if json != nil {
                self.functionalButton.stopAnimating()
                self.functionalType = _tmpType
                if SAValue(json, "error") != "0" {
                    if let j = json as? NSDictionary {
                        let message = j.stringAttributeForKey("message")
                        if message == "The resources is not exist." {
                            self.showTipText("这个邮箱没注册过...")
                        } else {
                            self.showTipText("超出发送限制...")
                        }
                    }
                } else {
                    let niAlert = NIAlert()
                    niAlert.delegate = self
                    niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "reset_password")!, "发好了", "重置密码邮件已发送\n快去查收邮件", ["好"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                }
            }
        }
    }
    
    
    //MARK: - click on functionalButton
    
    @IBAction func onFunctionalButton(_ sender: UIButton) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        self.handleEvent()
    }
    
    /**
     点击空白 dismiss keyboard
     */
    @IBAction func dismissKeyboard(_ sender: UIControl) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /**
     无论何时点击左上角的 cancel button, 都将回到 welcome view controller
     */
    @IBAction func backWelcomeViewController(_ sender: UIButton) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toModeVC" {
            let regInfo = RegInfo(email: self.emailTextField.text!, nickname: self.nicknameTextField.text!, password: self.passwordTextField.text!)
            
            /// 进入选择模式的 xib
            let patternViewController = segue.destination as! PatternViewController
            /// 传递注册时需要的数据
            patternViewController.regInfo = regInfo
        }
        
        if segue.identifier == "toPrivacyVC" {
            let privacyWebView = segue.destination as! PrivacyViewController
            privacyWebView.urlString = "http://nian.so/privacy.php"
        }
        
    }
    
}

// MARK:
// MARK: - UITextFieldDelegate
extension LogOrRegViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if self.functionalType == .confirm {
            if textField == self.emailTextField {
                self.handleEvent()
            }
        } else if self.functionalType == .logIn {
            if textField == self.passwordTextField {
                self.handleEvent()
            }
        } else if self.functionalType == .register {
            if self.passwordTextField.text?.characters.count > 0 && self.nicknameTextField.text?.characters.count > 0 {
                self.handleEvent()
            }
        }
        
        
        return true
    }
    
}


extension LogOrRegViewController {
    /**
     处理 return 键和点击 Button 的事件
     */
    func handleEvent() {
        
        /* 分别处理 “confirm” "logIn" "register" */
        if self.functionalType == .confirm {
            if let _text = self.emailTextField.text {
                if self.validateEmailAddress(_text) {
                    
                    self.functionalButton.startAnimating()
                    Api.checkEmailValidation(self.emailTextField.text!) { json in
                        self.functionalType = .confirm
                        self.functionalButton.stopAnimating()
                        if let j = json as? NSDictionary {
                            let data = j.stringAttributeForKey("data")
                            if data == "0" {
                                self.handleUnregisterEmail()
                            } else if data == "1" {
                                self.handleRegisterEmail()
                            }
                        }
                    }
                } else {  //if self.validateEmailAddress == false
                    self.showTipText("不是地球上的邮箱...")
                }
            } else { // if let _text = self.emailTextField.text == nil
                self.showTipText("邮箱不能为空...")
            }
            
        } else if self.functionalType == .logIn {
            /*@explain: 这里不需要再验证邮箱 */
            if let _pwdText = self.passwordTextField.text {
                if _pwdText.characters.count < 4 {
                    self.showTipText("密码至少 4 个字符")
                    return
                }
                
                let _email = self.emailTextField.text!
                let _password = "n*A\(self.passwordTextField.text!)"
                
                self.functionalButton.startAnimating()
                Api.logIn(_email, password: _password.md5) { json in
                    self.functionalButton.stopAnimating()
                    self.functionalType = .logIn
                    if SAValue(json, "error") != "0" {
                        self.showTipText("邮箱或密码不对...")
                    } else {
                        if let j = json as? NSDictionary {
                            if let data = j.object(forKey: "data") as? NSDictionary {
                                let shell = data.stringAttributeForKey("shell")
                                let uid = data.stringAttributeForKey("uid")
                                let username = data.stringAttributeForKey("username")
                                UserDefaults.standard.set(username, forKey: "user")
                                let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                                uidKey?.setObject(uid, forKey: kSecAttrAccount)
                                uidKey?.setObject(shell, forKey: kSecValueData)
                                Api.requestLoad()
                                
                                /* 使用邮箱来登录 */
                                self.launch(0)
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                            }
                        }
                    }
                }
            }
        } else if self.functionalType == .register {
            if self.passwordTextField.text != "" {
                if self.passwordTextField.text!.characters.count < 4 {
                    self.showTipText("密码至少 4 个字符")
                    return
                }
                
                if let _nickname = self.nicknameTextField.text {
                    if self.validateNickname(_nickname) {
                        
                        self.functionalButton.startAnimating()
                        Api.checkNameAvailability(_nickname) { json in
                            self.functionalButton.stopAnimating()
                            self.functionalType = .register
                            if SAValue(json, "error") == "1" {
                                self.showTipText("昵称被占用...")
                            } else if SAValue(json, "error") == "0" {
                                self.performSegue(withIdentifier: "toModeVC", sender: nil)
                            }
                        }
                    }
                } else { // 没有输入 nickname
                    self.showTipText("名字不能是空的...")
                }
            } else { // 没有输入 password
                self.showTipText("密码不能是空的...")
            }
        }
    }
}


// MARK:
// MARK: - 处理事件
extension LogOrRegViewController {
    
    /**
     验证邮箱是否正确
     */
    func validateEmailAddress(_ text: String) -> Bool {
        if text == "" {
            return false
        } else if !text.isValidEmail() {
            return false
        }
        
        return true
    }
    
    /**
     验证昵称是否符合要求
     */
    func validateNickname(_ name: String) -> Bool {
        if name == "" {
            self.showTipText("名字不能是空的...")
            
            return false
        } else if name.characters.count < 2 {
            self.showTipText("名字有点短...")
            
            return false
        } else if !name.isValidName() {
            self.showTipText("名字里有奇怪的字符...")
            
            return false
        }
        
        return true
    }
    
    /**
     email 未注册，View 进入注册的状态
     */
    func handleUnregisterEmail() {
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .always
        
        self.nicknameTextField.layer.cornerRadius = 22
        self.nicknameTextField.layer.masksToBounds = true
        self.nicknameTextField.leftViewMode = .always
        
        self.passwordTextField.isHidden = false
        self.nicknameTextField.isHidden = false
        self.functionalType = .register
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.emailTextFieldToTop.constant = 48
            self.pwdTextFieldTopToEmail.constant = 8
            self.nicknameTextFieldTopToPwd.constant = 8
            self.functionalButtonTopToEmail.constant = 128
            
            self.view.layoutIfNeeded()
        })
        
        self.privacyContainerView.isHidden = false
    }
    
    /**
     email 已注册，View 进入登陆状态
     */
    func handleRegisterEmail() {
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .always
        
        self.passwordTextField.isHidden = false
        self.functionalType = .logIn
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.emailTextFieldToTop.constant = 48
            self.pwdTextFieldTopToEmail.constant = 8
            self.functionalButtonTopToEmail.constant = 76
            
            self.view.layoutIfNeeded()
        })
        
        self.forgetPWDButton.isHidden = false
        
        self.passwordTextField.becomeFirstResponder()
    }
    
    /**
     返回只有 email text field 的状态
     
     :param: type: 返回之前的 functional type
     */
    func backToOnlyEmailTextField(fromFunctionType type: FunctionType) {
        if type == .logIn {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.4, animations: {
                self.pwdTextFieldTopToEmail.constant = -44
                self.functionalButtonTopToEmail.constant = 24
                
                self.emailTextFieldToTop.constant = 111
                
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    if finished {
                        self.passwordTextField.isHidden = true
                    }
            })
            
        } else if type == .register {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.4, animations: {
                self.pwdTextFieldTopToEmail.constant = -44
                self.nicknameTextFieldTopToPwd.constant = -44
                self.functionalButtonTopToEmail.constant = 24
                
                self.emailTextFieldToTop.constant = 111
                
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    if finished {
                        self.passwordTextField.isHidden = true
                        self.nicknameTextField.isHidden = true
                    }
            })
        }
        
        self.functionalType = .confirm
    }
}

// MARK: - NIAlert Delegate
extension LogOrRegViewController: NIAlertDelegate {
    
    func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int) {
        niAlert.dismissWithAnimation(.normal)
    }
    
    func niAlert(_ niAlert: NIAlert, tapBackground: Bool) {
        niAlert.dismissWithAnimation(.normal)
    }
    
}




