//
//  AccountBaseViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/12/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


enum NetworkError: ErrorType {
    case networkError
    
    case resultError(String, String?)
}



class AccountBaseViewController: UIViewController {
    
    private var _containView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    func setNavBar() {
        // 添加导航栏
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        self.viewBack()
        
        // 设置背景为白色
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func setNavTitle(content: String) {
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = content
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    func setBarButton(content: String, actionGesture: Selector) {
        let rightLabel = UILabel(frame: CGRectMake(globalWidth - 60, 20, 60, 44))
        rightLabel.textColor = UIColor.whiteColor()
        rightLabel.text = content
        rightLabel.font = UIFont.systemFontOfSize(14)
        rightLabel.textAlignment = NSTextAlignment.Right
        rightLabel.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: actionGesture)
        rightLabel.addGestureRecognizer(tap)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel)]
    }
    
    
    func startAnimating() {
        _containView = UIView(frame: CGRectMake((globalWidth - 50)/2, (globalHeight - 50)/2, 50, 50))
        _containView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        _containView!.layer.cornerRadius = 4.0
        _containView!.layer.masksToBounds = true
        
        
        let _activity = UIActivityIndicatorView(frame: CGRectMake(10, 10, 30, 30))
        _activity.color = UIColor.whiteColor()
        _activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        _activity.startAnimating()
        
        _containView!.addSubview(_activity)
        self.view.addSubview(_containView!)
    }
    
    
    func stopAnimating() {
        _containView?.removeFromSuperview()
    }

}

extension AccountBaseViewController {
    
    func preProcessNetworkResult(task: NSURLSessionDataTask, object: AnyObject?, error: NSError?) -> (JSON?, NetworkError?) {
        
        do {
            let json = try handle(task: task, responseObject: object, error: error)
            
            return (json, nil)
            
        } catch NetworkError.networkError {
            self.view.showTipText("网络有点问题，等一会儿再试")
            
        } catch NetworkError.resultError(let _error, let _message) {
            return (nil, NetworkError.resultError(_error, _message))
            
        } catch {
            
        }
        
        return (nil, nil)
    }
    
    
    func handle<T, O: AnyObject, E: Equatable>(task task: T, responseObject: O?, error: E?) throws -> JSON {
        
        if let _ = error {
            throw NetworkError.networkError
        }
        
        if let obj = responseObject {
            let json = JSON(obj)
            
            guard json["error"] == 0 else {
                throw NetworkError.resultError(json["error"].stringValue ,json["message"].string)
            }
            
            return json
            
        } else {
            throw NetworkError.networkError
        }
        
    }
    
}




extension AccountBaseViewController {
    
    /**
     验证昵称是否符合要求
     */
    func validateNickname(name: String) -> Bool {
        if name == "" {
            self.view.showTipText("名字不能是空的...")
            
            return false
        } else if name.characters.count < 2 {
            self.view.showTipText("名字有点短...")
            
            return false
        } else if !name.isValidName() {
            self.view.showTipText("名字里有奇怪的字符...")
            
            return false
        }
        
        return true
    }
    
    
    /**
     验证邮箱是否正确
     */
    func validateEmailAddress(text: String) -> Bool {
        if text == "" {
            return false
        } else if !text.isValidEmail() {
            return false
        }
        
        return true
    }
    
    
    func validateEmailFromTextField(text: String?) -> Bool {
        
        if let _text = text {
            if self.validateEmailAddress(_text) {
                return true
            } else {
                self.view.showTipText("不是地球上的邮箱...")
            }
        } else {
            self.view.showTipText("邮箱不能为空...")
        }
        
        return false
    }
    
    
    func validatePasswordFromTextField(text: String?) -> Bool {
        
        if let _text = text {
            if _text.characters.count > 4 {
                return true
            } else {
                self.view.showTipText("密码至少 4 个字符")
            }
        } else {
           self.view.showTipText("密码不能是空的...")
        }
    
        return false
    }
    
    func validateNameFromTextField(text: String?) -> Bool {
        if let _text = text {
            self.validateNickname(_text)        
        } else {
            self.view.showTipText("名字不能是空的...")
        }
        
        return false
    }
    
    
}

extension AccountBaseViewController {

    func enterHome(json: JSON) -> UINavigationController {

        let shell = json["data"]["shell"].stringValue
        let uid = json["data"]["uid"].stringValue
        
        /// uid 和 shell 保存到 keychain
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        uidKey.setObject(uid, forKey: kSecAttrAccount)
        uidKey.setObject(shell, forKey: kSecValueData)
        
        Api.requestLoad()
        globalWillReEnter = 1
        let mainViewController = HomeViewController(nibName:nil,  bundle: nil)
        
        let navigationViewController = UINavigationController(rootViewController: mainViewController)
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
        navigationViewController.navigationBar.translucent = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        navigationViewController.navigationBar.clipsToBounds = true
        
        Api.postJpushBinding { _ in }
        
        return navigationViewController
    }



}







