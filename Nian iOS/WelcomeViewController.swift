//
//  WelcomeViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    /// 如果读取到得 User 的 uid 和 shell 来自 NSUserdefault， 那么就要更新 Keychain
    var needUpdateKeychain: Bool = false
    
    /// 进入 “LogOrRegViewController”
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var wechatButton: SocialMediaButton!
    @IBOutlet weak var qqButton: SocialMediaButton!
    @IBOutlet weak var weiboButton: SocialMediaButton!
    
    var oauth: TencentOAuth?
    lazy var thirdPartyType = String()
    lazy var thirdPartyID = String()
    lazy var thirdPartyName = String()
    var hasRegistered = false

    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.logInButton.layer.cornerRadius = 22.0
        self.logInButton.layer.borderWidth = 0.5
        self.logInButton.layer.borderColor = UIColor.colorWithHex("#333333").CGColor
        self.logInButton.layer.masksToBounds = true
        
        // 先隐藏欢迎界面
        self.view.hidden = true
        
        if let _uid = CurrentUser.sharedCurrentUser.uid {      //如果登录了
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            uidKey.setObject(_uid, forKey: kSecAttrAccount)
            
            /* 普通启动 */
            launch()
            
            delay(1, closure: { () -> () in
                self.view.hidden = false
            })
        } else {  // 没有登录
            /* 留在当前页面 */
            self.view.hidden = false
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLogInViaWeibo:", name: "weibo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLogInViaWechat:", name: "Wechat", object: nil)
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Weibo", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Wechat", object: nil)
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
        
        if segue.identifier == "toConfirm3rdLogIn" {
            let nicknameViewController = segue.destinationViewController as! NicknameViewController
            nicknameViewController.originalType = self.thirdPartyType
            nicknameViewController.id = self.thirdPartyID
            nicknameViewController.nameFrom3rd = self.thirdPartyName
            nicknameViewController.hasRegistered = self.hasRegistered
        }

    }

    /*=========================================================================================================================================*/
    
    // MARK: - 3rd 登录 Button Action
    
    /**
    
    */
    @IBAction func logInViaWechat(sender: UIButton) {
        if WXApi.isWXAppInstalled() {
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            
            WXApi.sendReq(req)
        } else {
            self.showTipText("未安装微信...")
        }
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
        
        oauth = TencentOAuth(appId: "1104358951", andDelegate: self)
        oauth!.authorize(permissions, inSafari: false)
    }
    
    /**
    
    */
    @IBAction func logInViaWeibo(sender: UIButton) {
        let request = WBAuthorizeRequest()
        request.redirectURI = "https://api.weibo.com/oauth2/default.html"
        request.scope = "all"
        request.userInfo = ["SSO_From": "WelcomeViewController"]
        WeiboSDK.sendRequest(request)
    }
    

}

// MARK: - 实现 QQ 登录的相关代理
extension WelcomeViewController: TencentLoginDelegate, TencentSessionDelegate {
    /**
    * 登录成功后的回调
    */
    func tencentDidLogin() {
        guard let openid = oauth?.openId else {
            return
        }
        
        guard let appid = oauth?.appId else {
            return
        }
        
        guard let accessToken = oauth?.accessToken else {
            return
        }
        
        if openid.characters.count > 0 && appid.characters.count > 0 && accessToken.characters.count > 0 {
            
            LogOrRegModel.getQQName(accessToken, openid: openid, appid: appid) {
                (task, responseObject, error) in
                
                if let _ = error {
                    self.showTipText("网络有点问题，等一会儿再试")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["ret"].numberValue != 0 {
                        self.showTipText("QQ 授权不成功...")
                    } else {
                        let _name = json["nickname"].stringValue
                        
                        if _name.characters.count > 0 {
                            self.logInVia3rdHelper(openid, nameFrom3rd: _name, type: "QQ")
                        }
                    }
                }
            }
            
        } else {
            self.showTipText("QQ 授权不成功...")
        }
        
    }

    /**
    * 登录失败后的回调
    * param cancelled 代表用户是否主动退出登录
    */
    func tencentDidNotLogin(cancelled: Bool) {
        
    }

    /**
    * 登录时网络有问题的回调
    */
    func tencentDidNotNetWork() {
        
    }
}

