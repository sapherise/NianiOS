//
//  LogOrRegModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/21/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class LogOrRegModel: NSObject {
    var email: String?

    override init() {
        super.init()
    }
    
    convenience init(dict: NSDictionary) {
        self.init()
    }
    
    
    class func checkEmailValidation(url url: String, email: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(url + "?email=\(email)",
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