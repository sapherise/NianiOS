//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation

var _image_lock = NSLock()
var _image_task = [String: UIImageView]()
var _image_view = [UIImageView: String]()

extension UIImageView {
    
    // urlString 图片的网络路径
    // placeHolder 图片的背景颜色
    // bool 是否显示图片中间的水滴
    // ignore 是否无视网络环境加载图片
    // animated 加载完成后是否渐隐显示
    func setImage(urlString: String, placeHolder: UIColor!, bool: Bool = true, ignore: Bool = false, animated: Bool = false) {
        var url = NSURL(string: urlString)
        if bool == true {
            self.image = UIImage(named: "drop")!
        } else {
            self.image = UIImage()
        }
        
        self.backgroundColor = placeHolder
        self.contentMode = .Center
        
        var networkStatus = checkNetworkStatus()
        var Sa:NSUserDefaults = .standardUserDefaults()
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
        var req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if (saveMode == "1") && (networkStatus != 2) && (!ignore) {   //如果是开启了同时是在2G下
            //todo:加载缓存图片
            self.loadCacheImage(req, placeholderImage: UIImage(named: "drop")!)
            if animated {
                self.setAnimated()
            }
        } else {
            self.setImageWithURLRequest(req,
                                        placeholderImage: nil,
                                        success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                                            self.image = image
                                            if animated {
                                                self.setAnimated()
                                            }
                                            self.contentMode = .ScaleAspectFill
                                        },
                                        failure: nil)
        }
    }

    func setCover(urlString: String, placeHolder: UIColor!, bool: Bool = true, ignore: Bool = false, animated: Bool = false) {
        var url = NSURL(string: urlString)
        if bool == true {
            self.image = UIImage(named: "drop")!
        } else {
            self.image = UIImage()
        }
        self.backgroundColor = placeHolder
        self.contentMode = .Center
        
        var networkStatus = checkNetworkStatus()
        var Sa: NSUserDefaults = .standardUserDefaults()
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
        var req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if (saveMode == "1") && (networkStatus != 2) && (!ignore) {    //如果是开启了同时还是在2G下
            self.loadCacheImage(req, placeholderImage: UIImage(named: "drop")!)
            if animated {
                self.setAnimated()
            }
        } else {
            self.setImageWithURLRequest(req,
                                        placeholderImage: nil,
                                        success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                                            self.image = image
                                            if animated {
                                                self.setAnimated()
                                            }
                                            self.contentMode = .ScaleAspectFill
                                        },
                                        failure: nil)
        }
    }

    func setHead(uid: String) {
        var url = NSURL(string: "http://img.nian.so/head/\(uid).jpg!dream")
        self.image = UIImage(named: "head")
        self.contentMode = .ScaleAspectFill
        
        var networkStatus = checkNetworkStatus()
        var Sa: NSUserDefaults = .standardUserDefaults()
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
        var req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if (saveMode == "1") && (networkStatus != 2) {    //如果是开启了同时还是在2G下
            self.loadCacheImage(req, placeholderImage: UIImage(named: "drop")!)
        } else {
            self.setImageWithURLRequest(req,
                                        placeholderImage: nil,
                                        success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                                            self.image = image
                                        },
                                        failure: nil)
        }
        
        
    }
    
    // 设置图片渐变动画
    func setAnimated(){
        self.alpha = 0
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.alpha = 1
        })
    }
    
    func loadCacheImage(request: NSURLRequest, placeholderImage: UIImage) {
        var cachedImage: UIImage? = UIImageView.sharedImageCache().cachedImageForRequest(request)
        if cachedImage != nil {
            self.image = cachedImage
            self.contentMode = .ScaleAspectFill
        } else {
            self.image = placeholderImage
            self.contentMode = .Center
        }
    }
    
    
