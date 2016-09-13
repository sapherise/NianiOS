//
//  WeChatSessionActivity.swift
//  SuperBoard
//
//  Created by Xuzi Zhou on 1/12/15.
//  Copyright (c) 2015 Xuzi Zhou. All rights reserved.
//

import UIKit

class WeChatSessionActivity: WeChatActivityGeneral {
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.share
    }
    
    override var activityType : String? {
        return Bundle.main.bundleIdentifier! + ".WeChatSessionActivity"
    }
    
    override var activityTitle : String? {
        isSessionScene = true
        return "微信"
    }
    
    // 浮游
    
    override var activityImage : UIImage? {
        return UIImage(named: "wechat_session")
    }
}
