//
//  LogOrRegModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/21/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

/**
玩念的模式

- hard: <#hard description#>
- easy: <#easy description#>
*/
@objc enum PlayMode: Int {
    case hard
    case easy
}


class LogOrRegModel: NSObject {

    override init() {
        super.init()
    }
    
    convenience init(dict: NSDictionary) {
        self.init()
    }
    
    
    class func checkEmailValidation(email email: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get("check/email" + "?email=\(email)",
                                                  callback: callback)
    }
    
    class func logIn(email email: String, password: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post("user/login",
                                                content: ["email": "\(email)", "password": "\(password)"],
                                                callback: callback)
    }
    
    class func register(email email: String, password: String, username: String, daily: Int, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post("user/signup",
                                                content: ["username": "\(username)", "email": "\(email)",
                                                          "password": "\(password)", "daily": "\(daily)"],
                                                callback: callback)
    }
    
    class func check3rdOauth(id: String, type: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post("oauth/check",
                                                content: ["auth_id": "\(id)", "type": "\(type)"],
                                                callback: callback)
    }
    
    class func registerVia3rd(id: String, type: String, name: String, nameFrom3rd: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post("oauth/attempt",
                                                content: ["username": "\(name)", "nickname": "\(nameFrom3rd)" , "auth_id": "\(id)", "type": "\(type)"],
                                                callback: callback)
    }
    
    /**
     <#Description#>
     
     :param: id       <#id description#>
     :param: type     <#type description#>
     :param: callback <#callback description#>
     */
    class func logInVia3rd(id: String, type: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.post("oauth/login",
                                                content: ["auth_id": "\(id)", "type": "\(type)"],
                                                callback: callback)
    }
    
    
    /**
     <#Description#>
     
     :param: name     <#name description#>
     :param: callback <#callback description#>
     */
    class func checkNameAvailability(name name: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get("user/check" + "?username=\(name)",
                                                  callback: callback)
    }

    /**
    <#Description#>
    
    :param: accessToken <#accessToken description#>
    :param: openid      <#openid description#>
    :param: callback    <#callback description#>
    */
    class func getWechatName(accessToken: String, openid: String, callback: NetworkClosure) {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET("https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openid)&lang=zh_CN",
            parameters: nil,
            success: { (task, id) in
                callback(task: task, responseObject: id, error: nil)
            },
            failure: { (task, error) in
                callback(task: task, responseObject: nil, error: error)
        })
    }
    
    /**
     <#Description#>
     
     :param: accessToken <#accessToken description#>
     :param: openid      <#openid description#>
     :param: callback    <#callback description#>
     */
    class func getWeiboName(accessToken: String, openid: String, callback: NetworkClosure) {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET("https://api.weibo.com/2/users/show.json?access_token=\(accessToken)&uid=\(openid)",
            parameters: nil,
            success: { (task, id) in
                callback(task: task, responseObject: id, error: nil)
            },
            failure: { (task, error) in
                callback(task: task, responseObject: nil, error: error)
        })
    }
    
    /**
     <#Description#>
     
     :param: accessToken <#accessToken description#>
     :param: openid      <#openid description#>
     :param: appid       <#appid description#>
     :param: callback    <#callback description#>
     */
    class func getQQName(accessToken: String, openid: String, appid: String, callback: NetworkClosure) {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.GET("https://graph.qq.com/user/get_user_info?oauth_consumer_key=\(appid)&access_token=\(accessToken)&openid=\(openid)",
            parameters: nil,
            success: { (task, id) in
                callback(task: task, responseObject: id, error: nil)
            },
            failure: { (task, error) in
                callback(task: task, responseObject: nil, error: error)
        })
    }

    
}

// MARK: - User
class User: NSObject {
    var userId: String?
    var userShell: String?
    
    override init() {
        super.init()
        
    }
    
    convenience init(dict: NSDictionary) {
        self.init()
        
        self.userId = dict["uid"] as? String
        self.userShell = dict["shell"] as? String
    }
    
}

// MARK: - 注册时需要的信息
class RegInfo: NSObject {
    /// <#Description#>
    var email: String?
    ///
    var nickname: String?
    /// <#Description#>
    var password: String?
    /// 玩念的模式，简单 or 困难
    var mode: PlayMode?
    
    /**
    <#Description#>
    */
    override init() {
        super.init()
    }
    
    /**
    提供在未选择模式之前的 init 方法
    */
    convenience init(email: String, nickname: String, password: String) {
        self.init()
        
        self.email = email
        self.nickname = nickname
        self.password = password
    }
    
}





