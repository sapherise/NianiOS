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
        c.btnMain.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return c
    }
    
    //==
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        /* 如果是支付方式选择界面 */
        if niAlert == self.alert {
            
            if didselectAtIndex == 0 {
                print("微信支付")
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
                                print(j)
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
                                        self.alertResult = NIAlert()
                                        self.alertResult.delegate = self
                                        self.alertResult.dict = ["img": UIImage(named: "pay_result")!, "title": "支付好了", "content": "念币买好了！", "buttonArray": [" 嗯！"]]
                                        self.alert.dismissWithAnimationSwtich(self.alertResult)
                                        
                                        if let coin = Cookies.get("coin") as? String {
                                            if let _coin = Int(coin) {
                                                let coinNew = _coin + Int(title)!
                                                Cookies.set("\(coinNew)", forKey: "coin")
                                            }
                                        }
                                    } else {
                                        /* 支付宝：支付失败 */
                                        if let btn = self.alert.niButtonArray.lastObject as? NIButton {
                                            btn.stopAnimating()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if niAlert == self.alertResult {
            alert.dismissWithAnimation(.normal)
            alertResult.dismissWithAnimation(.normal)
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        alert.dismissWithAnimation(.normal)
        if alertResult != nil {
            alertResult.dismissWithAnimation(.normal)
        }
    }
}