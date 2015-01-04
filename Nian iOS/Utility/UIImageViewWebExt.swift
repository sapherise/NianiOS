//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView{
    
    func setImage(urlString: String,placeHolder: UIColor!, bool:Bool = true, cacheName: String? = nil) {
        var url = NSURL(string: urlString)
        var cacheFileName = (cacheName == nil ? url!.lastPathComponent : cacheName!)
        var cachePath = FileUtility.cachePath(cacheFileName!)
        var image: AnyObject = FileUtility.imageDataFromPath(cachePath)
        if image as NSObject != NSNull() {
            self.image = image as? UIImage
            self.contentMode = UIViewContentMode.ScaleAspectFill
        }else {
            dispatch_async(dispatch_get_main_queue(), {
                if bool == true {
                self.image = UIImage(named: "drop")!
                }
                self.backgroundColor = placeHolder
                self.contentMode = UIViewContentMode.Center
            })
            var networkStatus = checkNetworkStatus()
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var saveMode: String? = Sa.objectForKey("saveMode") as? String
            if saveMode == "1" && networkStatus != 2 {   //如果是开启了同时是在2G下
            }else{
                var req = NSURLRequest(URL: url!)
                var queue = NSOperationQueue();
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                        if (error == nil){
                            var image:UIImage? = UIImage(data: data)
                            if (image != nil) {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.image = image
                                    self.contentMode = UIViewContentMode.ScaleAspectFill
                                    FileUtility.imageCacheToPath(cachePath,image:data)
                                })
                            }
                        }
                    })
                })
            }
        }
    }
}


