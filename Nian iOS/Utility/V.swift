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
    
    /*class Downloader: NSObject, NSURLConnectionDataDelegate {
        
        private var _connection: NSURLConnection?
        private var _callback: (Float, AnyObject?) -> Void
        private var _data: NSMutableData? = nil
        private var _size: Int = 0
        
        init(url: NSURL, callback: (Float, AnyObject?) -> Void) {
            _callback = callback
            super.init()
            var request = NSURLRequest(URL: url)
            _connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
        
        func cancel() {
            if _connection != nil {
                _connection!.cancel()
                _connection = nil
            }
        }
        
        func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
            if response is NSHTTPURLResponse {
                var httpResponse = response as NSHTTPURLResponse
                var contentLength = httpResponse.allHeaderFields["Content-Length"] as NSNumber
                var _size = contentLength.integerValue
                _data = NSMutableData(capacity: _size)
                _callback(0.0, contentLength)
            } else {
                connection.cancel()
                _callback(0.0, nil)
            }
        }
        
        func connection(connection: NSURLConnection, didReceiveData data: NSData) {
            _data!.appendData(data)
            _callback(Float(_data!.length) / Float(_size), nil)
        }
        
        func connectionDidFinishLoading(connection: NSURLConnection) {
            _callback(1.0, _data)
        }
    }*/
    
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
    
    static func httpPostForJson(requestURL: String, content: String, callback: JsonCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var request = NSMutableURLRequest()
            request.URL = NSURL(string: requestURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
            var response: NSURLResponse?
            var error: NSError?
            var data = NSURLConnection.sendSynchronousRequest(request, returningResponse : &response, error: &error)
            var json: AnyObject? = nil
            if data != nil {
                json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            }
            dispatch_async(dispatch_get_main_queue(), {
                callback(json)
            })
        })
    }
    
    static func relativeTime(time: NSTimeInterval, current: NSTimeInterval) -> String {
        var d = current - time
        var formatter = NSDateFormatter()
        if d < 10 {
            return "刚刚";
        } else if d < 60 {
            return "\(d)秒前"
        } else if d < 3600 {
            return "\(NSNumber(double: floor(d / 60)).integerValue)分前"
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
    
    static func dataFromPath(path: String) -> NSData? {
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return NSData(contentsOfFile: path)
        }
        return nil
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
        tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
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
    
    func showImage(imageURL: String, width: Float, height: Float, yPoint: CGFloat = 0) {
        if true || imageURL.pathExtension != "gif!large" {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var w = CGFloat(width)
            var h = CGFloat(height)
            if w > globalWidth || h > globalHeight {
                if w / globalWidth > h / globalHeight {
                    h = h * globalWidth / w
                    w = globalWidth
                } else {
                    w = w * globalHeight / h
                    h = globalHeight
                }
                x = (globalWidth - w) / 2
                y = (globalHeight - h) / 2
            }
            globalImageYPoint = yPoint - y
            var imageView = SAImageZoomingView(frame: CGRectMake(0, 0, globalWidth, globalHeight), x: x, y: y, w: w, h: h)
            imageView.imageView!.frame.origin.y = yPoint - y
            imageView.backgroundColor = UIColor.blackColor()
            imageView.imageURL = imageURL
            var imageDoubleTap = UITapGestureRecognizer(target: self, action: "onImageViewDoubleTap:")
            imageDoubleTap.numberOfTapsRequired = 2
            var imageSingleTap = UITapGestureRecognizer(target: self, action: "onImageViewTap:")
            imageSingleTap.requireGestureRecognizerToFail(imageDoubleTap)
            var imageLongPress = UILongPressGestureRecognizer(target: self, action: "onImageViewLongPress:")
            imageLongPress.minimumPressDuration = 0.2
            imageView.addGestureRecognizer(imageDoubleTap)
            imageView.addGestureRecognizer(imageSingleTap)
            imageView.addGestureRecognizer(imageLongPress)
            self.window!.addSubview(imageView)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                imageView.imageView!.frame.origin.y = 0
            })
        } else {
            var view = GIFPlayer(frame: CGRectMake(0, 0, CGFloat(width), CGFloat(height)))
            view.play(V.dataFromPath(V.imageCachePath(imageURL))!)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageViewTap:"))
            self.window!.addSubview(view)
        }
    }
    
    func onImageViewTap(sender: UITapGestureRecognizer) {
        if sender.view != nil {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                (sender.view! as SAImageZoomingView).imageView!.frame.origin.y = globalImageYPoint
                }) { (Bool) -> Void in
                    if sender.view != nil {
                        sender.view!.removeFromSuperview()
                    }
            }
        }
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
