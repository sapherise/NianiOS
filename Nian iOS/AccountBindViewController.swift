//
//  AccountBindViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/31/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

protocol UpdateUserDictDelegate {
    func updateUserDict(_ email: String)
}

class AccountBindViewController: SAViewController, UIActionSheetDelegate {
    
    ///
    @IBOutlet weak var tableview: UITableView!
    
    var bindDict: Dictionary<String, AnyObject> = Dictionary()
    
    var userEmail: String = ""
    var delegate: UpdateUserDictDelegate?
    
    var oauth: TencentOAuth?
    
    var actionSheet: UIActionSheet?
    var actionSheetQQ: UIActionSheet?
    var actionSheetWeibo: UIActionSheet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("账号和绑定设置")
        
        self.tableview.register(AccountBindCell.self, forCellReuseIdentifier: "AccountBindCell")
        self.tableview.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
        self.tableview.separatorStyle = .none
        
        self.startAnimating()
        Api.getUserAllOauth() { json in
            self.stopAnimating()
            if json != nil {
                if SAValue(json, "error") != "0" {
                    self.showTipText("网络有点问题，等一会儿再试")
                } else {
                    if let data = json?.object(forKey: "data") as? Dictionary<String, AnyObject> {
                        self.bindDict = data
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AccountBindViewController.handleBindWeibo(_:)), name: NSNotification.Name(rawValue: "weibo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AccountBindViewController.handleBindWechat(_:)), name: NSNotification.Name(rawValue: "Wechat"), object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "weibo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Wechat"), object: nil)
    }
    
}

extension AccountBindViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "AccountBindCell") as? AccountBindCell
        
        if cell == nil {
           cell = AccountBindCell.init(style: .value1, reuseIdentifier: "AccountBindCell")
        }
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                if self.userEmail == "" {
                    cell?.imageView?.image = UIImage(named: "account_mail")
                } else {
                    cell?.imageView?.image = UIImage(named: "account_mail_binding")
                    cell?.detailTextLabel?.text = self.userEmail
                }
                
                cell?.textLabel?.text = "邮箱"
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                if self.bindDict["wechat"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_wechat_binding")
                    cell?.detailTextLabel?.text = self.bindDict["wechat_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_wechat")
                    cell?.detailTextLabel?.text = ""
                }
                let v = UIView(frame: CGRect(x: 16, y: cell!.height() - globalHalf, width: globalWidth - 16, height: globalHalf))
                v.backgroundColor = UIColor.e6()
                cell?.addSubview(v)
                cell?.textLabel?.text = "微信"
                
            } else if (indexPath as NSIndexPath).row == 1 {
                if self.bindDict["QQ"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_qq_binding")
                    cell?.detailTextLabel?.text = self.bindDict["QQ_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_qq")
                    cell?.detailTextLabel?.text = ""
                }
                let v = UIView(frame: CGRect(x: 16, y: cell!.height() - globalHalf, width: globalWidth - 16, height: globalHalf))
                v.backgroundColor = UIColor.e6()
                cell?.addSubview(v)
                cell?.textLabel?.text = "QQ"
                
            } else if (indexPath as NSIndexPath).row == 2 {
                if self.bindDict["weibo"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_weibo_binding")
                    cell?.detailTextLabel?.text = self.bindDict["weibo_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_weibo")
                    cell?.detailTextLabel?.text = ""
                }
                cell?.textLabel?.text = "微博"
                
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return globalHalf
        } else if section == 1 {
            return 24
        }
        return globalHalf
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            
            // 邮箱的顶部分割线
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: globalHalf))
            _view.backgroundColor = UIColor(red: 0xE6/255.0, green: 0xE6/255.0, blue: 0xE6/255.0, alpha: 1.0)
            
            return _view
        } else if section == 1 {
            
            // QQ和微信的上下分割线
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
            
            let _view1 = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 23.5))
            let _view2 = UIView(frame: CGRect(x: 0, y: 24 - globalHalf, width: self.view.frame.width, height: globalHalf))
            _view2.backgroundColor = UIColor.e6()
            
            containerView.addSubview(_view1)
            containerView.addSubview(_view2)
            
            return containerView
        }
        
        return nil
    }
   
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 24
        } else if section == 0 {
            return globalHalf
        }
        
        return globalHalf
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let _containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 24))
            
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: globalHalf))
            _view.backgroundColor = UIColor.e6()
            
            let label = UILabel(frame: CGRect(x: 16, y: 8, width: self.view.frame.width, height: 15))
            label.text = "绑定社交网络账号来玩念"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor.b3()
            
            _containerView.addSubview(_view)
            _containerView.addSubview(label)
            
            return _containerView
            
        } else if section == 0 {
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: globalHalf))
            _view.backgroundColor = UIColor.e6()
            
            return _view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                let bindEmailVC = BindEmailViewController(nibName: "BindEmailView", bundle: nil)
                bindEmailVC.delegate = self
                
                if self.userEmail == "" {
                    bindEmailVC.modeType = .bind
                } else {
                    bindEmailVC.previousEmail = self.userEmail
                    bindEmailVC.modeType = .modify
                }
                
                self.navigationController?.present(bindEmailVC, animated: true, completion: nil)
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                if self.bindDict["wechat"] as? String == "1" {
                    
                    if self.userEmail == "" {
                        if self.bindDict["weibo_username"] as! String == "" && self.bindDict["QQ_username"] as! String == "" {
                            self.showTipText("不能解除绑定微信...")

                            return
                        }
                    }
                    
                    actionSheet = UIActionSheet(title: "微信账号：" + (self.bindDict["wechat_username"] as! String), delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    actionSheet!.addButton(withTitle: "解除绑定")
                    actionSheet!.addButton(withTitle: "取消")
                    actionSheet!.cancelButtonIndex = 1
                    actionSheet!.show(in: self.view)
                } else {
                    if WXApi.isWXAppInstalled() {
                        let req = SendAuthReq()
                        req.scope = "snsapi_userinfo"
                        
                        WXApi.send(req)
                    } else {
                        self.showTipText("手机未安装微信")
                    }
                    
                }
            
            } else if (indexPath as NSIndexPath).row == 1 {
                if self.bindDict["QQ"] as? String == "1" {
                   
                    if self.userEmail == "" {
                        if self.bindDict["weibo_username"] as! String == "" && self.bindDict["wechat_username"] as? String == "" {
                            self.showTipText("不能解除绑定 QQ...")

                            return                       
                        }
                    }
                    
                    actionSheetQQ = UIActionSheet(title: "QQ 账号：" + (self.bindDict["QQ_username"] as! String), delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    actionSheetQQ!.addButton(withTitle: "解除绑定")
                    actionSheetQQ!.addButton(withTitle: "取消")
                    actionSheetQQ!.cancelButtonIndex = 1
                    actionSheetQQ!.show(in: self.view)
                } else {
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
            
            
            } else if (indexPath as NSIndexPath).row == 2 {
                if self.bindDict["weibo"] as? String == "1" {
                   
                    if self.userEmail == "" {
                        if self.bindDict["wechat_username"] as! String == "" && self.bindDict["QQ_username"] as! String == "" {
                            self.showTipText("不能解除绑定微博...")
                        
                            return
                        }
                    }
                    
                    
                    actionSheetWeibo = UIActionSheet(title: "微博账号：" + (self.bindDict["weibo_username"] as! String), delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    actionSheetWeibo!.addButton(withTitle: "解除绑定")
                    actionSheetWeibo!.addButton(withTitle: "取消")
                    actionSheetWeibo!.cancelButtonIndex = 1
                    actionSheetWeibo!.show(in: self.view)
                } else {
                    let request = WBAuthorizeRequest()
                    request.redirectURI = "https://api.weibo.com/oauth2/default.html"
                    request.scope = "all"
                    request.userInfo = ["SSO_From": "WelcomeViewController"]
                    WeiboSDK.send(request)
                }
            }
        }
    }
    
    @objc(actionSheet:clickedButtonAtIndex:) func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                /* 解除微信 */
                Api.relieveThirdAccount("wechat") { json in
                    if json != nil {
                        if SAValue(json, "error") != "0" {
                            self.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            self.bindDict["wechat"] = "0" as AnyObject?
                            self.bindDict["wechat_username"] = "" as AnyObject?
                            self.tableview.reloadData()
                            self.showTipText("微信解除绑定成功")
                        }
                    }
                }
            }
        } else if actionSheet == self.actionSheetQQ {
            if buttonIndex == 0 {
                Api.relieveThirdAccount("QQ") { json in
                    if json != nil {
                        if SAValue(json, "error") != "0" {
                           self.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            self.bindDict["QQ"] = "0" as AnyObject?
                            self.bindDict["QQ_username"] = "" as AnyObject?
                            self.tableview.reloadData()
                            self.showTipText("QQ 解除绑定成功")
                        }
                    }
                }
            }
        } else if actionSheet == self.actionSheetWeibo {
            if buttonIndex == 0 {
                Api.relieveThirdAccount("weibo") { json in
                    if json != nil {
                        if SAValue(json, "error") != "0" {
                           self.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            self.bindDict["weibo"] = "0" as AnyObject?
                            self.bindDict["weibo_username"] = "" as AnyObject?
                            self.tableview.reloadData()
                            self.showTipText("微博解除绑定成功")
                        }
                    }
                }
            }
        }
    }
}



