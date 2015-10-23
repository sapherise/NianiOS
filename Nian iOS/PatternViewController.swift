//
//  ModelViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/23/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


class PatternViewController: UIViewController {
    
    /// "模式"选中时的颜色
    let c5Color = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
    /// "模式"未选中时的颜色
    let c7Color = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
    
    /// 中间分割线的宽度
    @IBOutlet weak var widthLine: NSLayoutConstraint!
    /// 困难模式的图片
    @IBOutlet weak var toughImageView: UIImageView!
    /// 简单模式的图片
    @IBOutlet weak var simpleImageView: UIImageView!
    /// "困难" label
    @IBOutlet weak var toughLabel: UILabel!
    /// "简单" label
    @IBOutlet weak var simpleLabel: UILabel!
    /// "困难模式"描述 label
    @IBOutlet weak var toughIllustrate: UILabel!
    /// "简单模式"描述 label
    @IBOutlet weak var simpleIllustate: UILabel!
    ///
    @IBOutlet weak var toughView: UIView!
    ///
    @IBOutlet weak var simpleView: UIView!
    ///
    @IBOutlet weak var containerView: UIView!
    /// 中间的分割线
    @IBOutlet var viewLine: UIView!
    ///
    @IBOutlet weak var accompolishButton: CustomButton!
    
    /// 注册时应提供的信息
    var regInfo: RegInfo?
    /// 玩念的模式 -- 困难 or 简单
    var playMode: PlayMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /**
    设置玩念的模式
    */
    func setPlayMode(mode: PlayMode) {
        if mode == PlayMode.easy {
            //        self.toughImageView.image = UIImage(named: "xxx")
            self.simpleLabel.textColor = c5Color
            self.simpleIllustate.textColor = c5Color
            
            //        self.simpleImageView.image = UIImage(named: "zzz")
            self.toughLabel.textColor = c7Color
            self.toughIllustrate.textColor = c7Color
            
            self.playMode = PlayMode.easy
        } else {
            //        self.toughImageView.image = UIImage(named: "xxx")
            self.simpleLabel.textColor = c7Color
            self.simpleIllustate.textColor = c7Color
            
            //        self.simpleImageView.image = UIImage(named: "zzz")
            self.toughLabel.textColor = c5Color
            self.toughIllustrate.textColor = c5Color
            
            self.playMode = PlayMode.hard
        }
    }
    
    /**
    tap 手势 on tough mode view
    */
    @IBAction func touchOnLeftView(sender: UITapGestureRecognizer) {
        setPlayMode(PlayMode.hard)
    }
    
    /**
    tap 手势 on simple mode view
    */
    @IBAction func touchOnRightView(sender: UITapGestureRecognizer) {
        setPlayMode(PlayMode.easy)
    }
    
    /**
    点击“完成” Button, 完成注册
    */
    @IBAction func accompolishRegister(sender: UIButton) {
        self.accompolishButton.startAnimating()
        
        LogOrRegModel.register(email: self.regInfo!.email!,
            password: self.regInfo!.password!,
            username: self.regInfo!.nickname!,
            daily: self.playMode!.rawValue) {
               (task, responseObject, error) in
                self.accompolishButton.stopAnimating()
                
                if let _error = error { // 服务器返回错误
                    logError("\(_error)")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["error"] == 2 { // 服务器返回的数据包含“错误信息”
                        //TODO: json["message"]
                    } else if json["error"] == 0 { // 服务器返回正常，注册成功
                        let shell = json["data"]["shell"].stringValue
                        let uid = json["data"]["uid"].stringValue
                        
                        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                        uidKey.setObject(uid, forKey: kSecAttrAccount)
                        uidKey.setObject(shell, forKey: kSecValueData)
                        
                        Api.requestLoad()
                        
                        let mainViewController = HomeViewController(nibName:nil,  bundle: nil)
                        let navigationViewController = UINavigationController(rootViewController: mainViewController)
                        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
                        navigationViewController.navigationBar.translucent = true
                        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
                        navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                        navigationViewController.navigationBar.clipsToBounds = true
                        self.presentViewController(navigationViewController, animated: true, completion: {
                            self.navigationItem.rightBarButtonItems = []
                        })
                        
                        Api.postDeviceToken() { string in }
                        Api.postJpushBinding() {_ in }
                    }
                    
                }
                
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
