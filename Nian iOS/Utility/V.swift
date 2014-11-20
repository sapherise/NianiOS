//
//  V.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

struct V {
    
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
    
    static func getDay(time: NSTimeInterval) -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: time)))"
    }
    
    static func getHeadURL(uid: String) -> String {
        return "http://img.nian.so/head/\(uid).jpg!head"
    }
}

extension UIView {
    
    func showTipText(text: String, delay: Double) {
        var viewController: UIViewController?
        for var view: UIView? = self; view != nil; view = view!.superview {
            var responder = view?.nextResponder()
            if responder! is UIViewController {
                viewController = responder as? UIViewController
            }
        }
        if viewController != nil {
            var tipView = UIView()
            tipView.layer.masksToBounds = true
            tipView.layer.cornerRadius = 4
            tipView.backgroundColor = UIColor.blackColor()
            
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
            viewController!.view.addSubview(tipView)
            UIView.animateWithDuration(0.3, delay: delay, options: UIViewAnimationOptions.allZeros, animations: { tipView.alpha = 0 }, completion: { finished in
                tipView.removeFromSuperview()
            })
        }
    }
}
