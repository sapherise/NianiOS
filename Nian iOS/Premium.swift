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
    var price: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("奖励提现")
        setup()
    }
    
    func setup() {
        dataArray = [
            ["title": "关于奖励", "content": "当你创造好内容时，好友可以以奖励的方式支持你。奖励可兑换为等值的人民币。", "image": "vip_discount"],
            ["title": "关于提现", "content": "绑定微信账号后，你可以把奖励以人民币的方式取出至微信零钱。", "image": "vip_mark"],
            ["title": "提现规则", "content": "每次提现的金额不小于 20 元，手续费为每次提现总额的 20%。", "image": "vip_love"]
        ]
        price = 36
        
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "CoinProductTop", bundle: nil), forCellReuseIdentifier: "CoinProductTop")
        tableView.registerNib(UINib(nibName: "PremiumCell", bundle: nil), forCellReuseIdentifier: "PremiumCell")
        self.view.addSubview(tableView)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c: CoinProductTop! = tableView.dequeueReusableCellWithIdentifier("CoinProductTop", forIndexPath: indexPath) as? CoinProductTop
            c.setup()
            c.labelTitle.text = "余额"
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
        print("提现")
        alert = NIAlert()
        alert!.delegate = self
        alert!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "提现", "content": "要将所有余额\n提现到微信账号吗？", "buttonArray": [" 嗯！", " 不！"]]
        alert!.showWithAnimation(showAnimationStyle.flip)
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == alert {
            if didselectAtIndex == 0 {
                /* 提现，判断是否超过 20 */
                if price >= 20 {
                    /* 获取是否绑定微信 */
                    SettingModel.getUserAllOauth({ (task, json, error) in
                        if let btn = self.alert?.niButtonArray[0] as? NIButton {
                            btn.startAnimating()
                        }
                        if let _ = error {
                            self.showTipText("网络有点问题，等一会儿再试")
                        } else {
                            if json != nil {
                                if let data = json!.objectForKey("data") as? NSDictionary {
                                    let wechatUserName = data.stringAttributeForKey("wechat_username")
                                    if wechatUserName == "" {
                                        print("未绑定微信，去前往绑定")
                                        self.alertErrorWechat = NIAlert()
                                        self.alertErrorWechat!.delegate = self
                                        self.alertErrorWechat!.dict = ["img": UIImage(named: "pay_wallet")!, "title": "失败了", "content": "需要绑定一个微信\n才能提现", "buttonArray": ["现在绑定"]]
                                        self.alert!.dismissWithAnimationSwtich(self.alertErrorWechat!)
                                    } else {
                                        print("将提现到 \(wechatUserName) 账号，确定吗")
                                    }
                                }
                            }
                        }
                    })
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
//            let vc = AccountBindViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
            
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
        if section == 0 {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}