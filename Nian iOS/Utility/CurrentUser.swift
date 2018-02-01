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
            uidKey?.setObject(uid, forKey: kSecAttrAccount)
        }
        get {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            var cookieuid = uidKey?.object(forKey: kSecAttrAccount) as? String
            
            /**
            *  uid 和 shell 由于以前的原因，可能还在 userdefault 里
            */
            if (cookieuid!).characters.count > 0 && cookieuid != "" {
            } else {
                cookieuid = UserDefaults.standard.object(forKey: "uid") as? String
            }
            
            return cookieuid
        }
    }
    var shell: String? {
        set {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            uidKey?.setObject(shell, forKey: kSecValueData)
        }
        get {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            let cookieshell = uidKey?.object(forKey: kSecValueData) as? String
            return cookieshell
        }
    }
}
