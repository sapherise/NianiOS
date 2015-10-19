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
    func setImage(urlString: String, radius: CGFloat = 0) {
        self.backgroundColor = IconColor
        let url = NSURL(string: urlString)
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        if (saveMode == "1") && (networkStatus == 1) {   //如果是开启了同时是在2G下
            self.loadCacheImage(req, placeholderImage: self.image)
        } else {
            self.setImageWithURLRequest(req,
                placeholderImage: nil,
                success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                    self.contentMode = .ScaleAspectFill
                    if radius == 0 {
                        self.image = image
                    } else {
                        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, globalScale)
                        UIColor.e6().set()
                        let bPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
                        bPath.addClip()
                        image.drawInRect(self.bounds)
                        bPath.lineWidth = globalHalf
                        bPath.stroke()
                        self.image = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    }
                },
                failure: nil)
        }
    }
    
    func setPet(urlString: String) {
        let url = NSURL(string: urlString)
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        self.setImageWithURLRequest(req,
            placeholderImage: nil,
            success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                self.contentMode = .ScaleAspectFill
                self.image = image
            },
            failure: nil)
    }
    
    func setImageIgnore(urlString: String) {
        setPet(urlString)
    }
    
    func setCover(urlString: String, ignore: Bool = false, animated: Bool = false, radius: CGFloat = 0) {
        let _image = self.image
        self.backgroundColor = UIColor.blackColor()
        let url = NSURL(string: urlString)
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        if (saveMode == "1") && (networkStatus == 1) && (!ignore) {
            self.loadCacheImage(req, placeholderImage: self.image)
//                self.setAnimated()
        } else {
            self.setImageWithURLRequest(req,
                placeholderImage: nil,
                success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                    self.contentMode = .ScaleAspectFill
                    self.image = image
                    
                    // 当图片有变化时，才做淡入效果
                    if image != _image {
                        self.setAnimated()
                    }
                },
                failure: nil)
        }
    }
    
    func setHead(uid: String) {
        self.image = UIImage(named: "head")
        let url = NSURL(string: "http://img.nian.so/head/\(uid).jpg!dream")
        self.contentMode = .ScaleAspectFill
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        if (saveMode == "1") && (networkStatus == 1) {
            self.loadCacheImage(req, placeholderImage: self.image)
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
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.alpha = 1
            }, completion: nil)
    }
    
    func loadCacheImage(request: NSURLRequest, placeholderImage: UIImage?) {
        let cachedImage: UIImage? = UIImageView.sharedImageCache().cachedImageForRequest(request)
        if cachedImage != nil {
            self.image = cachedImage
            self.contentMode = .ScaleAspectFill
        } else {
            self.image = placeholderImage
        }
    }
    
}


