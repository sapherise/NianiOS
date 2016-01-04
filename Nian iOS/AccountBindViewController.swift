//
//  AccountBindViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/31/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

protocol UpdateUserDictDelegate {
    func updateUserDict(email: String)
}

class AccountBindViewController: SAViewController {
    
    ///
    @IBOutlet weak var tableview: UITableView!
    
    var bindDict: Dictionary<String, AnyObject> = Dictionary()
    
    var userEmail: String = ""
    var userName: String = ""
    var delegate: UpdateUserDictDelegate?
    
    var oauth: TencentOAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("账号和绑定设置")
        
        self.tableview.registerClass(AccountBindCell.self, forCellReuseIdentifier: "AccountBindCell")
        self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 24))
        self.tableview.separatorStyle = .None
        
        self.startAnimating()
        
        SettingModel.getUserAllOauth() {
            (task, responseObject, error) in
            
            self.stopAnimating()
            
            if let _ = error {
                self.view.showTipText("网络有点问题，等一会儿再试")
            } else {
                let json = JSON(responseObject!)
                
                if json["error"].numberValue != 0 {
                    
                } else {
                    self.bindDict = json["data"].dictionaryObject!
                    
                    self.tableview.reloadData()
                }
                
            }
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleBindWeibo:", name: "weibo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleBindWechat:", name: "Wechat", object: nil)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "weibo", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Wechat", object: nil)
    }
    
}

