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
        let c: ProductCollectionCell! = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCollectionCell", forIndexPath: indexPath) as? ProductCollectionCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.setup()
        return c
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
                print("支付宝支付")
                Api.postAlipayMember() { json in
                    if json != nil {
                        if let j = json as? NSDictionary {
                            let data = j.stringAttributeForKey("data")
                            AlipaySDK.defaultService().payOrder(data, fromScheme: "nian://") { (resultDic) -> Void in
                                print("==")
                                print(resultDic)
                                print("==")
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