//    func setCover(urlString: String,placeHolder: UIColor!, bool:Bool = true, ignore:Bool = false, animated: Bool = false) {
//        var url = NSURL(string: urlString)
//        if bool == true {
//            self.image = UIImage(named: "drop")!
//        }else{
//            self.image = UIImage()
//        }
//        self.backgroundColor = placeHolder
//        self.contentMode = UIViewContentMode.Center
//        var cacheFileName = url!.lastPathComponent
//        var cachePath = FileUtility.cachePath(cacheFileName!)
//        var image: AnyObject = FileUtility.imageDataFromPath(cachePath)
//        if image as! NSObject != NSNull() {
//            self.image = image as? UIImage
//            self.contentMode = UIViewContentMode.ScaleAspectFill
//            if animated {
//                self.setAnimated()
//            }
//        }else {
//            var networkStatus = checkNetworkStatus()
//            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//            var saveMode: String? = Sa.objectForKey("saveMode") as? String
//            if (saveMode == "1") && (networkStatus != 2) && (!ignore) {   //如果是开启了同时是在2G下
//            }else{
//                var req = NSURLRequest(URL: url!)
//                var queue = NSOperationQueue();
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                    NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
//                        if (error == nil){
//                            var image:UIImage? = UIImage(data: data)
//                            if (image != nil) {
//                                dispatch_async(dispatch_get_main_queue(), {
//                                    self.image = image
//                                    if animated {
//                                        self.setAnimated()
//                                    }
//                                    self.contentMode = UIViewContentMode.ScaleAspectFill
//                                    FileUtility.imageCacheToPath(cachePath,image:data)
//                                })
//                            }
//                        }
//                    })
//                })
//            }
//        }
//    }
    
    
    
//    func setHead(uid: String) {
//        var url = NSURL(string: "http://img.nian.so/head/\(uid).jpg!dream")
//        self.image = UIImage(named: "head")
//        self.contentMode = UIViewContentMode.ScaleAspectFill
//        var cacheFileName = url!.lastPathComponent
//        var cachePath = FileUtility.cachePath(cacheFileName!)
//        var image: AnyObject = FileUtility.imageDataFromPath(cachePath)
//        if image as! NSObject != NSNull() {
//            self.image = image as? UIImage
//        }else {
//            var networkStatus = checkNetworkStatus()
//            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//            var saveMode: String? = Sa.objectForKey("saveMode") as? String
//            if (saveMode == "1") && (networkStatus != 2) {   //如果是开启了同时是在2G下
//            }else{
//                var req = NSURLRequest(URL: url!)
//                var queue = NSOperationQueue();
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                    NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
//                        if (error == nil){
//                            var image:UIImage? = UIImage(data: data)
//                            if (image != nil) {
//                                dispatch_async(dispatch_get_main_queue(), {
//                                    self.image = image
//                                    FileUtility.imageCacheToPath(cachePath,image:data)
//                                })
//                            }
//                        }
//                    })
//                })
//            }
//        }
//    }
    
    
//    func setImage(urlString: String,placeHolder: UIColor!, bool:Bool = true, ignore:Bool = false, animated: Bool = false) {
//        var url = NSURL(string: urlString)
//        if bool == true {
//            self.image = UIImage(named: "drop")!
//        }else{
//            self.image = UIImage()
//        }
//        self.backgroundColor = placeHolder
//        self.contentMode = .Center
//        var cacheFileName = url!.lastPathComponent
//        var cachePath = FileUtility.cachePath(cacheFileName!)
//        var image: AnyObject = FileUtility.imageDataFromPath(cachePath)
//        if image as! NSObject != NSNull() {
//            self.image = image as? UIImage
//            self.contentMode = UIViewContentMode.ScaleAspectFill
//            if animated {
//                self.setAnimated()
//            }
//        } else {
//            var networkStatus = checkNetworkStatus()
//            var Sa:NSUserDefaults = .standardUserDefaults()
//            var saveMode: String? = Sa.objectForKey("saveMode") as? String
//            if (saveMode == "1") && (networkStatus != 2) && (!ignore) {   //如果是开启了同时是在2G下
//            }else{
//                var download = false
//                _image_lock.lock()
//                if _image_task[urlString] == nil {
//                    download = true
//                }
//                _image_task[urlString] = self
//                _image_view[self] = urlString
//                _image_lock.unlock()
//                if !download {
//                    return
//                }
//                var req = NSURLRequest(URL: url!)
//                var queue = NSOperationQueue();
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                    NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
//                        if error != nil {
//                            return
//                        }
//                        FileUtility.imageCacheToPath(cachePath,image:data)
//                        var showImage = false
//                        _image_lock.lock()
//                        var view = _image_task.removeValueForKey(urlString)!
//                        if _image_view[view] == urlString {
//                            _image_view.removeValueForKey(view)
//                            showImage = true
//                        }
//                        _image_lock.unlock()
//                        if !showImage {
//                            return
//                        }
//                        var image:UIImage? = UIImage(data: data)
//                        if (image == nil) {
//                            return
//                        }
//                        dispatch_async(dispatch_get_main_queue(), {
//                            view.image = image
//                            if animated {
//                                view.setAnimated()
//                            }
//                            view.contentMode = UIViewContentMode.ScaleAspectFill
//                        })
//                    })
//                })
//            }
//        }
//    }

}


