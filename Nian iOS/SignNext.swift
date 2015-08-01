//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class SignNextController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate{
    @IBOutlet var loginButton:UIImageView!
    @IBOutlet var loginButtonBorder:UIView!
    @IBOutlet var inputEmail:UITextField!
    @IBOutlet var inputPassword:UITextField!
    @IBOutlet var holder:UIView!
    @IBOutlet var errLabel:UILabel!
    var isAnimate:Int = 0
    var name:String = ""
    
    lazy var signInfo = SignInfo()
    
    func setupViews(){
        self.viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.holder.setX(globalWidth/2-140)
        self.errLabel.setX(globalWidth/2-100)
        
        self.loginButton.layer.cornerRadius = 20
        self.loginButtonBorder.layer.cornerRadius = 25
        self.inputEmail.textColor = UIColor.blackColor()
        self.inputPassword.textColor = UIColor.blackColor()
        self.inputEmail.leftView = UIView(frame: CGRectMake(0, 0, 8, 40))
        self.inputEmail.rightView = UIView(frame: CGRectMake(0, 0, 20, 40))
        self.inputPassword.leftView = UIView(frame: CGRectMake(0, 0, 8, 40))
        self.inputPassword.rightView = UIView(frame: CGRectMake(0, 0, 20, 40))
        self.inputEmail.leftViewMode = UITextFieldViewMode.Always
        self.inputEmail.rightViewMode = UITextFieldViewMode.Always
        self.inputPassword.leftViewMode = UITextFieldViewMode.Always
        self.inputPassword.rightViewMode = UITextFieldViewMode.Always
        self.inputPassword.delegate = self
        self.inputEmail.delegate = self
        
        let attributesDictionary = [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)]
        self.inputEmail.attributedPlaceholder = NSAttributedString(string: "邮箱", attributes: attributesDictionary)
        self.inputPassword.attributedPlaceholder = NSAttributedString(string: "密码", attributes: attributesDictionary)
        
        self.loginButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "loginAlert"))
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "完成注册"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.loginAlert()
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.inputEmail.becomeFirstResponder()
    }
    
    func loginAlert(){
        if self.inputEmail.text == "" {
            SAerr("注册邮箱不能是空的...")
        }else if self.inputPassword.text == "" {
            SAerr("注册密码不能是空的...")
        }else if !self.inputEmail.text.isValidEmail() {
            SAerr("不是地球上的邮箱...")
        }else if SAstrlen(self.inputPassword.text)<4 {
            SAerr("密码太短了...")
        }else{
            var email = SAEncode(SAHtml(self.inputEmail.text))
            var password = ("n*A\(self.inputPassword.text)").md5
            Api.postSignUp(self.signInfo.name!, password: password, email: self.inputEmail.text, daily: self.signInfo.mode!.rawValue) {
                json in
                SAPush("Mua!", NSDate().dateByAddingTimeInterval(Double(60*60*24)))
                
                if json != nil {
                    let error = json!.objectForKey("error") as! NSNumber
                    if error == 0 {
                        let data = json!.objectForKey("data") as! NSDictionary
                        let sa = data.objectForKey("uid") as! String
                        
                        self.holder!.hidden = true
                        self.navigationItem.rightBarButtonItems = buttonArray()
                        var shell = (("\(password)\(sa)n*A").lowercaseString).md5
                        var Sa: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        Sa.setObject(sa, forKey: "uid")
                        Sa.setObject(shell, forKey: "shell")
                        Sa.setObject(self.signInfo.name!, forKey: "user")
                        Sa.synchronize()
                        
//                        var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
//                        var shellKey = KeychainItemWrapper(identifier: "shellKey", accessGroup: nil)
//                        uidKey.setObject(sa, forKey: "uid")
//                        shellKey.setObject(shell, forKey: "shell")
                        
                        Api.requestLoad()
                        
                        var mainViewController = HomeViewController(nibName:nil,  bundle: nil)
                        var navigationViewController = UINavigationController(rootViewController: mainViewController)
                        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
                        navigationViewController.navigationBar.translucent = true
                        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
                        navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                        navigationViewController.navigationBar.clipsToBounds = true
                        self.presentViewController(navigationViewController, animated: true, completion: {
                            self.navigationItem.rightBarButtonItems = []
                        })
                        
                        Api.postDeviceToken() { string in
                        }
                        
                    } else if error == 2 {
                        self.SAerr("邮箱或用户名已注册")
                        
                    }
                }
            }
        }
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.inputEmail.resignFirstResponder()
        self.inputPassword.resignFirstResponder()
    }
    
    func SAerr(message:String){
        self.navigationItem.rightBarButtonItems = []
        shakeAnimation(self.holder)
        if self.isAnimate == 0 {
            self.isAnimate = 1
            UIView.animateWithDuration(0.3, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                self.errLabel.text = message
                self.errLabel.frame.offset(dx: 0, dy: -5)
                self.errLabel.alpha = 1
                }, completion: { (complete: Bool) in
                    UIView.animateWithDuration(0.1, delay:1.2, options: UIViewAnimationOptions.allZeros, animations: {
                        self.errLabel.frame.offset(dx: 0, dy: +5)
                        self.errLabel.alpha = 0
                        }, completion: { (complete: Bool) in
                            self.isAnimate = 0
                    })
            })
        }
    }
    
    func shakeAnimation(view:UIView){
        var viewLayer:CALayer = view.layer
        var position:CGPoint = viewLayer.position
        var x:CGPoint = CGPointMake(position.x + 3 , position.y)
        var y:CGPoint = CGPointMake(position.x - 3 , position.y)
        var animation:CABasicAnimation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(CGPoint: x)
        animation.toValue = NSValue(CGPoint: y)
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = 2
        viewLayer.addAnimation(animation, forKey: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
