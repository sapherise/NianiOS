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
        if type == "vip" {
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
            let point = view.convertPoint(view.frame.origin, fromView: view.window)
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
                viewEmojiHolder.image = nil
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        /* 如果是支付方式选择界面 */
        if niAlert == self.niAlert {
            
            if didselectAtIndex == 0 {
                print("微信支付")
                //            let request = PayReq()
//                niAlert._containerView.
                
//                let _btn = niAlert.niButtonArray.firstObject as! NIButton
//                _btn.startAnimating()
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
                print("支付宝购买念币")
                Api.postAlipayMember() { json in
                    if json != nil {
                        if let j = json as? NSDictionary {
                            let data = j.stringAttributeForKey("data")
                            AlipaySDK.defaultService().payOrder(data, fromScheme: "nian://") { (resultDic) -> Void in
                                print("==")
                                print(resultDic)
                                print("==")
                                let data = resultDic as NSDictionary
                                let resultStatus = data.stringAttributeForKey("resultStatus")
                                let success = data.stringAttributeForKey("success")
                                if resultStatus == "9000" && success == "true" {
                                    print("支付成功")
                                } else {
                                    print("支付失败！")
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
}