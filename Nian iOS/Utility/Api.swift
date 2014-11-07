//
//  Nian.swift
//  Nian iOS
//
//  Created by vizee on 14/11/7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

struct Api {
    
    typealias ApiCallback = AnyObject? -> Void
    
    private static var load = false
    private static var uid: String!
    private static var shell: String!
    
    private static func loadCookies() {
        if (!load) {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            uid = Sa.objectForKey("uid") as String
            shell = Sa.objectForKey("user") as String
            load = true
        }
    }
    
    private static func httpGet(url: String, callback: ApiCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var url = NSURL(string: url)
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            dispatch_async(dispatch_get_main_queue(), {
                callback(json)
            })
        })
    }
    
    static func getUserMe(callback: ApiCallback) {
        loadCookies();
        httpGet("http://nian.so/api/user.php?uid=\(uid)&myuid=\(uid)", callback: callback)
    }
    
    static func getCoinDetial(page: String, callback: ApiCallback) {
        loadCookies();
        
    }
}
