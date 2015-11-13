//
//  LogOrRegViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

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

class LogOrRegViewController: AccountBaseViewController {
    
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
                self.functionalButton?.setTitle("确定", forState: .Normal)
            case .logIn:
                self.functionalButton.setTitle("登录", forState: .Normal)
                self.descriptionLabel.hidden = true
            case .register:
                self.functionalButton.setTitle("注册", forState: .Normal)
                self.descriptionLabel.hidden = true
            }
        }
    }
    
    // MARK: - view controller life recycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.radius = 22
        self.passwordTextField.radius = 22
        self.nicknameTextField.radius = 22
        
        self.emailTextField.layer.cornerRadius = 22
        self.emailTextField.layer.masksToBounds = true
        self.emailTextField.leftViewMode = .Always
        
        // Do any additional setup after loading the view.
        if self.functionalType == .confirm {
            self.passwordTextField.hidden = true
            self.nicknameTextField.hidden = true
            self.forgetPWDButton.hidden = true
            self.privacyContainerView.hidden = true
        }
        
        /* 设置 all textfields 的 delegate  */
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.nicknameTextField.delegate = self
        
        /// 监听 email textfield 不能有变化
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "emailTextFieldDidChange:",
            name: UITextFieldTextDidChangeNotification,
            object: self.emailTextField)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextFieldTextDidChangeNotification,
            object: self.emailTextField)
    }
    
    
    // MARK: -
    /**
    当在登录或者注册时修改邮箱，将返回 “只有 emailTextField” 的状态
    
    :param: noti <#noti description#>
    */
    func emailTextFieldDidChange(noti: NSNotification) {
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
    @IBAction func resetPassword(sender: UIButton) {
        // 收起键盘
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        let _tmpType = self.functionalType
        
        self.functionalButton.startAnimating()
        
        LogOrRegModel.resetPaeeword(email: self.emailTextField.text!) {
            (task, responseObject, error) in
            
            self.functionalButton.stopAnimating()
            self.functionalType = _tmpType
            
            let (_, errorResult) = self.preProcessNetworkResult(task, object: responseObject, error: error)
            
            if let _errorResult = errorResult {
                switch _errorResult {
                case .resultError(_, let _message):
                    if _message == "The resources is not exist." {
                        self.view.showTipText("这个邮箱没注册过...")
                    } else if _message == "The request is too busy." {
                        self.view.showTipText("超出发送限制...")
                    }
                    
                default:
                    break
                }
            
            } else {
                
                let niAlert = NIAlert()
                niAlert.delegate = self
                
                niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "reset_password")!, "发好了", "重置密码邮件已发送\n快去查收邮件", ["好"]],
                    forKeys: ["img", "title", "content", "buttonArray"])
                
                niAlert.showWithAnimation(showAnimationStyle.spring)
                
            }
        }
        
        
    }
    
    
    //MARK: - click on functionalButton
    
    @IBAction func onFunctionalButton(sender: UIButton) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        self.handleEvent()
    }
    
    /**
     点击空白 dismiss keyboard
     */
    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    /**
     无论何时点击左上角的 cancel button, 都将回到 welcome view controller
     */
    @IBAction func backWelcomeViewController(sender: UIButton) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toModeVC" {
            let regInfo = RegInfo(email: self.emailTextField.text!, nickname: self.nicknameTextField.text!, password: self.passwordTextField.text!)
            
            /// 进入选择模式的 xib
            let patternViewController = segue.destinationViewController as! PatternViewController
            /// 传递注册时需要的数据
            patternViewController.regInfo = regInfo
        }
        
        if segue.identifier == "toPrivacyVC" {
            let privacyWebView = segue.destinationViewController as! PrivacyViewController
            privacyWebView.urlString = "http://nian.so/privacy.php"
        }
        
    }
    
}

