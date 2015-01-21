//
//  WeChatSessionActivity.swift
//  SuperBoard
//
//  Created by Xuzi Zhou on 1/12/15.
//  Copyright (c) 2015 Xuzi Zhou. All rights reserved.
//

import UIKit

class WeChatSessionActivity: WeChatActivityGeneral {
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Share
    }
    
    override func activityType() -> String? {
        return NSBundle.mainBundle().bundleIdentifier! + ".WeChatSessionActivity"
    }
    
    override func activityTitle() -> String? {
        isSessionScene = true
        return "微信"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "wechat_session")
    }
}
