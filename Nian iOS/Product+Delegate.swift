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
        if didselectAtIndex == 0 {
            print("微信支付")
//            let request = PayReq()
            
            /** 商家向财付通申请的商家id */
            Api.postWechatPay("6", coins: "12") { json in
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
//                            print(dataResult)
//                            request.timeStamp = Int(dataResult.stringAttributeForKey("noncestr"))
                            request.sign = dataResult.stringAttributeForKey("sign")
                            let a = WXApi.sendReq(request)
                            print(a)
                            
                            print(request.partnerId)
                            print(request.prepayId)
                            print(request.package)
                            print(request.nonceStr)
                            print(request.timeStamp)
                            print(request.sign)
//                            print(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                        }
                    }
                }
            }
        } else {
            print("支付宝支付")
        }
    }
}