extension AccountBindViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AccountBindCell") as? AccountBindCell
        
        if cell == nil {
           cell = AccountBindCell.init(style: .Value1, reuseIdentifier: "AccountBindCell")
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.userEmail == "" {
                    cell?.imageView?.image = UIImage(named: "account_mail")
                } else {
                    cell?.imageView?.image = UIImage(named: "account_mail_binding")
                    cell?.detailTextLabel?.text = self.userEmail
                }
                
                cell?.textLabel?.text = "邮箱"
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if self.bindDict["wechat"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_wechat_binding")
                    cell?.detailTextLabel?.text = self.bindDict["wechat_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_wechat")
                    cell?.detailTextLabel?.text = ""
                }
                let v = UIView(frame: CGRectMake(16, cell!.height() - globalHalf, globalWidth - 16, globalHalf))
                v.backgroundColor = UIColor.e6()
                cell?.addSubview(v)
                cell?.textLabel?.text = "微信"
                
            } else if indexPath.row == 1 {
                if self.bindDict["QQ"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_qq_binding")
                    cell?.detailTextLabel?.text = self.bindDict["QQ_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_qq")
                    cell?.detailTextLabel?.text = ""
                }
                let v = UIView(frame: CGRectMake(16, cell!.height() - globalHalf, globalWidth - 16, globalHalf))
                v.backgroundColor = UIColor.e6()
                cell?.addSubview(v)
                cell?.textLabel?.text = "QQ"
                
            } else if indexPath.row == 2 {
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return globalHalf
        } else if section == 1 {
            return 24
        }
        return globalHalf
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            
            // 邮箱的顶部分割线
            let _view = UIView(frame: CGRectMake(0, 0, self.view.frame.width, globalHalf))
            _view.backgroundColor = UIColor(red: 0xE6/255.0, green: 0xE6/255.0, blue: 0xE6/255.0, alpha: 1.0)
            
            return _view
        } else if section == 1 {
            
            // QQ和微信的上下分割线
            let containerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 24))
            
            let _view1 = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 23.5))
            let _view2 = UIView(frame: CGRectMake(0, 24 - globalHalf, self.view.frame.width, globalHalf))
            _view2.backgroundColor = UIColor.e6()
            
            containerView.addSubview(_view1)
            containerView.addSubview(_view2)
            
            return containerView
        }
        
        return nil
    }
   
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 24
        } else if section == 0 {
            return globalHalf
        }
        
        return globalHalf
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let _containerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 24))
            
            let _view = UIView(frame: CGRectMake(0, 0, self.view.frame.width, globalHalf))
            _view.backgroundColor = UIColor.e6()
            
            let label = UILabel(frame: CGRectMake(16, 8, self.view.frame.width, 15))
            label.text = "绑定社交网络账号来玩念"
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor.b3()
            
            _containerView.addSubview(_view)
            _containerView.addSubview(label)
            
            return _containerView
            
        } else if section == 0 {
            let _view = UIView(frame: CGRectMake(0, 0, self.view.frame.width, globalHalf))
            _view.backgroundColor = UIColor.e6()
            
            return _view
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let bindEmailVC = BindEmailViewController(nibName: "BindEmailView", bundle: nil)
                bindEmailVC.delegate = self
                
                if self.userEmail == "" {
                    bindEmailVC.modeType = .bind
                } else {
                    bindEmailVC.previousEmail = self.userEmail
                    bindEmailVC.modeType = .modify
                }
                
                self.navigationController?.presentViewController(bindEmailVC, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if self.bindDict["wechat"] as? String == "1" {
                    
                    if self.userEmail == "" {
                        if self.bindDict["weibo_username"] as! String == "" && self.bindDict["QQ_username"] as! String == "" {
                            self.view.showTipText("不能解除绑定微信...", delay: 1)

                            return
                        }
                    }
                    
                    let alertController = PSTAlertController.actionSheetWithTitle("微信账号: 昵称 " + (self.bindDict["wechat_username"] as! String))
                    
                    alertController.addAction(PSTAlertAction(title: "解除绑定", style: .Default, handler: { (action) in
                        SettingModel.relieveThirdAccount("wechat", callback: { (task, responseObject, error) -> Void in
                            if let _ = error {
                                self.view.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                
                                let json = JSON(responseObject!)
                                
                                if json["error"] != 0 {
                                    self.view.showTipText("网络有点问题，等一会儿再试")
                                } else {
                                    
                                    self.bindDict["wechat"] = "0"
                                    self.bindDict["wechat_username"] = ""
                                    
                                    self.tableview.beginUpdates()
                                    self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .None)
                                    self.tableview.endUpdates()
                                    
                                    self.view.showTipText("微信解除绑定成功", delay: 1)
                                }
                            }
                            
                        })

                    }))
                    
                    alertController.addCancelActionWithHandler(nil)
                    
                    alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
                    
                } else {
                    if WXApi.isWXAppInstalled() {
                        let req = SendAuthReq()
                        req.scope = "snsapi_userinfo"
                        
                        WXApi.sendReq(req)
                    } else {
                        self.view.showTipText("手机未安装微信", delay: 1)
                    }
                    
                }
            
            } else if indexPath.row == 1 {
                if self.bindDict["QQ"] as? String == "1" {
                   
                    if self.userEmail == "" {
                        if self.bindDict["weibo_username"] as! String == "" && self.bindDict["wechat_username"] as? String == "" {
                            self.view.showTipText("不能解除绑定 QQ...", delay: 1)

                            return                       
                        }
                    }
                    
                    let alertController = PSTAlertController.actionSheetWithTitle("QQ 账号: 昵称 " + (self.bindDict["QQ_username"] as! String))
                    
                    alertController.addAction(PSTAlertAction(title: "解除绑定", style: .Default, handler: { (action) in
                        SettingModel.relieveThirdAccount("QQ", callback: { (task, responseObject, error) -> Void in
                            if let _ = error {
                                self.view.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                
                                let json = JSON(responseObject!)
                                
                                if json["error"] != 0 {
                                    self.view.showTipText("网络有点问题，等一会儿再试")
                                } else {
                                    self.bindDict["QQ"] = 1
                                    self.bindDict["QQ_username"] = ""
                                    
                                    self.tableview.beginUpdates()
                                    self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .None)
                                    self.tableview.endUpdates()
                                    
                                    self.view.showTipText("QQ 解除绑定成功", delay: 1)
                                }
                            }
                            
                        })
                        
                    }))
                    
                    alertController.addCancelActionWithHandler(nil)
                    
                    alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
                    
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
            
            
            } else if indexPath.row == 2 {
                if self.bindDict["weibo"] as? String == "1" {
                   
                    if self.userEmail == "" {
                        if self.bindDict["wechat_username"] as! String == "" && self.bindDict["QQ_username"] as! String == "" {
                            self.view.showTipText("不能解除绑定微博...", delay: 1)
                        
                            return
                        }
                    }
                    
                    let alertController = PSTAlertController.actionSheetWithTitle("微博账号: 昵称 " + (self.bindDict["weibo_username"] as! String))
                    
                    alertController.addAction(PSTAlertAction(title: "解除绑定", style: .Default, handler: { (action) in
                        SettingModel.relieveThirdAccount("weibo", callback: { (task, responseObject, error) -> Void in
                            if let _ = error {
                                self.view.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                
                                let json = JSON(responseObject!)
                                
                                if json["error"] != 0 {
                                    self.view.showTipText("网络有点问题，等一会儿再试")
                                } else {
                                    self.bindDict["weibo"] = "0"
                                    self.bindDict["weibo_username"] = ""
                                    
                                    self.tableview.beginUpdates()
                                    self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .None)
                                    self.tableview.endUpdates()
                                    
                                    self.view.showTipText("微博解除绑定成功", delay: 1)
                                }
                            }
                            
                        })
                    }))
                    
                    alertController.addCancelActionWithHandler(nil)
                    
                    alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
                    
                } else {
                    let request = WBAuthorizeRequest()
                    request.redirectURI = "https://api.weibo.com/oauth2/default.html"
                    request.scope = "all"
                    request.userInfo = ["SSO_From": "WelcomeViewController"]
                    WeiboSDK.sendRequest(request)
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
            
            LogOrRegModel.getQQName(accessToken, openid: openid, appid: appid) {
                (task, responseObject, error) in
                
                if let _ = error {
                    self.view.showTipText("网络有点问题，等一会儿再试")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["ret"].numberValue != 0 {
                        self.view.showTipText("QQ 授权不成功...")
                    } else {
                        let _name = json["nickname"].stringValue
                        
                        if _name.characters.count > 0 {
                            self.bind3rdAccount(openid, name: self.userName, nameFrom3rd: _name, type: "QQ")
                        }
                    }
                }
            }
            
        } else {
            
        }
        
    }
    
    /**
     * 登录失败后的回调
     * param cancelled 代表用户是否主动退出登录
     */
    func tencentDidNotLogin(cancelled: Bool) {
        self.view.showTipText("绑定 QQ 失败...", delay: 2)
    }
    
    /**
     * 登录时网络有问题的回调
     */
    func tencentDidNotNetWork() {
        
    }

}


