//
//  SettingModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/2/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


class SettingModel: NSObject {
    
    var dailyMode: String = "0"
    var picOnCellar: String = "0"
    var saveCard: String = "1"
    var dailyRemind: String = "0"
    var findViaName: String = "0"
    
    var editProfileDictionary: Dictionary<String, String> = Dictionary()
    var accountBindDictionary: Dictionary<String, String> = Dictionary()
    
    override init() {
        super.init()
        
    }

    /**
     获得用户的设置，如是否日更，和账号的一些信息，如手机号、性别等。
     */
    class func getUserInfoAndSetting(callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(
            "user/\(CurrentUser.sharedCurrentUser.uid!)?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
                                                callback: callback)
    }
    
    /**
     获得用户第三方账户绑定情况
     */
    class func getUserAllOauth(callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(
            "oauth/all?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
                                                callback: callback)
    }
    
}
