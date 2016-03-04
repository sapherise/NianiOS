//
//  Product+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 16/2/25.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension Product {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let y = scrollView.contentOffset.y
            imageHead.setY(max(-y, 0))
            viewCover.setY(globalWidth * 3/4 - y)
            let h = globalHeight - globalWidth * 3/4 + y
            viewCover.setHeight(max(h, 0))
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if type == ProductType.Pro {
            let c: ProductCollectionCell! = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCollectionCell", forIndexPath: indexPath) as? ProductCollectionCell
            c.data = dataArray[indexPath.row] as! NSDictionary
            c.setup()
            return c
        } else {
            /* 表情 */
            let c: ProductEmojiCollectionCell! = collectionView.dequeueReusableCellWithReuseIdentifier("ProductEmojiCollectionCell", forIndexPath: indexPath) as? ProductEmojiCollectionCell
            c.data = dataArray[indexPath.row] as! NSDictionary
            c.num = indexPath.row
            c.imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onGif:"))
            c.setup()
            return c
        }
    }
    
    func onGif(sender: UILongPressGestureRecognizer) {
        if let view = sender.view {
            let tag = view.tag
            let point = view.convertPoint(view.frame.origin, fromView: scrollView)
            let x = -point.x
            let y = -point.y
            let xNew = max(x - 20, 0)
            let yNew = y - view.width() - 40 - 8
            let data = dataArray[tag] as! NSDictionary
            let image = data.stringAttributeForKey("image")
            viewEmojiHolder.qs_setGifImageWithURL(NSURL(string: image), progress: { (a, b) -> Void in
                }, completed: nil)
            viewEmojiHolder.frame = CGRectMake(xNew, yNew, view.width() + 50, view.width() + 50)
            viewEmojiHolder.hidden = sender.state == UIGestureRecognizerState.Ended ? true : false
            if sender.state == UIGestureRecognizerState.Ended {
                viewEmojiHolder.animatedImage = nil
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        /* 如果是支付方式选择界面 */
        if niAlert == self.niAlert {
            if type == ProductType.Pro {
                if didselectAtIndex == 0 {
                    if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                        btn.startAnimating()
                    }
                    
                    /** 商家向财付通申请的商家id */
                    Api.postWechatMember() { json in
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
                                    
                                    let b = dataResult.stringAttributeForKey("timestamp")
                                    let c = UInt32(b)
                                    request.timeStamp = c!
                                    request.sign = dataResult.stringAttributeForKey("sign")
                                    WXApi.sendReq(request)
                                }
                            }
                        }
                    }
                } else {
                    /* 支付宝购买念币 */
                    if let btn = niAlert.niButtonArray.lastObject as? NIButton {
                        btn.startAnimating()
                    }
                    Api.postAlipayMember() { json in
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
            } else if type == ProductType.Emoji {
                /* 购买表情 */
                if didselectAtIndex == 0 {
                    if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                        btn.startAnimating()
                    }
                    let code = data.stringAttributeForKey("code")
                    Api.postEmojiBuy(code) { json in
                        if json != nil {
                            if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                                btn.startAnimating()
                            }
                            if let j = json as? NSDictionary {
                                let error = j.stringAttributeForKey("error")
                                if error == "0" {
                                    self.niAlertResult = NIAlert()
                                    self.niAlertResult.delegate = self
                                    self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "买好了", "你获得了一组新表情！", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                                    self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    self.setButtonEnable(Product.btnMainState.hasBought)
                                    /* 修改本地的可能情况 */
                                    if let emojis = Cookies.get("emojis") as? NSMutableArray {
                                        let arr = NSMutableArray()
                                        for _emoji in emojis {
                                            if let emoji = _emoji as? NSDictionary {
                                                let e = NSMutableDictionary(dictionary: emoji)
                                                let newCode = emoji.stringAttributeForKey("code")
                                                if code == newCode {
                                                    e.setValue("1", forKey: "owned")
                                                }
                                                arr.addObject(e)
                                            }
                                        }
                                        Cookies.set(arr, forKey: "emojis")
                                    }
                                    
                                    self.delegate?.load()
                                    
                                    // todo: 逻辑！先看有没有 emojis 的缓存，如果没有，读取，然后缓存。总之就是要有。
                                    // 然后看下如果拥有，就展现八个，如果没有，就出现一个按钮跳转。
                                    
                                    /* 扣除本地的念币 */
                                    if let data = j.objectForKey("data") as? NSDictionary {
                                        let cost = data.stringAttributeForKey("cost")
                                        if let _cost = Int(cost) {
                                            if let coin = Cookies.get("coin") as? String {
                                                if let _coin = Int(coin) {
                                                    let coinNew = _coin - _cost
                                                    Cookies.set("\(coinNew)", forKey: "coin")
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.niAlertResult = NIAlert()
                                    self.niAlertResult.delegate = self
                                    self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "你的念币不够...", ["哦"]], forKeys: ["img", "title", "content", "buttonArray"])
                                    self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    // todo: 有已经购买过的情况，例如在 A 设备登录了，保存了表情缓存。然后在 B 设备登录并且购买，那么在 A 设备到达这个页面时，会告知没有购买过
                                }
                            }
                        }
                    }
                }
            } else if type == ProductType.Plugin {
                if didselectAtIndex == 0 {
                    let name = data.stringAttributeForKey("name")
                    if name == "请假" {
                        if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                            btn.startAnimating()
                        }
                        Api.postLeave() { json in
                            if json != nil {
                                if let j = json as? NSDictionary {
                                    let error = j.stringAttributeForKey("error")
                                    if error == "0" {
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "买好了", "请假好了！早点回来！", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                        if let coin = Cookies.get("coin") as? String {
                                            if let _coin = Int(coin) {
                                                let coinNew = _coin - 2
                                                Cookies.set("\(coinNew)", forKey: "coin")
                                            }
                                        }
                                    } else {
                                        // todo: 念币不够的时候
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "念币不够...", [" 哦"]], forKeys: ["img", "title", "content", "buttonArray"])
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    }
                                }
                            }
                        }
                    } else if name == "毕业证" {
                        if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                            btn.startAnimating()
                        }
                        Api.getGraduate() { json in
                            if json != nil {
                                if let j = json as? NSDictionary {
                                    let error = j.stringAttributeForKey("error")
                                    if error == "0" {
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "毕业", "恭喜毕业！\n我们奖励了一颗小星星给你\n重启应用看看", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                        if let coin = Cookies.get("coin") as? String {
                                            if let _coin = Int(coin) {
                                                let coinNew = _coin - 100
                                                Cookies.set("\(coinNew)", forKey: "coin")
                                            }
                                        }
                                    } else {
                                        /* 念币不够 */
                                        self.niAlertResult = NIAlert()
                                        self.niAlertResult.delegate = self
                                        let message = j.stringAttributeForKey("message")
                                        if message == "you have graduate." {
                                            self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "毕业过啦", [" 哦"]], forKeys: ["img", "title", "content", "buttonArray"])
                                        } else {
                                            self.niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "失败了", "念币不够...", [" 哦"]], forKeys: ["img", "title", "content", "buttonArray"])
                                        }
                                        self.niAlert.dismissWithAnimationSwtich(self.niAlertResult)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if niAlert == self.niAlertResult {
            /* 如果是支付结果页面 */
            self.niAlert.dismissWithAnimation(.normal)
            self.niAlertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 移除整个支付界面 */
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        self.niAlert.dismissWithAnimation(.normal)
        if self.niAlertResult != nil {
            self.niAlertResult.dismissWithAnimation(.normal)
        }
    }
    
    /* 购买会员成功 */
    func payMemberSuccess() {
        niAlertResult = NIAlert()
        niAlertResult.delegate = self
        niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付好了", "获得念的永久会员啦！\n蟹蟹你对念的支持", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
        niAlert.dismissWithAnimationSwtich(niAlertResult)
        Cookies.set("1", forKey: "member")
        /* 按钮的状态变化 */
        setButtonEnable(Product.btnMainState.hasBought)
    }
    
    /* 购买会员用户取消了操作 */
    func payMemberCancel() {
        if let btn = niAlert.niButtonArray.firstObject as? NIButton {
            btn.stopAnimating()
        }
        if let btn = niAlert.niButtonArray.lastObject as? NIButton {
            btn.stopAnimating()
        }
    }
    
    /* 购买会员失败 */
    func payMemberFailed() {
        niAlertResult = NIAlert()
        niAlertResult.delegate = self
        niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付不成功", "服务器坏了！", ["哦"]], forKeys: ["img", "title", "content", "buttonArray"])
        niAlert.dismissWithAnimationSwtich(niAlertResult)
    }
    
    /* 微信购买会员回调 */
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