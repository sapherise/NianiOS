//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class WelcomeViewController: UIViewController {
    
    func setupViews(){
        var width = self.view.frame.size.width  //宽度
        var height = self.view.frame.size.height   //高度
        println(height)
        
        self.view.hidden = true
        self.view.backgroundColor = BGColor
        
        
        var login:UIButton = UIButton(frame: CGRectMake(20, height-48-64-20, 280, 48))
        login.setTitle("登录", forState: UIControlState.Normal)
        login.layer.borderColor = LineColor.CGColor
        login.layer.borderWidth = 1
        login.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        login.titleLabel!.font = UIFont(name: "system", size: 17)
        login.setTitleColor(IconColor, forState: UIControlState.Normal)
        
        var sign:UIButton = UIButton(frame: CGRectMake(20, height-48-64-20-47, 280, 48))
        sign.setTitle("注册", forState: UIControlState.Normal)
        sign.layer.borderColor = LineColor.CGColor
        sign.layer.borderWidth = 1
        sign.addTarget(self, action: "sign", forControlEvents: UIControlEvents.TouchUpInside)
        sign.titleLabel!.font = UIFont(name: "system", size: 17)
        sign.setTitleColor(IconColor, forState: UIControlState.Normal)
        
        self.view.addSubview(login)
        self.view.addSubview(sign)
        
        var des:UILabel = UILabel(frame: CGRectMake(20, 80, width-40, 128))
        var content:String = "在这个宇宙最残酷\n记梦应用里，\n只有每天坚持\n更新你的梦想，\n才不会被停用账号。"
        des.font = UIFont.systemFontOfSize(14)
        des.setHeight(128)
        des.text = content
        des.numberOfLines = 0
        des.textAlignment = NSTextAlignment.Center
        des.textColor = IconColor
        self.view.addSubview(des)
    }
    
    func login(){
        self.navigationController!.pushViewController(LoginViewController(nibName: "Login", bundle: nil), animated: true)
    }
    func sign(){
        self.navigationController!.pushViewController(SignViewController(nibName: "Sign", bundle: nil), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var cookieuid: String? = Sa.objectForKey("uid") as? String
        if cookieuid == nil {
            self.view.hidden = false
        }else{
            var mainViewController = HomeViewController(nibName:nil,  bundle: nil)
            mainViewController.selectedIndex = 2
            var navigationViewController = UINavigationController(rootViewController: mainViewController)
            navigationViewController.navigationBar.setBackgroundImage(SAColorImg(BGColor), forBarMetrics: UIBarMetrics.Default)
            navigationViewController.navigationBar.tintColor = IconColor
            navigationViewController.navigationBar.translucent = false
            navigationViewController.navigationBar.clipsToBounds = true
            navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
            self.presentViewController(navigationViewController, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