extension AccountBindViewController: TencentLoginDelegate, TencentSessionDelegate {
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
                    if SAValue(json, "ret") != "0" {
                       self.showTipText("QQ 授权不成功...")
                    } else {
                        let name = SAValue(json, "nickname")
                        if name.characters.count > 0 {
                            self.bind3rdAccount(openid, nameFrom3rd: name, type: "QQ")
                        }
                    }
                }
            }
        }
    }
    
    /**
     * 登录失败后的回调
     * param cancelled 代表用户是否主动退出登录
     */
    func tencentDidNotLogin(_ cancelled: Bool) {
        self.showTipText("绑定 QQ 失败...")
    }
    
    /**
     * 登录时网络有问题的回调
     */
    func tencentDidNotNetWork() {
        
    }

}


extension AccountBindViewController {

    func handleBindWeibo(_ noti: Notification) {
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
                        self.bind3rdAccount(weiboUid!, nameFrom3rd: name, type: "weibo")
                        self.showTipText("微博绑定成功")
                    }
                }
            }
        } else {
            
        }
    }


    func handleBindWechat(_ noti: Notification) {
        if let json = noti.object as? NSDictionary {
            if SAValue(json, "errcode") != "" {
                self.showTipText("网络有点问题，等一会儿再试")
            } else {
                let openid = json.stringAttributeForKey("openid")
                let token = json.stringAttributeForKey("access_token")
                Api.getWechatName(token, openid: openid) { json in
                    if json != nil {
                        let name = SAValue(json, "nickname")
                        self.bind3rdAccount(openid, nameFrom3rd: name, type: "wechat")
                    }
                }
            }
        }
    }
    
    
    func bind3rdAccount(_ id: String, nameFrom3rd: String, type: String) {
        Api.bindThirdAccount(id, nameFrom3rd: nameFrom3rd, type: type) { json in
            if json != nil {
                if SAValue(json, "error") != "0" {
                   self.showTipText("网络有点问题，等一会儿再试")
                } else {
                    if type == "wechat" {
                        self.bindDict["wechat"] = "1" as AnyObject?
                        self.bindDict["wechat_username"] = nameFrom3rd as AnyObject?
                        self.tableview.reloadData()
                    } else if type == "QQ" {
                        self.bindDict["QQ"] = "1" as AnyObject?
                        self.bindDict["QQ_username"] = nameFrom3rd as AnyObject?
                        self.tableview.reloadData()
                    } else if type == "weibo" {
                        self.bindDict["weibo"] = "1" as AnyObject?
                        self.bindDict["weibo_username"] = nameFrom3rd as AnyObject?
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
}


extension AccountBindViewController: bindEmailDelegate {
    
    func bindEmail(email: String) {
        self.userEmail = email
        
        // 修改邮箱成功后，调用协议来修改 userDict
        delegate?.updateUserDict(email)
        
        self.tableview.beginUpdates()
        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        self.tableview.endUpdates()
    }
    
}








