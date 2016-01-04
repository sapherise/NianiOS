//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation
//import WebImage

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
        if (saveMode == "on") && (networkStatus == 1) {   //如果是开启了同时是在2G下
            self.loadCacheImage(urlString, placeholderImage: self.image)
        } else {
            self.sd_setImageWithURL(url, completed: { (image, err, type, url) -> Void in
                if image != nil {
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
                }
            })
        }
    }
    
    func setPet(urlString: String) {
        let url = NSURL(string: urlString)
        self.sd_setImageWithURL(url) { (image, err, type, url) -> Void in
            if image != nil {
                self.contentMode = .ScaleAspectFill
                self.image = image
            }
        }
    }
    
    func setImageIgnore(urlString: String) {
        setPet(urlString)
    }
    
    func setCover(urlString: String, ignore: Bool = false, animated: Bool = false, radius: CGFloat = 0) {
        self.backgroundColor = UIColor.blackColor()
        let url = NSURL(string: urlString)
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        if (saveMode == "on") && (networkStatus == 1) && (!ignore) {
            self.loadCacheImage(urlString, placeholderImage: self.image)
        } else {
            self.sd_setImageWithURL(url, completed: { (image, err, type, url) -> Void in
                if image != nil {
                    self.contentMode = .ScaleAspectFill
                    self.image = image
                    if animated {
                        self.setAnimated()
                    }
                }
            })
        }
    }
    
    func setHead(uid: String) {
        self.image = UIImage(named: "head")
        let urlString = "http://img.nian.so/head/\(uid).jpg!dream"
        let url = NSURL(string: urlString)
        self.contentMode = .ScaleAspectFill
        let networkStatus = getStatus()
        print(urlString)
        let saveMode = Cookies.get("saveMode") as? String
        if (saveMode == "on") && (networkStatus == 1) {
            print("2")
            self.loadCacheImage(urlString, placeholderImage: self.image)
        } else {
            self.sd_setImageWithURL(url, placeholderImage: UIImage(named: "head"), completed: { (image, err, type, url) -> Void in
                if image != nil {
                    self.image = image
                }
            })
        }
    }
    
    // 设置图片渐变动画
    func setAnimated(){
        self.alpha = 0
        UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.alpha = 1
            }, completion: nil)
    }
    
    func loadCacheImage(urlString: String, placeholderImage: UIImage?) {
        let cachedImage: UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(urlString)
        if cachedImage != nil {
            self.image = cachedImage
            self.contentMode = .ScaleAspectFill
        } else {
            self.image = placeholderImage
        }
    }
    
}