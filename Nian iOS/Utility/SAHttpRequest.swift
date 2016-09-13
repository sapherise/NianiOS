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
    
    class func requestWithURL(_ urlString:String,completionHandler:@escaping (_ data:AnyObject)->Void)
    {
        let URL = Foundation.URL(string: urlString)
        let req = URLRequest(url: URL!)
        let queue = OperationQueue();
        NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
            if (error != nil) {
                DispatchQueue.main.async(execute: {
                    completionHandler(NSNull())
                })
            }else{
                if data != nil {
                    let jsonData = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if jsonData != nil {
                        DispatchQueue.main.async(execute: {
                            completionHandler(jsonData!)
                        })
                    }
                }
            }
        })
    }
    
    
    
}
