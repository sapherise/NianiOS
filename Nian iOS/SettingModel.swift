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
     获得用户第三方账号绑定情况
     */
    class func getUserAllOauth(callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(
            "oauth/all?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
                                                callback: callback)
    }
    
    /**
     绑定第三方账号
     */
    class func bindThirdAccount(id: String, name: String, nameFrom3rd: String, type: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post("oauth/auth/binding?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
                                                content: ["nickname": "\(nameFrom3rd)", "auth_id": "\(id)", "type": "\(type)"],
                                                callback: callback)
        
        
        
    }
    
    /**
     解除第三方账号绑定
     */
    class func relieveThirdAccount(type: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(
            "oauth/remove?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)&&type=\(type)",
                                                callback: callback)
    }
    
    /**
     更改封面
     */
    class func changeCoverImage(coverURL coverURL: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post(
            "user/\(CurrentUser.sharedCurrentUser.uid!)/cover/edit?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
                                                content: ["cover": coverURL],
                                                callback: callback)
    }
    
    /**
     已登录用户绑定邮箱
     */
    class func bindEmail(email: String, password: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post(
            "/oauth/email/binding?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
            content: ["email": email, "password": password],
            callback: callback)
        
        
    }
    
    /**
     更新账号信息和设置 
     */
    class func updateUserInfo(settingInfo: Dictionary<String, String>, callback: NetworkClosure) {
//<<<<<<< HEAD
//        NianNetworkClient.sharedNianNetworkClient.put(
//            "user/\(CurrentUser.sharedCurrentUser.uid!)?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
//=======

        NianNetworkClient.sharedNianNetworkClient.post(
            "user/\(CurrentUser.sharedCurrentUser.uid!)/edit?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
//>>>>>>> 72ec8c7377531596c27e76bc416a5ef32d175025
            content: settingInfo,
            callback: callback)
    
    }
}



















