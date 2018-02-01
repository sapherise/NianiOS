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
    func setImage(_ urlString: String, radius: CGFloat = 0) {
        self.backgroundColor = UIColor.GreyColor4()
        let url = URL(string: urlString)
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        if (saveMode == "on") && (networkStatus == 1) {   //如果是开启了同时是在流量下
            self.loadCacheImage(urlString, placeholderImage: self.image)
        } else {
            self.sd_setImage(with: url, completed: { (image, err, type, url) -> Void in
                if image != nil {
                    self.contentMode = .scaleAspectFill
                    self.image = image
                }
            })
        }
    }
    
    /* 进展中的单图要用到，用以显示进度条 */
    func setCell(_ urlString: String) {
        self.backgroundColor = UIColor.GreyColor4()
        let url = URL(string: urlString)
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        if (saveMode == "on") && (networkStatus == 1) {   //如果是开启了同时是在2G下
            self.loadCacheImage(urlString, placeholderImage: self.image)
        } else {
            let v = UIProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
            v.progressTintColor = UIColor.HighlightColor()
            v.trackTintColor = UIColor.e6()
            v.center = self.center
            v.isHidden = true
            
            delay(0.3, closure: { () -> () in
                v.isHidden = false
            })
            
            self.sd_setImage(with: url, completed: { (image, err, type, url) -> Void in
                if image != nil {
                    self.contentMode = .scaleAspectFill
                    self.image = image
                }
                }, using: v)
        }
    }
    
    func setPet(_ urlString: String) {
        let url = URL(string: urlString)
        self.sd_setImage(with: url) { (image, err, type, url) -> Void in
            if image != nil {
                self.contentMode = .scaleAspectFill
                self.image = image
            }
        }
    }
    
    func setImageIgnore(_ urlString: String) {
        setPet(urlString)
    }
    
    func setCover(_ urlString: String, ignore: Bool = false, animated: Bool = false) {
        self.backgroundColor = UIColor.black
        let url = URL(string: urlString)
        let networkStatus = getStatus()
        let saveMode = Cookies.get("saveMode") as? String
        if (saveMode == "on") && (networkStatus == 1) && (!ignore) {
            self.loadCacheImage(urlString, placeholderImage: self.image)
        } else {
            self.sd_setImage(with: url, completed: { (image, err, type, url) -> Void in
                if image != nil {
                    self.contentMode = .scaleAspectFill
                    self.image = image
                    if animated {
                        self.setAnimated()
                    }
                }
            })
        }
    }
    
    func setHead(_ uid: String) {
        self.image = UIImage(named: "head")
        let urlString = "http://img.nian.so/head/\(uid).jpg!dream"
        if let url = URL(string: urlString) {
            self.contentMode = .scaleAspectFill
            let networkStatus = getStatus()
            let saveMode = Cookies.get("saveMode") as? String
            if (saveMode == "on") && (networkStatus == 1) {
                self.loadCacheImage(urlString, placeholderImage: self.image)
            } else {
                if let placeholder = UIImage(named: "head") {
                    self.sd_setImage(with: url, placeholderImage: placeholder)
                }
            }
        }
    }
    
    // 设置图片渐变动画
    func setAnimated(){
        self.alpha = 0
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.alpha = 1
            }, completion: nil)
    }
    
    func loadCacheImage(_ urlString: String, placeholderImage: UIImage?) {
        let cachedImage: UIImage? = SDImageCache.shared().imageFromDiskCache(forKey: urlString)
        if cachedImage != nil {
            self.image = cachedImage
            self.contentMode = .scaleAspectFill
        } else {
            self.image = placeholderImage
        }
    }
    
}