extension AccountBindViewController {

    func handleBindWeibo(noti: NSNotification) {
        guard let notiObject = noti.object else {
            return
        }
        
        if (notiObject as! NSArray).count > 0 {
            let weiboUid = (notiObject as! NSArray)[0] as? String
            let accessToken = (notiObject as! NSArray)[1] as? String
            
            if weiboUid != nil && accessToken != nil {
                LogOrRegModel.getWeiboName(accessToken!, openid: "n*A\(weiboUid!)".md5) {
                    (task, responseObject, error) in
                    
                    if let _ = error {
                        self.view.showTipText("网络有点问题，等一会儿再试")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if let _ = json["error"].string {
                            self.view.showTipText("微博授权不成功...")
                        } else {
                            let _name = json["name"].stringValue
                            
                            if _name.characters.count > 0 {
                                self.bind3rdAccount(weiboUid!, name: self.userName, nameFrom3rd: _name, type: "weibo")
                            }
                        }
                    }
                }
            }
            
        } else {
            
        }
    }


    func handleBindWechat(noti: NSNotification) {
        guard let notiObject = noti.object else {
            return
        }
        
        if let openid = (notiObject as! NSDictionary)["openid"] as? String {
            if let accessToken = (notiObject as! NSDictionary)["access_token"] as? String {
                LogOrRegModel.getWechatName(accessToken, openid: openid) {
                    (task, responseObject, error) in
                    
                    if let _ = error {
                        self.view.showTipText("网络有点问题，等一会儿再试")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if let _ = json["errcode"].number {
                            self.view.showTipText("微信授权不成功...")
                        } else {
                            let _name = json["nickname"].stringValue
                            
                            if openid.characters.count > 0 {
                                self.bind3rdAccount(openid, name: self.userName, nameFrom3rd: _name, type: "wechat")
                            }
                        }
                    }
                    
                }
            }
        } else {
            
        }

    }
    
    
    func bind3rdAccount(id: String, name: String, nameFrom3rd: String, type: String) {
    
        SettingModel.bindThirdAccount(id, name: name, nameFrom3rd: nameFrom3rd, type: type) {
            (task, responseObject, error) -> Void in
            
            if let _ = error {
                self.view.showTipText("网络有点问题，等一会儿再试")
            } else {
                let json = JSON(responseObject!)
                
                if json["error"].numberValue != 0 {
                    self.view.showTipText("网络有点问题，等一会儿再试")
                } else {
                    
                    if type == "wechat" {
                        self.bindDict["wechat"] = "1"
                        self.bindDict["wechat_username"] = nameFrom3rd
                        
                        self.tableview.beginUpdates()
                        self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .None)
                        self.tableview.endUpdates()
                        
                    } else if type == "QQ" {
                        self.bindDict["QQ"] = "1"
                        self.bindDict["QQ_username"] = nameFrom3rd
                        
                        self.tableview.beginUpdates()
                        self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .None)
                        self.tableview.endUpdates()
                        
                    } else if type == "weibo" {
                        self.bindDict["weibo"] = "1"
                        self.bindDict["weibo_username"] = nameFrom3rd
                        
                        self.tableview.beginUpdates()
                        self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .None)
                        self.tableview.endUpdates()
                    
                    }
                }
            }
        }
    
    }
}


extension AccountBindViewController: bindEmailDelegate {
    
    func bindEmail(email email: String) {
        self.userEmail = email
        
        // 修改邮箱成功后，调用协议来修改 userDict
        delegate?.updateUserDict(email)
        
        self.tableview.beginUpdates()
        self.tableview.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
        self.tableview.endUpdates()
    }
    
}








