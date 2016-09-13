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
    
    // todo
//    class func checkEmailValidation(email: String, callback: @escaping NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.get("check/email" + "?email=\(email)", callback: callback)
//    }
//    
//    class func logIn(email: String, password: String, callback: NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.post("user/login", content: ["email": "\(email)", "password": "\(password)"], callback: callback)
//    }
//    
//    class func register(email: String, password: String, username: String, daily: Int, callback: NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.post("user/signup", content: ["username": "\(username)", "email": "\(email)", "password": "\(password)", "daily": "\(daily)"], callback: callback)
//    }
//    
//    class func check3rdOauth(_ id: String, type: String, callback: NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.post("oauth/check",
//                                                content: ["auth_id": "\(id)", "type": "\(type)"],
//                                                callback: callback)
//    }
//    
//    class func registerVia3rd(_ id: String, type: String, name: String, nameFrom3rd: String, callback: NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.post("oauth/attempt",
//                                                content: ["username": "\(name)", "nickname": "\(nameFrom3rd)" , "auth_id": "\(id)", "type": "\(type)"],
//                                                callback: callback)
//    }
    
    /**
     <#Description#>
     
     :param: email    <#email description#>
     :param: callback <#callback description#>
     */
    // todo
//    class func resetPaeeword(email: String, callback: NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.post("password/reset/mail",
//                                                content: ["email": "\(email)"],
//                                                callback: callback)
//    }
    
    
    /**
     <#Description#>
     
     :param: id       <#id description#>
     :param: type     <#type description#>
     :param: callback <#callback description#>
     */
//    class func logInVia3rd(_ id: String, type: String, callback: NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.post("oauth/login",
//                                                content: ["auth_id": "\(id)", "type": "\(type)"],
//                                                callback: callback)
//    }
    
    
    /**
     <#Description#>
     
     :param: name     <#name description#>
     :param: callback <#callback description#>
     */
//    class func checkNameAvailability(name: String, callback: @escaping NetworkClosure) {
//        NianNetworkClient.sharedNianNetworkClient.get("user/check" + "?username=\(SAEncode(SAHtml(name)))",
//                                                  callback: callback)
//    }

    /**
    <#Description#>
    
    :param: accessToken <#accessToken description#>
    :param: openid      <#openid description#>
    :param: callback    <#callback description#>
    */
//    class func getWechatName(_ accessToken: String, openid: String, callback: @escaping NetworkClosure) {
//        let manager = AFHTTPSessionManager()
//        manager.responseSerializer = AFJSONResponseSerializer()
//        
//        manager.get("https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openid)&lang=zh_CN",
//            parameters: nil,			
//            success: { (task, id) in
//                callback(task, id, nil)
//            },
//            failure: { (task, error) in
//                callback(task: task, responseObject: nil, error: error)
//        })
//    }
    
    /**
     <#Description#>
     
     :param: accessToken <#accessToken description#>
     :param: openid      <#openid description#>
     :param: callback    <#callback description#>
     */
//    class func getWeiboName(_ accessToken: String, openid: String, callback: @escaping NetworkClosure) {
//        let manager = AFHTTPSessionManager()
//        manager.responseSerializer = AFJSONResponseSerializer()
//        
//        manager.get("https://api.weibo.com/2/users/show.json?access_token=\(accessToken)&uid=\(openid)",
//            parameters: nil,
//            success: { (task, id) in
//                callback(task, id, nil)
//            },
//            failure: { (task, error) in
//                callback(task: task, responseObject: nil, error: error)
//        })
//    }
    
    /**
     <#Description#>
     
     :param: accessToken <#accessToken description#>
     :param: openid      <#openid description#>
     :param: appid       <#appid description#>
     :param: callback    <#callback description#>
     */
//    class func getQQName(_ accessToken: String, openid: String, appid: String, callback: @escaping NetworkClosure) {
//        let manager = AFHTTPSessionManager()
//        manager.responseSerializer = AFJSONResponseSerializer()
//        
//        manager.get("https://graph.qq.com/user/get_user_info?oauth_consumer_key=\(appid)&access_token=\(accessToken)&openid=\(openid)",
//            parameters: nil,
//            success: { (task: URLSessionDataTask?, id: Any?) in
//                callback(task!, id, nil)
//            },
//            failure: { (task, error) in
//                callback(task: task, responseObject: nil, error: error)
//        })
//    }

    // todo: 上面一大段
    
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





