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
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c: RechargeCell! = tableView.dequeueReusableCell(withIdentifier: "RechargeCell", for: indexPath) as? RechargeCell
        c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        c.num = (indexPath as NSIndexPath).row
        c.numMax = dataArray.count
        c.setup()
        c.btnMain.tag = (indexPath as NSIndexPath).row
        c.btnMain.addTarget(self, action: #selector(self.onClick(_:)), for: UIControlEvents.touchUpInside)
        return c
    }
    
    //==
    
    func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int) {
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
                                let data = Data(base64Encoded: j.stringAttributeForKey("data"), options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                                let base64Decoded = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                let jsonString = base64Decoded?.data(using: String.Encoding.ascii.rawValue)
                                if let dataResult = try? JSONSerialization.jsonObject(with: jsonString!, options: JSONSerialization.ReadingOptions.allowFragments) {
                                    let request = PayReq()
                                    request.partnerId = (dataResult as AnyObject).stringAttributeForKey("partnerid")
                                    request.prepayId = (dataResult as AnyObject).stringAttributeForKey("prepayid")
                                    request.package = (dataResult as AnyObject).stringAttributeForKey("package")
                                    request.nonceStr = (dataResult as AnyObject).stringAttributeForKey("noncestr")
                                    request.timeStamp = UInt32((dataResult as AnyObject).stringAttributeForKey("timestamp"))!
                                    request.sign = (dataResult as AnyObject).stringAttributeForKey("sign")
                                    WXApi.send(request)
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
//                                    let data = resultDic as NSDictionary
//                                    let resultStatus = data.stringAttributeForKey("resultStatus")
//                                    if resultStatus == "9000" {
//                                        /* 支付宝：支付成功 */
//                                        self.payMemberSuccess()
//                                    } else {
//                                        /* 支付宝：支付失败 */
//                                        self.payMemberCancel()
//                                    }
                                    // todo
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
    func niAlert(_ niAlert: NIAlert, tapBackground: Bool) {
        alert.dismissWithAnimation(.normal)
        if alertResult != nil {
            alertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 购买念币成功 */
    func payMemberSuccess() {
        alertResult = NIAlert()
        alertResult.delegate = self
        alertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付好了", "念币买好了！", [" 嗯！"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
        alert.dismissWithAnimationSwtich(alertResult)
        if let coin = Cookies.get("coin") as? String {
            if let _coin = Int(coin) {
                if let data = dataArray[index] as? NSDictionary {
                    let insertCoin = data.stringAttributeForKey("title")
                    let coinNew = _coin + Int(insertCoin)!
                    Cookies.set("\(coinNew)" as AnyObject?, forKey: "coin")
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
        alertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付不成功", "服务器坏了！", ["哦"]], forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
        alert.dismissWithAnimationSwtich(alertResult)
    }
    
    /* 微信购买念币回调 */
    func onWechatResult(_ sender: Notification) {
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
