//
//  BindEmailViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/5/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

@objc protocol bindEmailDelegate {

    optional func bindEmail(email email: String)
}


enum BindFunctionType: Int {
    case confirm
    case finish
}

/**
 来这一页，绑定邮箱还是修改邮箱
 */
enum ModeType: Int {
    case modify
    case bind
}


class BindEmailViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var emailTextField: NITextfield!
    
    @IBOutlet weak var passwordTextField: NITextfield!
    
    @IBOutlet weak var confirmButton: CustomButton!
    
    @IBOutlet weak var discriptionLabel: UILabel!
    /// email text field 距离顶部的约束
    @IBOutlet weak var emailTextFieldToTop: NSLayoutConstraint!
    /// password text field 顶部到 email text field 的约束
    @IBOutlet weak var pwdTextFieldTopToEmail: NSLayoutConstraint!
    
    @IBOutlet weak var buttonTopToEmail: NSLayoutConstraint!
    
    weak var delegate: bindEmailDelegate?
    
    var previousEmail: String?
    
    var bindFuntionType: BindFunctionType? {
        didSet {
            switch bindFuntionType! {
            case .confirm:
                self.confirmButton.setTitle("确认", forState: .Normal)
            case .finish:
                self.confirmButton.setTitle("完成", forState: .Normal)
            }
        }
    }
    
    var modeType: ModeType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bindFuntionType = .confirm
        
        self.emailTextField.layer.cornerRadius = 22
        self.emailTextField.layer.masksToBounds = true
        self.emailTextField.leftViewMode = .Always
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .Always
        
        if self.modeType == .bind {
            self.passwordTextField.hidden = true
        } else if self.modeType == .modify {
            
            self.discriptionLabel.text = "输入登录密码，以确认你的身份"
            self.emailTextField.hidden = true
        }
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
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
    
    func emailTextFieldDidChange(noti: NSNotification) {
        if self.bindFuntionType == .finish {
            let _textfield = noti.object as! UITextField
            
            if _textfield == self.emailTextField {
                self.view.layoutIfNeeded()
                
                UIView.animateWithDuration(0.4, animations: {
                    self.pwdTextFieldTopToEmail.constant = -44
                    self.emailTextFieldToTop.constant = 131
                    self.buttonTopToEmail.constant = 24
                    
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        if finished {
                            self.passwordTextField.hidden = true
                        }
                })
                
                self.discriptionLabel.hidden = false
                self.bindFuntionType = .confirm
            }
        }
    }
    
    
    
    @IBAction func dismissVC(sender: UIButton) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     <#Description#>
     */
    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    
    @IBAction func onConfirmButton(sender: CustomButton) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        if self.modeType == .bind {
            if self.bindFuntionType == .confirm {
                if let _text = self.emailTextField.text {
                    if _text.isValidEmail() {
                        
                        self.confirmButton.startAnimating()
                        
                        LogOrRegModel.checkEmailValidation(email: _text, callback: {
                            (task, responseObject, error) in
                            
                            self.confirmButton.stopAnimating()
                            
                            if let _ = error {
                                self.view.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                let json = JSON(responseObject!)
                                
                                if json["data"] == "0" {
                                    self.handleBindEmail()
                                } else if json["data"] == "1" {
                                    self.view.showTipText("邮箱已被注册...", delay: 2)
                                    self.bindFuntionType = .confirm
                                }
                            }
                        })

                    } else {
                        self.view.showTipText("不是地球上的邮箱...")
                    }
                } else {
                    self.view.showTipText("绑定邮箱不能为空...")
                }
            } else if self.bindFuntionType == .finish {
                if let _pwdText = self.passwordTextField.text {
                    if _pwdText.characters.count < 4 {
                        self.view.showTipText("密码至少 4 个字符", delay: 1)
                        return
                    }
                    
                    let _email = self.emailTextField.text!
                    let _password = "n*A\(self.passwordTextField.text!)"
                    
                    self.confirmButton.startAnimating()
                    
                    SettingModel.bindEmail(_email, password: _password.md5, callback: {
                        (task, responseObject, error) in
                        
                        self.confirmButton.stopAnimating()
                        
                        if let _ = error {
                            self.view.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            let json = JSON(responseObject!)
                            
                            if json["error"] != 0 {
                                
                            } else {
                                self.view.showTipText("邮箱绑定成功", delay: 1)
                                
                                self.delegate?.bindEmail?(email: self.emailTextField.text!)
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    })
                }
            }
        } else if self.modeType == .modify {
            if let _pwd = self.passwordTextField.text {
                if _pwd.characters.count < 4 {
                    self.view.showTipText("密码至少 4 个字符", delay: 1)
                    return
                }
                
                let _password = "n*A\(self.passwordTextField.text!)"
                self.confirmButton.startAnimating()
                
                LogOrRegModel.logIn(email: self.previousEmail!, password: _password.md5, callback: {
                    (task, responseObject, error) -> Void in
                    
                    self.confirmButton.stopAnimating()
                    self.bindFuntionType = .confirm
                    
                    if let _ = error {
                        self.view.showTipText("网络有点问题，只加载了本地设置")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if json["error"] != 0 {
                            self.view.showTipText("密码错误，无法解除绑定邮箱")
                        } else {
                            self.view.showTipText("解除绑定成功，请输入新的邮箱", delay: 1)
                            
                            self.passwordTextField.hidden = true
                            self.emailTextField.hidden = false
                            self.passwordTextField.text = ""
                            self.discriptionLabel.text = "设置邮箱和密码后，你可以通过\n「邮箱+密码」直接登录念"
                            
                            self.modeType = .bind
                        }
                    }
                })
                
            }
        }
    }
    
}


extension BindEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        return true
    }
    
}


extension BindEmailViewController {

    func handleBindEmail() {
        self.discriptionLabel.hidden = true
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .Always
        
        self.passwordTextField.hidden = false
        
        self.bindFuntionType = .finish
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.4) { () -> Void in
            self.emailTextFieldToTop.constant = 68
            self.pwdTextFieldTopToEmail.constant = 8
            self.buttonTopToEmail.constant = 76
            
            self.view.layoutIfNeeded()
        }
    }


}



