// MARK:
// MARK: - UITextFieldDelegate
extension LogOrRegViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
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
            
            if self.validateEmailFromTextField(self.emailTextField.text) {
                self.functionalButton.startAnimating()
                
                LogOrRegModel.checkEmailValidation(email: self.emailTextField.text!, callback: {
                    (task, responseObject, error) -> Void in
                   
                    self.functionalType = .confirm
                    self.functionalButton.stopAnimating()
                    
                    let (_json, errorResult) = self.preProcessNetworkResult(task, object: responseObject, error: error)
                    
                    if let _ = errorResult {
                        self.view.showTipText("网络有点问题，等一会儿再试")
                    } else {
                        if _json!["data"] == "0" {  // email 未注册
                            // 处理未注册
                            self.handleUnregisterEmail()
                        } else if _json!["data"] == "1" { // email 已注册
                            // 处理登陆
                            self.handleRegisterEmail()
                        }
                    }
                })
                
            }

        } else if self.functionalType == .logIn {
            /*@explain: 这里不需要再验证邮箱 */
            
            if self.validatePasswordFromTextField(self.passwordTextField.text!) {
                
                let _email = self.emailTextField.text!
                let _password = "n*A\(self.passwordTextField.text!)"
                
                self.functionalButton.startAnimating()
                
                LogOrRegModel.logIn(email: _email, password: _password.md5, callback: {
                    (task, responseObject, error) -> Void in
                    
                    self.functionalButton.stopAnimating()
                    self.functionalType = .logIn
                    
                    let (_json, errorResult) = self.preProcessNetworkResult(task, object: responseObject, error: error)
                    
                    if let _error = errorResult {
                        switch _error {
                        case .resultError(_, _):
                            self.view.showTipText("邮箱或密码不对...")
                        default:
                            break
                        }
                    } else {
                        let username = _json!["data"]["username"].stringValue
                        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "user")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.presentViewController(self.enterHome(_json!), animated: true, completion: {
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                        })
                    }
                    
                    
                })
                
                
            }
            
        } else if self.functionalType == .register {
            
            if self.validatePasswordFromTextField(self.passwordTextField.text) && self.validateNameFromTextField(self.nicknameTextField.text) {
                self.functionalButton.startAnimating()
                
                LogOrRegModel.checkNameAvailability(name: self.nicknameTextField.text!, callback: {
                    (task, responseObject, error) -> Void in
                    
                    self.functionalButton.stopAnimating()
                    self.functionalType = .register
                    
                    let (_, errorResult) = self.preProcessNetworkResult(task, object: responseObject, error: error)
                    
                    if let _error = errorResult {
                        switch _error {
                        case .resultError(let __error, _):
                            if __error == "1" {
                                self.view.showTipText("昵称被占用...")
                            }
                        default:
                            break
                        }
                        
                    } else {
                        self.performSegueWithIdentifier("toModeVC", sender: nil)
                    }
                })
            }
        }
    }
    
}


// MARK:
// MARK: - 处理事件
extension LogOrRegViewController {

    /**
     email 未注册，View 进入注册的状态
     */
    func handleUnregisterEmail() {
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .Always
        
        self.nicknameTextField.layer.cornerRadius = 22
        self.nicknameTextField.layer.masksToBounds = true
        self.nicknameTextField.leftViewMode = .Always
        
        self.passwordTextField.hidden = false
        self.nicknameTextField.hidden = false
        self.functionalType = .register
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, animations: {
            self.emailTextFieldToTop.constant = 48
            self.pwdTextFieldTopToEmail.constant = 8
            self.nicknameTextFieldTopToPwd.constant = 8
            self.functionalButtonTopToEmail.constant = 128
            
            self.view.layoutIfNeeded()
        })
        
        self.privacyContainerView.hidden = false
    }
    
    /**
     email 已注册，View 进入登陆状态
     */
    func handleRegisterEmail() {
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .Always
        
        self.passwordTextField.hidden = false
        self.functionalType = .logIn
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4, animations: {
            self.emailTextFieldToTop.constant = 48
            self.pwdTextFieldTopToEmail.constant = 8
            self.functionalButtonTopToEmail.constant = 76
            
            self.view.layoutIfNeeded()
        })
        
        self.forgetPWDButton.hidden = false
        
        self.passwordTextField.becomeFirstResponder()
    }
    
    /**
     返回只有 email text field 的状态
     
     :param: type: 返回之前的 functional type
     */
    func backToOnlyEmailTextField(fromFunctionType type: FunctionType) {
        if type == .logIn {
            
            self.view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.4, animations: {
                self.pwdTextFieldTopToEmail.constant = -44
                self.functionalButtonTopToEmail.constant = 24
                
                self.emailTextFieldToTop.constant = 111
                
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    if finished {
                        self.passwordTextField.hidden = true
                    }
            })
            
        } else if type == .register {
            
            self.view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.4, animations: {
                self.pwdTextFieldTopToEmail.constant = -44
                self.nicknameTextFieldTopToPwd.constant = -44
                self.functionalButtonTopToEmail.constant = 24
                
                self.emailTextFieldToTop.constant = 111
                
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    if finished {
                        self.passwordTextField.hidden = true
                        self.nicknameTextField.hidden = true
                    }
            })
        }
        
        self.functionalType = .confirm
    }
}

// MARK: - NIAlert Delegate
extension LogOrRegViewController: NIAlertDelegate {
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        niAlert.dismissWithAnimation(.normal)
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        niAlert.dismissWithAnimation(.normal)
    }
    
}




