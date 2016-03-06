//
//  WeChatActivityGeneral.swift
//  SuperBoard
//
//  Created by Xuzi Zhou on 1/12/15.
//  Copyright (c) 2015 Xuzi Zhou. All rights reserved.
//

import UIKit

class WeChatActivityGeneral: UIActivity {
    var text:String?
    var url:NSURL?
    var image:UIImage?
    var isSessionScene = true
    var isStep: Bool = false
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            for item in activityItems {
                if item is UIImage {
                    return true
                }
                if item is String {
                    return true
                }
                if item is NSURL {
                    return true
                }
            }
        }
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for item in activityItems {
            if item is UIImage {
                image = item as? UIImage
            }
            if item is String {
                text = item as? String
            }
            if item is NSURL {
                url = item as? NSURL
            }
        }
    }
    
    override func performActivity() {
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = WXMediaMessage()
        if isSessionScene {
            req.scene = Int32(WXSceneSession.rawValue)
        } else {
            req.scene = Int32(WXSceneTimeline.rawValue)
        }
        
        var imageNew = UIImage(named: "nian")!
        var textNew = "念" as NSString
        var urlNew = NSURL(string: "http://nian.so")!
        if image != nil {
            imageNew = image!
        }
        if text != nil {
            textNew = text! as NSString
            if textNew.length > 30 {
                textNew = textNew.substringToIndex(30)
            }
        }
        if url != nil {
            urlNew = url!
        }
        
        if isStep {
            let imageObject = WXImageObject()
            imageObject.imageData = UIImageJPEGRepresentation(imageNew, 1)
            req.message.mediaObject = imageObject
            WXApi.sendReq(req)
        } else {
            // 缩略图
            let width = 240.0 as CGFloat
            let height = width*(imageNew.size.height)/(imageNew.size.width)
            UIGraphicsBeginImageContext(CGSizeMake(width, height))
            imageNew.drawInRect(CGRectMake(0, 0, width, height))
            req.message.setThumbImage(UIGraphicsGetImageFromCurrentImageContext())
            UIGraphicsEndImageContext()
            let webObject = WXWebpageObject()
            webObject.webpageUrl = urlNew.absoluteString //.encode()
            req.message.mediaObject = webObject
            req.message.title = textNew as String
            req.message.description = "「念」\n小而美的记录应用，\n可以养宠物的日记本。"
            WXApi.sendReq(req)
        }
        self.activityDidFinish(true)
    }
}
