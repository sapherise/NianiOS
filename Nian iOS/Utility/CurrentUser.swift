//
//  CurrentUser.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/2/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import Foundation


class CurrentUser {
    
    static let sharedCurrentUser = CurrentUser()
    
    var uid: String? {
        set {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            uidKey.setObject(uid, forKey: kSecAttrAccount)
        }
        get {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            var cookieuid = uidKey.objectForKey(kSecAttrAccount) as? String
            
            /**
            *  uid 和 shell 由于以前的原因，可能还在 userdefault 里
            */
            if (cookieuid!).characters.count > 0 && cookieuid != "" {
            } else {
                cookieuid = NSUserDefaults.standardUserDefaults().objectForKey("uid") as? String
            }
            
            return cookieuid
        }
    }
    var shell: String? {
        set {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            uidKey.setObject(uid, forKey: kSecAttrAccount)
        }
        
        get {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            let cookieshell = uidKey.objectForKey(kSecValueData) as? String
            
            return cookieshell
        }
    
    }
    
    private init() {
//        /// 读取保存在 keychain 里的 uid 和 shell
//        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
//        var cookieuid = uidKey.objectForKey(kSecAttrAccount) as? String
//        let cookieshell = uidKey.objectForKey(kSecValueData) as? String
//        
//        /**
//        *  uid 和 shell 由于以前的原因，可能还在 userdefault 里
//        */
//        if (cookieuid!).characters.count > 0 && cookieuid != "" {
//        } else {
//            cookieuid = NSUserDefaults.standardUserDefaults().objectForKey("uid") as? String
//        }
//        
//        if let _uid = cookieuid {
//            if cookieuid != "" {
//                uid = _uid
//            }
//        }
//        
//        if let _shell = cookieshell {
//            if cookieshell != "" {
//                shell = _shell
//            }
//        }

    }
    
}