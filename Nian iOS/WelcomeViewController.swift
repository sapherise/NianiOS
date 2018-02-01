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
    
    @IBOutlet weak var x: NSLayoutConstraint!
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
        self.logInButton.layer.borderColor = UIColor.colorWithHex("#333333").cgColor
        self.logInButton.layer.masksToBounds = true
        
        if !WXApi.isWXAppInstalled() {
            wechatButton.isHidden = true
            qqButton.isHidden = true
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            button.frame.origin = CGPoint(x: 100, y: globalHeight - 24 - 44)
            button.setImage(UIImage(named: "signin_qq"), for: UIControlState())
            button.titleLabel?.textAlignment = NSTextAlignment.center
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setTitle("QQ", for: UIControlState())
            button.setTitleColor(UIColor.black, for: UIControlState())
            button.addTarget(self, action: #selector(WelcomeViewController.qq), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
            
            let imageSize = button.imageView?.frame.size
            let titleSize = button.titleLabel?.frame.size
            let padding: CGFloat = 4.0
            let totalHeight = imageSize!.height + titleSize!.height + padding
            button.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize!.height), 0, 0, -titleSize!.width)
            button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize!.width, -(totalHeight - titleSize!.height), 0.0)
            
            x.constant = 100
        }
        
        // 先隐藏欢迎界面
        self.view.isHidden = true
        
        if let _uid = CurrentUser.sharedCurrentUser.uid {      //如果登录了
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            uidKey?.setObject(_uid, forKey: kSecAttrAccount)
            
            /* 普通启动 */
            launch(1)
            numExplore = 1
            
            delay(1, closure: { () -> () in
                self.view.isHidden = false
            })
        } else {  // 没有登录
            /* 留在当前页面 */
            self.view.isHidden = false
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.handleLogInViaWeibo(_:)), name: NSNotification.Name(rawValue: "weibo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.handleLogInViaWechat(_:)), name: NSNotification.Name(rawValue: "Wechat"), object: nil)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Weibo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Wechat"), object: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        // toLORVC : to LogOrRegViewController
        if segue.identifier == "toLORVC" {
            /*   */
            let logOrRegViewController = segue.destination as! LogOrRegViewController
            logOrRegViewController.functionalType = FunctionType.confirm
        }
        
        if segue.identifier == "toConfirm3rdLogIn" {
            let nicknameViewController = segue.destination as! NicknameViewController
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
    @IBAction func logInViaWechat(_ sender: UIButton) {
        if WXApi.isWXAppInstalled() {
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            
            WXApi.send(req)
        } else {
            self.showTipText("未安装微信...")
        }
    }
    
    /**
    
    */
    @IBAction func logInViaQQ(_ sender: UIButton) {
        qq()
    }
    
    func qq() {
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
    @IBAction func logInViaWeibo(_ sender: UIButton) {
        let request = WBAuthorizeRequest()
        request.redirectURI = "https://api.weibo.com/oauth2/default.html"
        request.scope = "all"
        request.userInfo = ["SSO_From": "WelcomeViewController"]
        WeiboSDK.send(request)
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
            
            Api.getQQName(accessToken, openid: openid, appid: appid) { json in
                if json != nil {
                    let ret = SAValue(json, "ret")
                    if ret == "0" {
                        let name = SAValue(json, "nickname")
                        if name.characters.count > 0 {
                            self.logInVia3rdHelper(openid, nameFrom3rd: name, type: "QQ")
                        }
                    } else {
                        self.showTipText("QQ 授权不成功...")
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
    func tencentDidNotLogin(_ cancelled: Bool) {
        
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
    func handleLogInViaWeibo(_ noti: Notification) {
        guard let notiObject = noti.object else {
            return
        }
        
        if (notiObject as! NSArray).count > 0 {
            let weiboUid = (notiObject as! NSArray)[0] as? String
            let accessToken = (notiObject as! NSArray)[1] as? String
            
            if weiboUid != nil && accessToken != nil {
                Api.getWeiboName(accessToken!, openid: weiboUid!) { json in
                    if json != nil {
                        let name = SAValue(json, "name")
                        self.logInVia3rdHelper(weiboUid!, nameFrom3rd: name, type: "weibo")
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
    func handleLogInViaWechat(_ noti: Notification) {
        guard let notiObject = noti.object else {
            return
        }
        if let openid = (notiObject as! NSDictionary)["openid"] as? String {
            if let accessToken = (notiObject as! NSDictionary)["access_token"] as? String {
                Api.getWechatName(accessToken, openid: openid) { json in
                    if json != nil {
                        if SAValue(json, "errcode") != "" {
                           self.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            let name = SAValue(json, "nickname")
                            self.logInVia3rdHelper(openid, nameFrom3rd: name, type: "wechat")
                        }
                    }
                }
            }
        } else {
            self.showTipText("微信授权不成功...")
        }
    }
    
    func logInVia3rdHelper(_ id: String, nameFrom3rd: String, type: String) {
        self.viewLoadingShow()
        Api.check3rdOauth(id, type: type) { json in
            self.viewLoadingHide()
            if json != nil {
                let data = SAValue(json, "data")
                if data == "0" {
                    self.hasRegistered = false
                } else if data == "1" {
                    self.hasRegistered = true
                }
                if !self.hasRegistered {
                    self.thirdPartyID = id
                    self.thirdPartyType = type
                    self.thirdPartyName = nameFrom3rd
                    self.performSegue(withIdentifier: "toConfirm3rdLogIn", sender: nil)
                } else {
                    Api.logInVia3rd(id, type: type) { json in
                        if json != nil {
                            if SAValue(json, "error") != "0" {
                                self.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                if let data = json!.object(forKey: "data") as? NSDictionary {
                                    let shell = data.stringAttributeForKey("shell")
                                    let uid = data.stringAttributeForKey("uid")
                                    let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                                    uidKey?.setObject(uid, forKey: kSecAttrAccount)
                                    uidKey?.setObject(shell, forKey: kSecValueData)
                                    CurrentUser.sharedCurrentUser.uid = uid
                                    CurrentUser.sharedCurrentUser.shell = shell
                                    Api.requestLoad()
                                    /* 使用第三方来登录 */
                                    self.launch(0)
                                }
                            }
                        }
                    }
                }
                
                
            }
        }
    }
}

