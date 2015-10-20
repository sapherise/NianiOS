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

class LogOrRegViewController: UIViewController {

    // MARK: - 界面上的控件
    
    /// discriotion label 可以设置为 hidden
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    /// 暂定 logIn 和 register 使用同一个密码框
    @IBOutlet weak var passwordTextField: UITextField!
    /// 昵称 -- 在注册的最后一步将重用为“确认昵称”
    @IBOutlet weak var nicknameTextField: UITextField!
    /// functional Button 可以复用为 “确定” “登录” “注册”
    @IBOutlet weak var functionalButton: UIButton!
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
    
    @IBOutlet weak var functionalButtonTopToEmail: NSLayoutConstraint!
    
    // MARK: - Variables
    
    /// functionalButtonType 决定了 functional button 的 text, 并决定 button 的 function
    var functionalButtonType: FunctionType? {
        didSet {
            switch functionalButtonType! {
            case .confirm:
                self.functionalButton.titleLabel?.text = "确定"
            case .logIn:
                self.functionalButton.titleLabel?.text = "登录"
                self.descriptionLabel.hidden = true
            case .register:
                self.functionalButton.titleLabel?.text = "注册"
                self.descriptionLabel.hidden = true
            }
        }
    }

    // MARK: - view controller life recycle     
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.functionalButtonType == .confirm {
            self.passwordTextField.hidden = true
            self.nicknameTextField.hidden = true
            self.forgetPWDButton.hidden = true
            self.privacyContainerView.hidden = true
        }
        
        /* 设置 all textfields 的 delegate  */
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.nicknameTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*   */
        if self.functionalButtonType == .logIn {
        } else if self.functionalButtonType == .register {
            /* 这里应该是注册的最后一步，确认昵称 */
            self.emailTextField.hidden = true
            self.nicknameTextField.hidden = false
            self.descriptionLabel.hidden = false
            self.descriptionLabel.text = "确认昵称"
        }
    }
    
    //MARK: - click on functionalButton 
    
    @IBAction func onFunctionalButton(sender: UIButton) {
        /* 分别处理 “confirm” "logIn" "register" */
        if self.functionalButtonType == .confirm {
            
        } else if self.functionalButtonType == .logIn {
            
        } else if self.functionalButtonType == .register {
            
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

// MARK:
// MARK: - UITextFieldDelegate
extension LogOrRegViewController: UITextFieldDelegate {




}

// MARK: 
// MARK: - 处理事件
extension LogOrRegViewController {
    


}


















