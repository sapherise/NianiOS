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
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CoinProductTop", bundle: nil), forCellReuseIdentifier: "CoinProductTop")
        tableView.register(UINib(nibName: "PremiumCell", bundle: nil), forCellReuseIdentifier: "PremiumCell")
        self.view.addSubview(tableView)
        tableView.addHeaderWithCallback { 
            self.load()
        }
        tableView.headerBeginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.wechatNotification(_:)), name: NSNotification.Name(rawValue: "Wechat"), object: nil)
    }
    
    func wechatNotification(_ notification: Notification) {
        if let data = notification.object as? NSDictionary {
            let openid = data.stringAttributeForKey("openid")
            let accessToken = data.stringAttributeForKey("access_token")
            Api.getWechatName(accessToken, openid: openid) { json in
                if json != nil {
                    if SAValue(json, "errcode") != "" {
                        self.showTipText("微信授权不成功...")
                    } else {
                        let name = SAValue(json, "nickname")
                        Api.bindThirdAccount(openid, nameFrom3rd: name, type: "wechat") { json in
                            if json != nil {
                                self.hasWechat = true
                                self.wechatName = name
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
                if let data = json!.object(forKey: "data") as? NSDictionary {
                    let balance = data.stringAttributeForKey("balance")
                    if let _balance = Int(balance) {
                        self.price = CGFloat(_balance) * 0.01
                    }
                    if let wechat = data.object(forKey: "wechat") as? NSDictionary {
                        self.wechatName = wechat.stringAttributeForKey("name")
                        self.hasWechat = wechat.stringAttributeForKey("has") == "1"
                    }
                    self.tableView.headerEndRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let c: CoinProductTop! = tableView.dequeueReusableCell(withIdentifier: "CoinProductTop", for: indexPath) as? CoinProductTop
            c.setup()
            c.labelTitle.text = "余额"
            c.imageHead.image = UIImage(named: "pig")
            c.labelContent.text = "¥\(price)"
            c.btn.setTitle("提现", for: UIControlState())
            c.btn.removeTarget(nil, action: nil, for: UIControlEvents.touchUpInside)
            c.btn.addTarget(self, action: #selector(self.withdraw), for: UIControlEvents.touchUpInside)
            c.viewLine.setX(40)
            c.viewLine.setWidth(globalWidth - 80)
            return c
        } else {
            let c: PremiumCell! = tableView.dequeueReusableCell(withIdentifier: "PremiumCell", for: indexPath) as? PremiumCell
            c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
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
    
    func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int) {
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
                            Api.getExchange() { json in
                                self.alertError = NIAlert()
                                self.alertError!.delegate = self
                                if let _json = json as? NSDictionary {
                                    let status = _json.stringAttributeForKey("status")
                                    let error = _json.stringAttributeForKey("error")
                                    if error == "1003" {
                                        self.alertError!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "失败了", "content": "念的实验室没有这么多钱！\n去联系下 @Sa 试试！", "buttonArray": ["哦"]]
                                        self.alert!.dismissWithAnimationSwtich(self.alertError!)
                                    } else if error == "1001" {
                                        self.alertError!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "失败了", "content": "余额要不小于 20 元\n才能提出", "buttonArray": ["哦"]]
                                        self.alert!.dismissWithAnimationSwtich(self.alertError!)
                                    } else if status == "200" {
                                        self.alertError!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "提现好了", "content": "在 24 小时内奖励会提现到微信零钱里！", "buttonArray": [" 嗯！"]]
                                        self.alert!.dismissWithAnimationSwtich(self.alertError!)
                                    } else {
                                        self.alertError!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "失败了", "content": "遇到一个奇怪的错误\n去联系下 @Sa 试试！", "buttonArray": ["哦"]]
                                        self.alert!.dismissWithAnimationSwtich(self.alertError!)
                                    }
                                }
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
                
                WXApi.send(req)
            } else {
                self.showTipText("手机未安装微信")
            }
        }
    }
    
    func niAlert(_ niAlert: NIAlert, tapBackground: Bool) {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 281
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
