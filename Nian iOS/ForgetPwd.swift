//
//  ForgetPwd.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/23/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ForgetPwd: UIViewController {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var info: UILabel!
    
    private var _rightButton: UIBarButtonItem?
    
    var isAnimate: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        _rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "resetPwd")
        _rightButton!.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [_rightButton!]
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "重置密码"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.email.layer.cornerRadius = 4.0
        self.email.layer.masksToBounds = true
        self.email.delegate = self
        
        self.email.setX(globalWidth/2 - 100)
        self.info.setX(globalWidth/2 - 100)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.email.becomeFirstResponder()
    }

    func resetPwd() {
        self.email.resignFirstResponder()
        
        if !self.email.text.isValidEmail() {
            self.SAerr("不是地球上的邮箱...")
            self.email.becomeFirstResponder()
        } else {
            self.navigationItem.rightBarButtonItems = buttonArray()
            Api.postResetPwd(self.email.text) {
                json in
                if json != nil {
                    var error = json!.objectForKey("error") as! NSNumber
                    
                    if error == 0 {
                        var niAlert = NIAlert()
                        niAlert.delegate = self
                        niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "reset_password")!, "发好了", "重置密码邮件已发送\n快去查收邮件", ["好"]],
                                                           forKeys: ["img", "title", "content", "buttonArray"])
                        
                        niAlert.showWithAnimation(showAnimationStyle.spring)
                    } else {
                        var msg = json!.objectForKey("message") as! String
                        
                        if msg == "The resources is not exist." {
                            self.SAerr("这个邮箱没注册过...")
                        } else if msg == "The request is too busy." {
                            self.SAerr("超出发送限制...")
                        }
                    }
                    
                    self.navigationItem.rightBarButtonItems = [self._rightButton!]
                }
            }
        }
        
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.email.resignFirstResponder()
    }
    
}

// MARK: implement text field delegate
extension ForgetPwd: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.email.resignFirstResponder()
        resetPwd()
        
        return true
    }
}

// MARK: implement alert delegate
extension ForgetPwd: NIAlertDelegate {
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if didselectAtIndex == 0 {
           self.navigationController?.popViewControllerAnimated(true)
        }
    }
}


// MARK: utility function && animation
extension ForgetPwd {
    
    func shakeAnimation(view: UIView) {
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
    
    func SAerr(message: String) {
        shakeAnimation(self.email)
        
        if self.isAnimate == 0 {
            self.isAnimate = 1
            
            UIView.animateWithDuration(0.3, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                self.info.text = message
                self.info.frame.offset(dx: 0, dy: -5)
                self.info.alpha = 1
                }, completion: { (complete: Bool) in
                    UIView.animateWithDuration(0.1, delay:1.2, options: UIViewAnimationOptions.allZeros, animations: {
                        self.info.frame.offset(dx: 0, dy: +5)
                        self.info.alpha = 0
                        }, completion: { (complete: Bool) in
                            self.isAnimate = 0
                    })
            })
        }
    }
}





