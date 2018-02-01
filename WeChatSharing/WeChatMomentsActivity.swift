//
//  WeChatMomentsActivity.swift
//  SuperBoard
//
//  Created by Xuzi Zhou on 1/12/15.
//  Copyright (c) 2015 Xuzi Zhou. All rights reserved.
//

import UIKit

class WeChatMomentsActivity: WeChatActivityGeneral {
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.share
    }
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: Bundle.main.bundleIdentifier! + ".WeChatMomentsActivity")
    }
    
    override var activityTitle : String? {
        isSessionScene = false
        return "朋友圈"
    }
    
    override var activityImage : UIImage? {
        return UIImage(named: "wechat_moments")
    }
    
}
