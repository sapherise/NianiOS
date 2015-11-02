//
//  SettingModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/2/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


class SettingModel: NSObject {
    
    override init() {
        super.init()
    }
    
    /**
     获得用户的设置，如是否日更，和账号的一些信息，如手机号、性别等。
     */
    class func getUserInfoAndSetting(callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get("/user/\(CurrentUser.sharedCurrentUser.uid!)",
                                                callback: callback)
    }
    
    
}
