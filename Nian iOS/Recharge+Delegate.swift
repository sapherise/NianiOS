//
//  Recharge+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 16/2/28.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension Recharge {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c: RechargeCell! = tableView.dequeueReusableCellWithIdentifier("RechargeCell", forIndexPath: indexPath) as? RechargeCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.num = indexPath.row
        c.numMax = dataArray.count
        c.setup()
        c.btnMain.tag = indexPath.row
        c.btnMain.addTarget(self, action: #selector(self.onClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return c
    }
    
    //==
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        /* 如果是支付方式选择界面 */
        if niAlert == self.alert {
            
            if didselectAtIndex == 0 {
                if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                    btn.startAnimating()
                }
                
                /** 商家向财付通申请的商家id */
                if let data = dataArray[index] as? NSDictionary {
                    let title = data.stringAttributeForKey("title")
                    let price = data.stringAttributeForKey("price")
                    Api.postWechatPay(price, coins: title) { json in
                        if json != nil {
                            if let j = json as? NSDictionary {
                                let data = NSData(base64EncodedString: j.stringAttributeForKey("data"), options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                                let base64Decoded = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                let jsonString = base64Decoded?.dataUsingEncoding(NSASCIIStringEncoding)
                                if let dataResult = try? NSJSONSerialization.JSONObjectWithData(jsonString!, options: NSJSONReadingOptions.AllowFragments) {
                                    let request = PayReq()
                                    request.partnerId = dataResult.stringAttributeForKey("partnerid")
                                    request.prepayId = dataResult.stringAttributeForKey("prepayid")
                                    request.package = dataResult.stringAttributeForKey("package")
                                    request.nonceStr = dataResult.stringAttributeForKey("noncestr")
                                    request.timeStamp = UInt32(dataResult.stringAttributeForKey("timestamp"))!
                                    request.sign = dataResult.stringAttributeForKey("sign")
                                    WXApi.sendReq(request)
                                }
                            }
                        }
                    }
                }
            } else {
                /* 支付宝购买念币 */
                if let btn = niAlert.niButtonArray.lastObject as? NIButton {
                    btn.startAnimating()
                }
                if let data = dataArray[index] as? NSDictionary {
                    let title = data.stringAttributeForKey("title")
                    let price = data.stringAttributeForKey("price")
                    Api.postAlipayPay(price, coins: title) { json in
                        if json != nil {
                            if let j = json as? NSDictionary {
                                let data = j.stringAttributeForKey("data")
                                AlipaySDK.defaultService().payOrder(data, fromScheme: "nianalipay") { (resultDic) -> Void in
                                    let data = resultDic as NSDictionary
                                    let resultStatus = data.stringAttributeForKey("resultStatus")
                                    if resultStatus == "9000" {
                                        /* 支付宝：支付成功 */
                                        self.payMemberSuccess()
                                    } else {
                                        /* 支付宝：支付失败 */
                                        self.payMemberCancel()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if niAlert == self.alertResult {
            /* 如果是支付结果页面 */
            alert.dismissWithAnimation(.normal)
            alertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 移除整个支付界面 */
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        alert.dismissWithAnimation(.normal)
        if alertResult != nil {
            alertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 购买念币成功 */
    func payMemberSuccess() {
        alertResult = NIAlert()
        alertResult.delegate = self
        alertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付好了", "念币买好了！", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
        alert.dismissWithAnimationSwtich(alertResult)
        if let coin = Cookies.get("coin") as? String {
            if let _coin = Int(coin) {
                if let data = dataArray[index] as? NSDictionary {
                    let insertCoin = data.stringAttributeForKey("title")
                    let coinNew = _coin + Int(insertCoin)!
                    Cookies.set("\(coinNew)", forKey: "coin")
                }
            }
        }
    }
    
    /* 购买念币用户取消了操作 */
    func payMemberCancel() {
        if let btn = alert.niButtonArray.firstObject as? NIButton {
            btn.stopAnimating()
        }
        if let btn = alert.niButtonArray.lastObject as? NIButton {
            btn.stopAnimating()
        }
    }
    
    /* 购买念币失败 */
    func payMemberFailed() {
        alertResult = NIAlert()
        alertResult.delegate = self
        alertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付不成功", "服务器坏了！", ["哦"]], forKeys: ["img", "title", "content", "buttonArray"])
        alert.dismissWithAnimationSwtich(alertResult)
    }
    
    /* 微信购买念币回调 */
    func onWechatResult(sender: NSNotification) {
        if let object = sender.object as? String {
            if object == "0" {
                payMemberSuccess()
            } else if object == "-1" {
                payMemberFailed()
            } else {
                payMemberCancel()
            }
        }
    }
}