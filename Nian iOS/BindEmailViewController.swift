//
//  BindEmailViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/5/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

@objc protocol bindEmailDelegate {

    @objc optional func bindEmail(email: String)
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
                self.confirmButton.setTitle("好", for: UIControlState())
            case .finish:
                self.confirmButton.setTitle("完成", for: UIControlState())
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
        self.emailTextField.leftViewMode = .always
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .always
        
        if self.modeType == .bind {
            self.passwordTextField.isHidden = true
        } else if self.modeType == .modify {
            
            self.discriptionLabel.text = "输入密码来换一个\n登录邮箱"
            self.emailTextField.isHidden = true
        }
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(BindEmailViewController.emailTextFieldDidChange(_:)),
                                            name: NSNotification.Name.UITextFieldTextDidChange,
                                            object: self.emailTextField)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                            name: NSNotification.Name.UITextFieldTextDidChange,
                                            object: self.emailTextField)
    }
    
    func emailTextFieldDidChange(_ noti: Notification) {
        if self.bindFuntionType == .finish {
            let _textfield = noti.object as! UITextField
            
            if _textfield == self.emailTextField {
                self.view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.pwdTextFieldTopToEmail.constant = -44
                    self.emailTextFieldToTop.constant = 131
                    self.buttonTopToEmail.constant = 24
                    
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        if finished {
                            self.passwordTextField.isHidden = true
                        }
                })
                
                self.discriptionLabel.isHidden = false
                self.bindFuntionType = .confirm
            }
        }
    }
    
    
    
    @IBAction func dismissVC(_ sender: UIButton) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     <#Description#>
     */
    @IBAction func dismissKeyboard(_ sender: UIControl) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    @IBAction func onConfirmButton(_ sender: CustomButton) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if self.modeType == .bind {
            if self.bindFuntionType == .confirm {
                if let _text = self.emailTextField.text {
                    if _text.isValidEmail() {
                        
                        self.confirmButton.startAnimating()
                        Api.checkEmailValidation(_text) { json in
                            if json != nil {
                                if SAValue(json, "error") != "0" {
                                    self.showTipText("网络有点问题，等一会儿再试")
                                } else {
                                    if SAValue(json, "data") == "0" {
                                       self.handleBindEmail()
                                    } else if SAValue(json, "data") == "1" {
                                        self.showTipText("邮箱已被注册...")
                                        self.bindFuntionType = .confirm
                                    }
                                }
                            }
                        }
                    } else {
                        self.showTipText("不是地球上的邮箱...")
                    }
                } else {
                    self.showTipText("绑定邮箱不能为空...")
                }
            } else if self.bindFuntionType == .finish {
                if let _pwdText = self.passwordTextField.text {
                    if _pwdText.characters.count < 4 {
                        self.showTipText("密码至少 4 个字符")
                        return
                    }
                    
                    let _email = self.emailTextField.text!
                    let _password = ("n*A\(self.passwordTextField.text!)").md5
                    let shell = (("\(_password)\(SAUid())n*A").lowercased()).md5
                    
                    self.confirmButton.startAnimating()
                    
                    Api.bindEmail(_email, password: _password!) { json in
                        if json != nil {
                            if SAValue(json, "error") != "0" {
                                self.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                                uidKey?.setObject(shell, forKey: kSecValueData)
                                self.showTipText("邮箱绑定成功")
                                self.delegate?.bindEmail?(email: self.emailTextField.text!)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        } else if self.modeType == .modify {
            if let _pwd = self.passwordTextField.text {
                if _pwd.characters.count < 4 {
                    self.showTipText("密码至少 4 个字符")
                    return
                }
                
                let _password = "n*A\(self.passwordTextField.text!)"
                self.confirmButton.startAnimating()
                Api.logIn(self.previousEmail!, password: _password.md5) { json in
                    if json != nil {
                        if SAValue(json, "error") != "0" {
                            self.showTipText("密码不对...")
                        } else {
                            self.passwordTextField.isHidden = true
                            self.emailTextField.isHidden = false
                            self.passwordTextField.text = ""
                            self.discriptionLabel.text = "设置邮箱和密码后\n你可以用新的邮箱来登录念"
                            self.modeType = .bind
                        }
                    }
                }
            }
        }
    }
    
}


extension BindEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        return true
    }
    
}


extension BindEmailViewController {

    func handleBindEmail() {
        self.discriptionLabel.isHidden = true
        
        self.passwordTextField.layer.cornerRadius = 22
        self.passwordTextField.layer.masksToBounds = true
        self.passwordTextField.leftViewMode = .always
        
        self.passwordTextField.isHidden = false
        
        self.bindFuntionType = .finish
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.emailTextFieldToTop.constant = 68
            self.pwdTextFieldTopToEmail.constant = 8
            self.buttonTopToEmail.constant = 76
            
            self.view.layoutIfNeeded()
        }) 
    }


}



















