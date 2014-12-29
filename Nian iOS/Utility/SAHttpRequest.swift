//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation

//class func connectionWithRequest(request: NSURLRequest!, delegate: AnyObject!) -> NSURLConnection!


class SAHttpRequest: NSObject {

    override init()
    {
        super.init();
    }
    
    class func requestWithURL(urlString:String,completionHandler:(data:AnyObject)->Void)
    {
        var URL = NSURL(string: urlString)
        var req = NSURLRequest(URL: URL!)
        var queue = NSOperationQueue();
        NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(data:NSNull())
                })
            }else{
                if data != nil {
                    let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(data:jsonData)
                    })
                }
            }
        })
    }
    
    
    
}
