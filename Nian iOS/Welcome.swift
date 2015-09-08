//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    /// 是否 nav 到私信界面，对应的是启动时是否是从 NSNotification 启动的。 
    var shouldNavToMe = false
    
    func setupViews(){
        self.view.hidden = true
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        let login:UIButton = UIButton(frame: CGRectMake(globalWidth/2 - 100, globalHeight-60-60, 200, 44))
        login.setTitle("登录", forState: UIControlState.Normal)
        login.layer.borderColor = UIColor.blackColor().CGColor
        login.layer.borderWidth = 1
        login.layer.cornerRadius = 4
        login.layer.masksToBounds = true
        login.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        login.titleLabel!.font = UIFont(name: "system", size: 17)
        login.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        let sign:UIButton = UIButton(frame: CGRectMake(globalWidth/2 - 100, globalHeight-60-60-56, 200, 44))
        sign.setTitle("注册", forState: UIControlState.Normal)
        sign.layer.borderColor = UIColor.blackColor().CGColor
        sign.backgroundColor = UIColor.blackColor()
        sign.layer.borderWidth = 1
        sign.layer.cornerRadius = 4
        sign.layer.masksToBounds = true
        sign.addTarget(self, action: "sign", forControlEvents: UIControlEvents.TouchUpInside)
        sign.titleLabel!.font = UIFont(name: "system", size: 17)
        sign.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        let privacy = UILabel(frame: CGRectMake(globalWidth/2 - 80, globalHeight - 60, 160, 30))
        privacy.text = "使用念，就表示你同意\n念的使用条款和隐私政策"
        privacy.font = UIFont.systemFontOfSize(9)
        privacy.textColor = UIColor.blackColor()
        privacy.textAlignment = NSTextAlignment.Center
        privacy.numberOfLines = 2
        privacy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPrivacyClick"))
        privacy.userInteractionEnabled = true
        self.view.addSubview(privacy)
        
        self.view.addSubview(login)
        self.view.addSubview(sign)
        
        let des:UILabel = UILabel(frame: CGRectMake(20, 120, globalWidth-40, 128))
        let content:String = "在这个宇宙最残酷的\n记录应用里\n只有每天坚持更新\n才不会被停用账号"
        des.font = UIFont.systemFontOfSize(14)
        des.setHeight(128)
        des.text = content
        des.numberOfLines = 0
        des.textAlignment = NSTextAlignment.Center
        des.textColor = UIColor.blackColor()
        self.view.addSubview(des)
        
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var cookieuid: String?
        
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        cookieuid = uidKey.objectForKey(kSecAttrAccount) as? String
        
        if (cookieuid!).characters.count > 0 && cookieuid != "" {
        } else {
            cookieuid = Sa.objectForKey("uid") as? String
        }
        
            if cookieuid != "" {      //如果登录了
                    let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                    uidKey.setObject(cookieuid, forKey: kSecAttrAccount)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let mainViewController = HomeViewController(nibName:nil,  bundle: nil)
                        mainViewController.shouldNavToMe = self.shouldNavToMe
                        let navigationViewController = UINavigationController(rootViewController: mainViewController)
                        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
                        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
                        navigationViewController.navigationBar.clipsToBounds = true
                        navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
                        
                        delay(0.3, closure: {
                            self.navigationController!.presentViewController(navigationViewController, animated: false, completion: {
                                self.view.hidden = false
                            })
                        })
                    })
            } else { // 没有登录
                self.view.hidden = false
            }
    }
    
    func onPrivacyClick(){
        let web = WebViewController()
        web.urlString = "http://nian.so/privacy.php"
        web.webTitle = "隐私政策"
        self.navigationController!.pushViewController(web, animated: true)
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
        super.viewDidAppear(animated)
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
