//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SignViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate{
    @IBOutlet var inputName:UITextField!
    @IBOutlet var holder:UIView!
    @IBOutlet var errLabel:UILabel!
    var isAnimate:Int = 0
    
    lazy var signInfo = SignInfo()
    
    func setupViews(){
        self.viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        self.inputName.textColor = UIColor.blackColor()
        self.inputName.textAlignment = NSTextAlignment.Center
        let attributesDictionary = [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)]
        self.inputName.attributedPlaceholder = NSAttributedString(string: "昵称", attributes: attributesDictionary)
        self.inputName.delegate = self
        
        self.holder.setX(globalWidth/2-140)
        self.errLabel.setX(globalWidth/2-100)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "注册"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.errLabel.alpha = 0
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.checkName()
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.inputName!.becomeFirstResponder()
    }
    
    func checkName(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        if self.inputName.text == "" {
            self.SAerr("名字不能是空的...")
        }else if SAstrlen(self.inputName.text)<4 {
            self.SAerr("名字有点短...")
        }else if SAstrlen(self.inputName.text)>30 {
            self.SAerr("名字太长了...")
        }else if !self.inputName.text.isValidName() {
            self.SAerr("名字里有奇怪的字符...")
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var name = self.inputName.text
                name = SAEncode(SAHtml(name))
                var sa = SAPost("name=\(name)", "http://nian.so/api/sign_checkname.php")
                if sa != "" && sa != "err" {
                    if sa == "NO" {
                        dispatch_async(dispatch_get_main_queue(), {
                        self.SAerr("有人取这个名字了...")
                        })
                    }else if sa == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.signInfo.name = name
                            var modeVC = ModeViewController(nibName: "ModeViewController", bundle: nil)
                            modeVC.signInfo = self.signInfo
                            self.navigationController?.pushViewController(modeVC, animated: true)
                        })
                    }
                }
            })
        }
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
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.inputName.resignFirstResponder()
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


class SignInfo: NSObject {
    var name: String?
    var mode: PlayMode?
}



