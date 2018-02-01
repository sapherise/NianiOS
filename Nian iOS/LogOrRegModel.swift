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





