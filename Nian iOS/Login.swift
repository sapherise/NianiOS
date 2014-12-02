//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate{
    @IBOutlet var loginButton:UIImageView!
    @IBOutlet var loginButtonBorder:UIView!
    @IBOutlet var inputEmail:UITextField!
    @IBOutlet var inputPassword:UITextField!
    @IBOutlet var holder:UIView!
    
    func setupViews(){
        viewBack(self)
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        self.view.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        self.loginButton.layer.cornerRadius = 20
        self.loginButtonBorder.layer.cornerRadius = 25
        self.loginButtonBorder.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
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
        self.inputEmail.delegate = self
        self.inputPassword.delegate = self
        
        let attributesDictionary = [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)]
        self.inputEmail.attributedPlaceholder = NSAttributedString(string: "邮箱", attributes: attributesDictionary)
        self.inputPassword.attributedPlaceholder = NSAttributedString(string: "密码", attributes: attributesDictionary)
        
        self.loginButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "loginAlert"))
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "登录"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        delay(1, { () -> () in
            self.inputEmail.becomeFirstResponder()
            return
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.loginAlert()
        return true
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func loginAlert(){
        if self.inputEmail.text == "" || self.inputPassword.text == "" {
            shakeAnimation(self.holder)
        }else{
            self.navigationItem.rightBarButtonItems = buttonArray()
            var email = SAEncode(SAHtml(self.inputEmail.text))
            var password = "n*A\(SAHtml(self.inputPassword.text))"
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("em=\(email)&&pw=\(password.md5)", "http://nian.so/api/login.php")
                dispatch_async(dispatch_get_main_queue(), {
                    if sa == "err"{
                        self.navigationItem.rightBarButtonItems = []
                    }else if sa == "NO" {
                        //self.navigationController.popViewControllerAnimated(true)
                        self.shakeAnimation(self.holder)
                        self.navigationItem.rightBarButtonItems = []
                    }else{
                        self.navigationItem.rightBarButtonItems = buttonArray()
                        var shell = (("\(password.md5)\(sa)n*A").lowercaseString).md5
                        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        var username = SAPost("uid=\(sa)", "http://nian.so/api/username.php")
                        Sa.setObject(sa, forKey: "uid")
                        Sa.setObject(shell, forKey: "shell")
                        Sa.setObject(username, forKey:"user")
                        Sa.synchronize()
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
                        var DeviceToken = Sa.objectForKey("DeviceToken") as? String
                        if DeviceToken != nil {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                var sa = SAPost("devicetoken=\(DeviceToken!)&&uid=\(sa)&&shell=\(shell!)&&type=1", "http://nian.so/api/user_update.php")
                            })
                        }
                    }
                })
            })
        }
    }

    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.inputEmail.resignFirstResponder()
        self.inputPassword.resignFirstResponder()
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
    
    func login(){
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
