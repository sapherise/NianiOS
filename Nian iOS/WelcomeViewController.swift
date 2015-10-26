//
//  WelcomeViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var shouldNavToMe: Bool = false
    /// 如果读取到得 User 的 uid 和 shell 来自 NSUserdefault， 那么就要更新 Keychain
    var needUpdateKeychain: Bool = false
    
    /// 进入 “LogOrRegViewController”
    @IBOutlet weak var logInButton: UIButton!

    @IBOutlet weak var wechatButton: SocialMediaButton!
    @IBOutlet weak var qqButton: SocialMediaButton!
    @IBOutlet weak var weiboButton: SocialMediaButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.logInButton.layer.cornerRadius = 22.0
        self.logInButton.layer.borderWidth = 0.5
        self.logInButton.layer.borderColor = UIColor.colorWithHex("#333333").CGColor
        self.logInButton.layer.masksToBounds = true
        
        /// 读取保存在 keychain 里的 uid 和 shell
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        var cookieuid = uidKey.objectForKey(kSecAttrAccount) as? String
        
        /**
        *  uid 和 shell 由于以前的原因，可能还在 userdefault 里
        */
        if (cookieuid!).characters.count > 0 && cookieuid != "" {
        } else {
            cookieuid = Cookies.get("uid") as? String
        }
        
        if cookieuid != "" && cookieuid != nil {      //如果登录了
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            uidKey.setObject(cookieuid!, forKey: kSecAttrAccount)
            
            let mainViewController = HomeViewController(nibName:nil,  bundle: nil)
            mainViewController.shouldNavToMe = self.shouldNavToMe
            
            let navigationViewController = UINavigationController(rootViewController: mainViewController)
            navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
            navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
            navigationViewController.navigationBar.clipsToBounds = true
            navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            delay(0.3, closure: {
                self.navigationController!.presentViewController(navigationViewController, animated: false, completion: {
                    self.view.hidden = false
                })
            })
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        // toLORVC : to LogOrRegViewController
        if segue.identifier == "toLORVC" {
            
            /*   */
            let logOrRegViewController = segue.destinationViewController as! LogOrRegViewController
            logOrRegViewController.functionalType = FunctionType.confirm
        }

    }

    /*=========================================================================================================================================*/
    
    /**
    
    */
    @IBAction func logInViaWechat(sender: UIButton) {
        
        
        
        
    }
    
    /**
    
    */
    @IBAction func logInViaQQ(sender: UIButton) {
        let permissions = [
            kOPEN_PERMISSION_GET_USER_INFO,
            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
            kOPEN_PERMISSION_ADD_ALBUM,
            kOPEN_PERMISSION_ADD_IDOL,
            kOPEN_PERMISSION_ADD_ONE_BLOG,
            kOPEN_PERMISSION_ADD_PIC_T,
            kOPEN_PERMISSION_ADD_SHARE,
            kOPEN_PERMISSION_ADD_TOPIC,
            kOPEN_PERMISSION_CHECK_PAGE_FANS,
            kOPEN_PERMISSION_DEL_IDOL,
            kOPEN_PERMISSION_DEL_T,
            kOPEN_PERMISSION_GET_FANSLIST,
            kOPEN_PERMISSION_GET_IDOLLIST,
            kOPEN_PERMISSION_GET_INFO,
            kOPEN_PERMISSION_GET_OTHER_INFO,
            kOPEN_PERMISSION_GET_REPOST_LIST,
            kOPEN_PERMISSION_LIST_ALBUM,
            kOPEN_PERMISSION_UPLOAD_PIC,
            kOPEN_PERMISSION_GET_VIP_INFO,
            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
            kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
            kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO
        ]
        
        let oauth = TencentOAuth(appId: "tencent1104358951", andDelegate: self)
        oauth.authorize(permissions, inSafari: false)
    }
    
    /**
    
    */
    @IBAction func logInViaWeibo(sender: UIButton) {
   
    }
    

}


extension WelcomeViewController: TencentLoginDelegate, TencentSessionDelegate {
    /**
    * 登录成功后的回调
    */
    func tencentDidLogin() {
        
    }

    /**
    * 登录失败后的回调
    * \param cancelled 代表用户是否主动退出登录
    */
    func tencentDidNotLogin(cancelled: Bool) {
        
    }

    /**
    * 登录时网络有问题的回调
    */
    func tencentDidNotNetWork() {
        
    }
}



























