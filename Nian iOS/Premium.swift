//
//  Premium.swift
//  NianiOS
//
//  Created by Sa on 16/4/7.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Premium: SAViewController, UITableViewDelegate, UITableViewDataSource, NIAlertDelegate {
    
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var alert: NIAlert?
    var alertError: NIAlert?
    var alertErrorWechat: NIAlert?
    var price: CGFloat = -1
    var hasWechat = false
    var wechatName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("奖励提现")
        setup()
    }
    
    func setup() {
        dataArray = [
            ["title": "关于奖励", "content": "当你创造好内容时，好友可以以奖励的方式支持你。奖励可兑换为等值的人民币。", "image": "premium_coffee"],
            ["title": "关于提现", "content": "绑定微信账号后，你可以把奖励以人民币的方式取出至微信零钱。", "image": "premium_wallet"],
            ["title": "提现规则", "content": "每次提现的金额不小于 20 元，手续费为每次提现总额的 20%。", "image": "premium_rules"]
        ]
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "CoinProductTop", bundle: nil), forCellReuseIdentifier: "CoinProductTop")
        tableView.registerNib(UINib(nibName: "PremiumCell", bundle: nil), forCellReuseIdentifier: "PremiumCell")
        self.view.addSubview(tableView)
        tableView.addHeaderWithCallback { 
            self.load()
        }
        tableView.headerBeginRefreshing()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.wechatNotification(_:)), name: "Wechat", object: nil)
    }
    
    func wechatNotification(notification: NSNotification) {
        if let data = notification.object as? NSDictionary {
            let openid = data.stringAttributeForKey("openid")
            let accessToken = data.stringAttributeForKey("access_token")
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
                            SettingModel.bindThirdAccount(openid, nameFrom3rd: _name, type: "wechat") {
                                (task, responseObject, error) -> Void in
                                if let _ = error {
                                    self.showTipText("网络有点问题，等一会儿再试")
                                } else {
                                    self.hasWechat = true
                                    self.wechatName = _name
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func load() {
        Api.getBalance() { json in
            if json != nil {
                print(json)
                if let data = json!.objectForKey("data") as? NSDictionary {
//                    if let balance = data.stringAttributeForKey("balance") {
//                        print(balance)
//                        print(data.stringAttributeForKey("balance"))
//                        self.price = CGFloat(balance) * 0.01
//                    }
                    let balance = data.stringAttributeForKey("balance")
                    if let _balance = Int(balance) {
                        self.price = CGFloat(_balance) * 0.01
                    }
                    if let wechat = data.objectForKey("wechat") as? NSDictionary {
                        self.wechatName = wechat.stringAttributeForKey("name")
                        self.hasWechat = wechat.stringAttributeForKey("has") == "1"
                    }
                    self.tableView.headerEndRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c: CoinProductTop! = tableView.dequeueReusableCellWithIdentifier("CoinProductTop", forIndexPath: indexPath) as? CoinProductTop
            c.setup()
            c.labelTitle.text = "余额"
            c.imageHead.image = UIImage(named: "pig")
            c.labelContent.text = "¥\(price)"
            c.btn.setTitle("提现", forState: UIControlState())
            c.btn.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
            c.btn.addTarget(self, action: #selector(self.withdraw), forControlEvents: UIControlEvents.TouchUpInside)
            c.viewLine.setX(40)
            c.viewLine.setWidth(globalWidth - 80)
            return c
        } else {
            let c: PremiumCell! = tableView.dequeueReusableCellWithIdentifier("PremiumCell", forIndexPath: indexPath) as? PremiumCell
            c.data = dataArray[indexPath.row] as! NSDictionary
            c.setup()
            return c
        }
    }
    
    func withdraw() {
        alert = NIAlert()
        alert!.delegate = self
        var content = "要将所有余额\n提现到微信账号 \(self.wechatName) 吗？"
        if !hasWechat {
            content = "要将所有余额\n提现到微信账号吗？"
        }
        alert!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "提现", "content": content, "buttonArray": [" 嗯！", " 不！"]]
        alert!.showWithAnimation(showAnimationStyle.flip)
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == alert {
            if didselectAtIndex == 0 {
                /* 提现，判断是否超过 20 */
                if price >= 20 {
                    /* 获取是否绑定微信 */
                    if !hasWechat {
                        self.alertErrorWechat = NIAlert()
                        self.alertErrorWechat?.delegate = self
                        self.alertErrorWechat?.dict = ["img": UIImage(named: "pay_wallet")!, "title": "失败了", "content": "需要绑定一个微信\n才能提现", "buttonArray": ["现在绑定"]]
                        self.alert?.dismissWithAnimationSwtich(self.alertErrorWechat!)
                    } else {
                        if let btn = self.alert?.niButtonArray.firstObject as? NIButton {
                            btn.startAnimating()
                            Api.postExchange(price) { json in
                                    print(json)
                                    // todo: 确实成功提现了，但是没有返回 json
                                    self.alertError = NIAlert()
                                    self.alertError!.delegate = self
                                    self.alertError!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "提现好了", "content": "在 24 小时内奖励会提现到微信零钱里！", "buttonArray": [" 嗯！"]]
                                    self.alert!.dismissWithAnimationSwtich(self.alertError!)
                            }
                        }
                    }
                } else {
                    /* 如果余额小于 20 */
                    alertError = NIAlert()
                    alertError!.delegate = self
                    alertError!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "失败了", "content": "余额要不小于 20 元\n才能提出", "buttonArray": ["哦"]]
                    alert!.dismissWithAnimationSwtich(alertError!)
                }
            } else {
                alert!.dismissWithAnimation(.normal)
            }
        } else if niAlert == alertError {
            alert!.dismissWithAnimation(.normal)
            alertError!.dismissWithAnimation(.normal)
        } else if niAlert == alertErrorWechat {
            alert!.dismissWithAnimation(.normal)
            alertErrorWechat!.dismissWithAnimation(.normal)
            if WXApi.isWXAppInstalled() {
                let req = SendAuthReq()
                req.scope = "snsapi_userinfo"
                
                WXApi.sendReq(req)
            } else {
                self.showTipText("手机未安装微信")
            }
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        if niAlert == alert {
            alert!.dismissWithAnimation(.normal)
        } else if niAlert == alertError {
            alert!.dismissWithAnimation(.normal)
            alertError!.dismissWithAnimation(.normal)
        } else if niAlert == alertErrorWechat {
            alert!.dismissWithAnimation(.normal)
            alertErrorWechat!.dismissWithAnimation(.normal)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 281
        } else {
            return 80
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if price < 0 {
            return 0
        } else {
            if section == 0 {
                return 1
            } else {
                return dataArray.count
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}