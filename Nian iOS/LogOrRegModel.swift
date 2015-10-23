//
//  LogOrRegModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/21/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


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
    
    
}

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

class RegInfo: NSObject {
    var email: String?
    var nickname: String?
    var password: String?
    var mode: PlayMode?
    
    
    override init() {
        super.init()
    }
    
    
    convenience init(email: String, nickname: String, password: String) {
        self.init()
        
        self.email = email
        self.nickname = nickname
        self.password = password
    }
    
}