// MARK: - 处理“跳转微信或微博返回的结果”的相关通知
extension WelcomeViewController {

    /**
     接收到微博登录的结果之后， appDelegate 会发送通知，通知里包含相关的 uid 和 token
     
     :param: noti <#noti description#>
     */
    func handleLogInViaWeibo(noti: NSNotification) {
        guard let notiObject = noti.object else {
            return
        }
        
        if (notiObject as! NSArray).count > 0 {
            let weiboUid = (notiObject as! NSArray)[0] as? String
            let accessToken = (notiObject as! NSArray)[1] as? String
            
            if weiboUid != nil && accessToken != nil {
                LogOrRegModel.getWeiboName(accessToken!, openid: weiboUid!) {
                   (task, responseObject, error) in
                    
                    if let _ = error {
                        self.showTipText("网络有点问题，等一会儿再试")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if let _ = json["error"].string {
                            self.showTipText("微博授权不成功...")
                        } else {
                            let _name = json["name"].stringValue
                            
                            if _name.characters.count > 0 {
                                self.logInVia3rdHelper(weiboUid!, nameFrom3rd: _name, type: "weibo")
                            }
                        }
                    }
                }
                
                
            }
            
        } else {
            self.showTipText("微博授权不成功...")
        }
        
        
    }
    
    /**
     <#Description#>
     
     :param: noti <#noti description#>
     */
    func handleLogInViaWechat(noti: NSNotification) {
        guard let notiObject = noti.object else {
            return
        }
        
        if let openid = (notiObject as! NSDictionary)["openid"] as? String {
            if let accessToken = (notiObject as! NSDictionary)["access_token"] as? String {
                LogOrRegModel.getWechatName(accessToken, openid: openid) {
                    (task, responseObject, error) in
                    
                    if let _ = error {
                        self.showTipText("网络有点问题，等一会儿再试")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if let _ = json["errcode"].number {
                            self.showTipText("微信授权不成功...")
                        } else {
                            let _name = json["nickname"].stringValue
                            
                            if openid.characters.count > 0 {
                                self.logInVia3rdHelper(openid, nameFrom3rd: _name, type: "wechat")
                            }
                        }
                    }
                    
                }
            }
        } else {
            self.showTipText("微信授权不成功...")
        }
        
    }
    
    
    func logInVia3rdHelper(id: String, nameFrom3rd: String, type: String) {
        self.viewLoadingShow()
        
        
        
        LogOrRegModel.check3rdOauth(id, type: type) {
            (task, responseObject, error) in
            self.viewLoadingHide()
            if let _ = error {
                self.showTipText("网络有点问题，等一会儿再试")
            } else {
                let json = JSON(responseObject!)
                
                if json["data"] == "0" {
                    self.hasRegistered = false
                } else if json["data"] == "1" {
                    self.hasRegistered = true
                }
                
                if self.hasRegistered == false {
                    self.thirdPartyID = id
                    self.thirdPartyType = type
                    self.thirdPartyName = nameFrom3rd
                    self.performSegueWithIdentifier("toConfirm3rdLogIn", sender: nil)
                } else {
                    LogOrRegModel.logInVia3rd(id, type: type) {
                        (task, responseObject, error) in
                        
                        if let _ = error {
                            self.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            let json = JSON(responseObject!)
                            
                            if json["error"] != 0 {
                                self.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                let shell = json["data"]["shell"].stringValue
                                let uid = json["data"]["uid"].stringValue
                                
                                let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                                uidKey.setObject(uid, forKey: kSecAttrAccount)
                                uidKey.setObject(shell, forKey: kSecValueData)
                                
                                CurrentUser.sharedCurrentUser.uid = uid
                                CurrentUser.sharedCurrentUser.shell = shell
                                
                                Api.requestLoad()
                                
                                /* 使用第三方来登录 */
                                self.launch()
                            }  // if json["error"] != 0
                        } // if let _error = error
                        
                    } // LogOrRegModel.logInVia3rd(id, type: type)
                    
                } // if self.hasRegistered == false
                
            } // if let _error = error
            
        } //  LogOrRegModel.check3rdOauth(id, type: type)
        
    } // func logInVia3rdHelper(id: String, nameFrom3rd: String, type: String)
    
    
}
























