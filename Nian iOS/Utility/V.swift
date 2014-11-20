//
//  V.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

struct V {
    
    enum IMAGE_TAG: String {
        case iOS = "ios"
        case iOSFo = "iosfo"
        case Head = "head"
        case Dream = "dream"
        case Large = "large"
    }
    
    class CustomActivity: UIActivity {
        
        var title: String?
        var image: UIImage?
        var callback: (([AnyObject]) -> Void)?
        
        init(title: String, image: UIImage?,callback: ([AnyObject]) -> Void) {
            super.init()
            self.title = title
            self.image = image
            self.callback = callback
        }
        
        override func activityType() -> String? {
            return ""
        }
        
        override func activityTitle() -> String? {
            return title
        }
        
        override func activityImage() -> UIImage? {
            return image
        }
        
        override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
            return true
        }
        
        override func prepareWithActivityItems(activityItems: [AnyObject]) {
            self.callback!(activityItems)
        }
    }
    
    typealias StringCallback = String? -> Void
    typealias JsonCallback = AnyObject? -> Void
    
    static func httpGetForJson(requestURL: String, callback: JsonCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var url = NSURL(string: requestURL)
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject? = nil
            if data != nil {
                json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(json)
            })
        })
    }
    
    static func httpGetForString(requestURL: String, callback: StringCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var url = NSURL(string: requestURL)
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var string: String?
            if data != nil {
                string = NSString(data: data!, encoding: NSUTF8StringEncoding)
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(string)
            })
        })
    }
    
    static func httpPostForString(requestURL: String, content: String, callback: StringCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var request = NSMutableURLRequest()
            request.URL = NSURL(string: requestURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
            var response: NSURLResponse?
            var error: NSError?
            var data = NSURLConnection.sendSynchronousRequest(request, returningResponse : &response, error: &error)
            var string: String?
            if  error == nil {
                string = NSString(data: data!, encoding: NSUTF8StringEncoding)
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(string)
            })
        })
    }
    
    static func relativeTime(time: NSTimeInterval, current: NSTimeInterval) -> String {
        var d = current - time
        var formatter = NSDateFormatter()
        if d < 10 {
            return "0s";
        } else if d < 60 {
            return "\(d)s"
        } else if d < 3600 {
            return "\(NSNumber(double: floor(d / 60)).integerValue)m"
        } else if d < 86400 {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
    
    static func imageCachePath(imageURL: String) -> String {
        var url = NSURL(string: imageURL)
        var cacheFilename = url!.lastPathComponent
        var cachePath = FileUtility.cachePath(cacheFilename)
        return cachePath
    }
    
    static func urlShareDream(did: String) -> String {
        return "http://nian.so/dream/\(did)"
    }
    
    static func urlDreamImage(img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/dream/\(img)!\(tag.rawValue)"
    }
    
    static func urlHeadImage(uid: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/head/\(uid).jpg!\(tag.rawValue)"
    }
    
    static func urlStepImage(img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/step/\(img)!\(tag.rawValue)"
    }
    
    static func getDay(time: NSTimeInterval) -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
}

extension UIView {
    
    func findRootViewController() -> UIViewController? {
        for var view: UIView? = self; view != nil; view = view!.superview {
            var responder = view?.nextResponder()
            if responder! is UIViewController {
                return responder as? UIViewController
            }
        }
        return nil
    }
    
    func showTipText(text: String, delay: Double) {
        var tipView = UIView()
        tipView.layer.masksToBounds = true
        tipView.layer.cornerRadius = 4
        tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let fontSize: CGFloat = 14
        let textWidth: CGFloat = 180
        
        var h: CGFloat = fontSize
        var w: CGFloat = text.stringWidthWith(fontSize, height: h)
        if w > textWidth {
            w = textWidth
            h = text.stringHeightWith(fontSize, width: textWidth)
        }
        var tipLabel = UILabel(frame: CGRectMake(15, 15, w, h))
        tipLabel.text = text
        tipLabel.font = UIFont.systemFontOfSize(fontSize)
        tipLabel.lineBreakMode = .ByWordWrapping
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = NSTextAlignment.Center
        tipLabel.textColor = UIColor.whiteColor()
        var size = CGSizeMake(w + 30, h + 30)
        tipView.frame.size = size
        tipView.frame.origin = CGPointMake((globalWidth - size.width) / 2, globalHeight * 0.5 - size.height / 2)
        tipView.addSubview(tipLabel)
        self.window!.addSubview(tipView)
        UIView.animateWithDuration(0.3, delay: delay, options: UIViewAnimationOptions.allZeros, animations: { tipView.alpha = 0 }, completion: {
            finished in
            tipView.removeFromSuperview()
        })
    }
    
    func popupActivity(items: [AnyObject], activities: [AnyObject]?, exclude: [AnyObject]?) {
        if let viewController = findRootViewController() {
            var activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
            activityViewController.excludedActivityTypes = exclude
            viewController.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    func showImage(imageURL: String, width: Float, height: Float) {
        var view = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        view.backgroundColor = UIColor.blackColor()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageViewClick:"))
        var imageView = SAImageZoomingView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        imageView.imageURL = imageURL
        var imageDoubleTap = UITapGestureRecognizer(target: self, action: "onImageViewDoubleTap:")
        imageDoubleTap.numberOfTapsRequired = 2
        var imageSingleTap = UITapGestureRecognizer(target: self, action: "onImageViewTap:")
        imageSingleTap.requireGestureRecognizerToFail(imageDoubleTap)
        var imageLongPress = UILongPressGestureRecognizer(target: self, action: "onImageViewLongPress:")
        imageLongPress.minimumPressDuration = 0.5
        imageView.addGestureRecognizer(imageDoubleTap)
        imageView.addGestureRecognizer(imageSingleTap)
        imageView.addGestureRecognizer(imageLongPress)
        view.addSubview(imageView)
        self.window!.addSubview(view)
    }
    
    func onImageViewDoubleTap(sender: UITapGestureRecognizer) {
        var imageView = sender.view! as SAImageZoomingView
        if imageView.zoomScale > 1.0 {
            imageView.setZoomScale(1.0, animated: true)
        } else {
            var point = sender.locationInView(self);
            imageView.zoomToRect(CGRectMake(point.x - 50, point.y - 50, 100, 100), animated: true)
        }
    }
    
    func onImageViewTap(sender: UITapGestureRecognizer) {
        if sender.view! is SAImageZoomingView {
            sender.view!.superview!.removeFromSuperview()
        } else {
            sender.view!.removeFromSuperview()
        }
    }
    
    func onImageViewLongPress(sender: UITapGestureRecognizer) {
        var imageView = sender.view! as SAImageZoomingView
        if sender.state == UIGestureRecognizerState.Began {
            var imageData: AnyObject = FileUtility.imageDataFromPath(V.imageCachePath(imageView.imageURL))
            popupActivity([ "喜欢念上的这张照片。http://nian.so", imageData ], activities: nil, exclude: [
                UIActivityTypeAssignToContact,
                UIActivityTypePrint,
                UIActivityTypeCopyToPasteboard,
                UIActivityTypeMail,
                UIActivityTypeMessage
                ])
            
        }
    }
}
