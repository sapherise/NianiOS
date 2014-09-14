//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    @IBOutlet var loginButton:UIImageView!
    @IBOutlet var loginButtonBorder:UIView!
    @IBOutlet var inputEmail:UITextField!
    @IBOutlet var inputPassword:UITextField!
    @IBOutlet var holder:UIView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.view.backgroundColor = BGColor
        self.loginButton.layer.cornerRadius = 20
        self.loginButtonBorder.layer.cornerRadius = 25
        self.inputEmail.textColor = BlueColor
        self.inputPassword.textColor = BlueColor
        self.inputEmail.leftView = UIView(frame: CGRectMake(0, 0, 8, 40))
        self.inputEmail.rightView = UIView(frame: CGRectMake(0, 0, 20, 40))
        self.inputPassword.leftView = UIView(frame: CGRectMake(0, 0, 8, 40))
        self.inputPassword.rightView = UIView(frame: CGRectMake(0, 0, 20, 40))
        self.inputEmail.leftViewMode = UITextFieldViewMode.Always
        self.inputEmail.rightViewMode = UITextFieldViewMode.Always
        self.inputPassword.leftViewMode = UITextFieldViewMode.Always
        self.inputPassword.rightViewMode = UITextFieldViewMode.Always
        
        let attributesDictionary = [NSForegroundColorAttributeName: LineColor]
        self.inputEmail.attributedPlaceholder = NSAttributedString(string: "邮箱", attributes: attributesDictionary)
        self.inputPassword.attributedPlaceholder = NSAttributedString(string: "密码", attributes: attributesDictionary)
        
        self.loginButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "loginAlert"))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "登录"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    override func viewDidAppear(animated: Bool) {
        self.inputEmail.becomeFirstResponder()
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func loginAlert(){
        if self.inputEmail.text == "" || self.inputPassword.text == "" {
            shakeAnimation(self.holder)
        }else{
            var email = SAEncode(SAHtml(self.inputEmail.text))
            var password = "n*A\(SAEncode(SAHtml(self.inputPassword.text)))"
            var sa = SAPost("em=\(email)&&pw=\(password.md5)", "http://nian.so/api/login.php")
            if sa == "NO" {
                //self.navigationController.popViewControllerAnimated(true)
                shakeAnimation(self.holder)
            }else{
                    var shell = (("\(password.md5)\(sa)n*A").lowercaseString).md5
                    var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                
                    var username = SAPost("uid=\(sa)", "http://nian.so/api/username.php")
                    Sa.setObject(sa, forKey: "uid")
                    Sa.setObject(shell, forKey: "shell")
                    Sa.setObject(username, forKey:"user")
                    Sa.synchronize()
                    var mainViewController = HomeViewController(nibName:nil,  bundle: nil)
                    mainViewController.selectedIndex = 2
                    var navigationViewController = UINavigationController(rootViewController: mainViewController)
                    navigationViewController.navigationBar.setBackgroundImage(SAColorImg(BGColor), forBarMetrics: UIBarMetrics.Default)
                    navigationViewController.navigationBar.tintColor = IconColor
                    navigationViewController.navigationBar.translucent = false
                    navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
                    navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                    navigationViewController.navigationBar.clipsToBounds = true
                    self.presentViewController(navigationViewController, animated: true) { () -> Void in
                    }
                }
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
