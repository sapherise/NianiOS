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
        var Sa: NSUserDefaults = .standardUserDefaults()
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
        var req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if (saveMode == "1") && (networkStatus != 2) && (!ignore) {   //如果是开启了同时是在2G下
            self.loadCacheImage(req, placeholderImage: self.image!)
            if animated {
                self.setAnimated()
            }
        } else {
            self.setImageWithURLRequest(req,
                placeholderImage: nil,
                success: {[unowned self](request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
                    self.image = image
                    if animated {
                        self.setAnimated()
                    }
                    self.contentMode = UIViewContentMode.ScaleAspectFill
                }, failure: { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                    println("set Image error: \(error.localizedDescription)")
            })
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
            self.loadCacheImage(req, placeholderImage: self.image!)
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
            self.loadCacheImage(req, placeholderImage: self.image!)
            self.contentMode = .ScaleAspectFill
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

}


