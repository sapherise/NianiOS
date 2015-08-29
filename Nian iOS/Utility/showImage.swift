//
//  showImage.swift
//  Nian iOS
//
//  Created by Sa on 15/1/9.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
extension UIImageView {
    func showImage(imageURL: String, rect: CGRect = CGRectZero) {
        
        // 这是打开前的状态
        let w = rect.width
        let h = rect.height
        let x: CGFloat = rect.origin.x
        let y: CGFloat = rect.origin.y
        
        // 这是打开后的状态
        let nw = globalWidth
        let nh = globalWidth * h / w
        let nx: CGFloat = 0
        let ny: CGFloat = (globalHeight - nh)/2
        
        globalImageYPoint = CGRectMake(x, y, w, h)
        
        // 不为 gif 的话
        if imageURL.pathExtension != "gif!large" {
            let imageView = SAImageZoomingView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
            imageView.backgroundColor = UIColor.blackColor()
            imageView.imageURL = imageURL
            imageView.imageView!.frame = CGRectMake(x, y, w, h)
            self.window!.addSubview(imageView)
            
            // 放大的动画
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                imageView.imageView!.frame = CGRectMake(nx, ny, nw, nh)
            })
            
            // 单击
            let imageSingleTap = UITapGestureRecognizer(target: self, action: "onImageViewTap:")
            imageView.addGestureRecognizer(imageSingleTap)
            
            // 长按
            let imageLongPress = UILongPressGestureRecognizer(target: self, action: "onImageViewLongPress:")
            imageLongPress.minimumPressDuration = 0.2
            imageView.addGestureRecognizer(imageLongPress)
            
            // 双击
            let imageDoubleTap = UITapGestureRecognizer(target: self, action: "onImageViewDoubleTap:")
            imageDoubleTap.numberOfTapsRequired = 2
            imageSingleTap.requireGestureRecognizerToFail(imageDoubleTap)
            imageView.addGestureRecognizer(imageDoubleTap)
        } else {
            // gif 播放功能
            let viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
            let webView = UIWebView(frame: CGRectMake(nx, ny, nw, nh))
            let url = NSURL(string: "http://nian.so/api/gif.php?url=\(imageURL)")
            let request = NSURLRequest(URL: url!)
            webView.loadRequest(request)
            webView.userInteractionEnabled = false
            webView.hidden = true
            
            //var viewImage = UIImageView(frame: CGRectMake(0, -yPoint.y, CGFloat(globalWidth), heightGif))
            let viewImage = UIImageView(frame: rect)
            viewImage.setImage(imageURL, placeHolder: IconColor)
            viewHolder.addSubview(viewImage)
            viewHolder.addSubview(webView)
            viewHolder.backgroundColor = UIColor.blackColor()
            viewHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onGifTap:"))
            viewHolder.userInteractionEnabled = true
            self.window?.addSubview(viewHolder)
            webView.backgroundColor = UIColor.clearColor()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                viewImage.setY(ny)
                }, completion: { (Bool) -> Void in
                    webView.hidden = false
            })
        }
    }
    
    func onGifTap(sender: UIGestureRecognizer) {
        if let v = sender.view {
            let views:NSArray = v.subviews
            for view:AnyObject in views {
                if NSStringFromClass(view.classForCoder) == "UIWebView"  {
                    view.removeFromSuperview()
                }else if NSStringFromClass(view.classForCoder) == "UIImageView"  {
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        (view as! UIView).setY(globalImageYPoint.origin.y)
                        }) { (Bool) -> Void in
                            if sender.view != nil {
                                sender.view!.removeFromSuperview()
                            }
                    }
                }
            }
        }
    }
    
    func onImageViewTap(sender: UIGestureRecognizer) {
        if sender.view != nil {
            if let v = sender.view as? SAImageZoomingView {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    v.setZoomScale(1.0, animated: false)
                    v.imageView?.frame = globalImageYPoint
                    }) { (Bool) -> Void in
                        if sender.view != nil {
                            sender.view!.removeFromSuperview()
                        }
                }
            }
        }
    }
    
    func onImageViewDoubleTap(sender: UIGestureRecognizer) {
        let imageView = sender.view! as! SAImageZoomingView
        if imageView.zoomScale > 1.0 {
            imageView.setZoomScale(1.0, animated: true)
        } else {
            let point = sender.locationInView(self);
            imageView.zoomToRect(CGRectMake(point.x - 50, point.y - 50, 100, 100), animated: true)
        }
    }
    
    func onImageViewLongPress(sender: UIGestureRecognizer) {
        if let imageView = sender.view as? SAImageZoomingView {
            if sender.state == UIGestureRecognizerState.Began {
                let image = getCacheImage(imageView.imageURL)
                if image != nil {
                    let avc = SAActivityViewController.shareSheetInView(["喜欢念上的这张照片", image!], applicationActivities: [])
                    self.findRootViewController()?.presentViewController(avc, animated: true, completion: nil)
                }
            }
        }
    }
}