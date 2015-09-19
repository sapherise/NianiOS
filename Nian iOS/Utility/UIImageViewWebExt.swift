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
        let url = NSURL(string: urlString)
        if bool == true {
            self.image = UIImage(named: "drop")!
        } else {
            self.image = UIImage()
        }
        
        self.backgroundColor = placeHolder
        self.contentMode = .Center
        
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        if (saveMode == "1") && (networkStatus == 1) && (!ignore) {   //如果是开启了同时是在2G下
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
    
    func setCover(urlString: String, placeHolder: UIColor!, bool: Bool = true, ignore: Bool = false, animated: Bool = false) {
        let url = NSURL(string: urlString)
        if bool == true {
            self.image = UIImage(named: "drop")!
        } else {
            self.image = UIImage()
        }
        self.backgroundColor = placeHolder
        self.contentMode = .Center
        
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if (saveMode == "1") && (networkStatus == 1) && (!ignore) {    //如果是开启了同时还是在2G下
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
        let url = NSURL(string: "http://img.nian.so/head/\(uid).jpg!dream")
        self.image = UIImage(named: "head")
        self.contentMode = .ScaleAspectFill
        
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        if (saveMode == "1") && (networkStatus == 1) {
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
    
    /*=========================================================================================================================================*/
    /**
    更好的绘制圆角矩形， 性能好
    */
    func setImageWithRounded(radius: CGFloat, urlString: String, placeHolder: UIColor!, ignore: Bool = false) {
        let url = NSURL(string: urlString)
        
        self.image = UIImage(named: "drop")!
        self.contentMode = .Center
        
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if (saveMode == "1") && (networkStatus == 1) && (!ignore) {   //如果是开启了同时是在2G下
            self.loadCacheImage(req, placeholderImage: self.image!)
        } else {
            self.setImageWithURLRequest(req,
                placeholderImage: UIImage(named: "drop"),
                success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                    
                    /*================最佳的绘制圆角图片的方式==============*/
                    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
                    
                    /* 先设置将要 stroke 的颜色 */
                    let _color = UIColor.colorWithHex("#E6E6E6")
                    _color.set()
                    
                    /* 设置 bezierPath 并切去圆角 */
                    let bPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
                    bPath.addClip()
                    
                    /* 在新的 bezierPath 里面 draw image */
                    image.drawInRect(self.bounds)
                    
                    /* 在图片周围再画 0.5 的线宽，并填色 */
                    let SINGLE_LINE_HEIGHT = 1 / UIScreen.mainScreen().scale
                    bPath.lineWidth = SINGLE_LINE_HEIGHT
                    bPath.stroke()
                    
                    /* 获得当前图片 */
                    self.image = UIGraphicsGetImageFromCurrentImageContext()
                    
                    UIGraphicsEndImageContext()
                    
                    self.contentMode = .ScaleAspectFill
                },
                failure: nil)
        }
    }
    
    
    
    // 设置图片渐变动画
    func setAnimated(){
        self.alpha = 0
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.alpha = 1
            }, completion: nil)
    }
    
    func loadCacheImage(request: NSURLRequest, placeholderImage: UIImage) {
        let cachedImage: UIImage? = UIImageView.sharedImageCache().cachedImageForRequest(request)
        if cachedImage != nil {
            self.image = cachedImage
            self.contentMode = .ScaleAspectFill
        } else {
            self.image = placeholderImage
            self.contentMode = .Center
        }
    }

}


