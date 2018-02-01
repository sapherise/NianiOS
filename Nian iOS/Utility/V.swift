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
        case Empty = ""
    }
    
    static let Tags = ["日常", "摄影", "恋爱", "创业", "阅读", "追剧", "绘画", "英语", "收集", "健身", "音乐", "写作", "旅行", "美食", "设计", "游戏", "工作", "习惯", "写字", "其他"]
    
    typealias StringCallback = (String?) -> Void
    typealias JsonCallback = (AnyObject?) -> Void
    
    static func httpGetForJson(_ requestURL: String, callback: @escaping JsonCallback) {
        let manager = AFHTTPSessionManager()
        let url = requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.get(url!,
            parameters: nil,
            success: {(op: URLSessionDataTask?, obj: Any?) in
                callback(obj as AnyObject?)
            },
            failure: {(op: URLSessionDataTask?, error: Error?) in
                let t = DateFormatter()
                t.dateFormat = "HH:mm:ss"
                let s = t.string(from: Date())
                let e = s + "  " + "\(error)"
                let url = NSURL.fileURL(withPath: "/Users/Sa/Desktop/1.txt")
                let data = NSMutableData()
                data.append(e.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                data.write(toFile: url.path, atomically: true)
        })
    }
    
    static func httpPostForJson(_ requestURL: String, content: Any?, callback: @escaping JsonCallback) {
        let manager = AFHTTPSessionManager()
        let url = requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.post(url!, parameters: content, success: { (op: URLSessionDataTask?, obj: Any?) in
                callback(obj as AnyObject?)
        }) { (op: URLSessionDataTask?, error: Error?) in
            let t = DateFormatter()
            t.dateFormat = "HH:mm:ss"
            let s = t.string(from: Date())
            let e = s + "  " + "\(error)"
            let url = NSURL.fileURL(withPath: "/Users/Sa/Desktop/1.txt")
            let data = NSMutableData()
            data.append(e.data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            data.write(toFile: url.path, atomically: true)
        }
    }
    
    static func enTime(_ timestamp: String) -> String {
        let time = (timestamp as NSString).doubleValue
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return "\(formatter.string(from: Date(timeIntervalSince1970: time)))"
    }
    
    static func enTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return "\(formatter.string(from: Date()))"
    }
    
    static func now() -> String {
        return "\(Int(Date().timeIntervalSince1970))"
    }
    
    static func relativeTime(_ timestamp: String) -> String {
        let current = Date().timeIntervalSince1970
        let time = (timestamp as NSString).doubleValue
        let d = current - time
        let formatter = DateFormatter()
        var component = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second],
            from: Date())
        (component as NSDateComponents).timeZone = TimeZone.current
        component.hour = 0
        component.minute = 0
        component.second = 0
        let today = Calendar.current.date(from: component)!.timeIntervalSince1970
        if d < 10 {
            return "刚刚";
        } else if d < 60 {
            return "\(Int(d)) 秒前"
        } else if d < 3600 {
            return "\(NSNumber(value: floor(d / 60) as Double).intValue) 分前"
        }else if time >= today {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = TimeZone.current
        return "\(formatter.string(from: Date(timeIntervalSince1970: time)))"
    }
    
    static func relativeTime(_ time: TimeInterval, current: TimeInterval) -> String {
        let d = current - time
        let formatter = DateFormatter()
        if d < 10 {
            return "刚刚";
        } else if d < 60 {
            return "\(Int(d)) 秒前"
        } else if d < 3600 {
            return "\(NSNumber(value: floor(d / 60) as Double).intValue) 分前"
        } else if d < 86400 {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = TimeZone.current
        return "\(formatter.string(from: Date(timeIntervalSince1970: time)))"
    }
    
    static func absoluteTime(_ time: TimeInterval) -> String {
        let d = Date().timeIntervalSince1970 - time
        let formatter = DateFormatter()
        if d < 86400 {
            formatter.dateFormat = "HH:mm"
        } else if d < 31536000 {
            formatter.dateFormat = "MM-dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        formatter.timeZone = TimeZone.current
        return "\(formatter.string(from: Date(timeIntervalSince1970: time)))"
    }
    
    static func dataFromPath(_ path: String) -> Data? {
        if FileManager.default.fileExists(atPath: path) {
            return (try? Data(contentsOf: URL(fileURLWithPath: path)))
        }
        return nil
    }
    
    static func urlShareDream(_ did: String) -> URL {
        return URL(string: "http://nian.so/m/dream/\(did)")!
    }
    
    static func urlDreamImage(_ img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/dream/\(img)!\(tag.rawValue)"
    }
    
    static func urlHeadImage(_ uid: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/head/\(uid).jpg!\(tag.rawValue)"
    }
    
    static func urlStepImage(_ img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/step/\(img)!\(tag.rawValue)"
    }
    
    static func urlCircleCoverImage(_ img: String, tag: V.IMAGE_TAG) -> String {
        return "http://img.nian.so/step/\(img)!\(tag.rawValue)"
    }
    
    static func getDay(_ time: TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = TimeZone.current
        return "\(formatter.string(from: Date(timeIntervalSince1970: time)))"
    }
}

extension UIView {
    func findRootViewController() -> UIViewController? {
        var a: UIView? = self
        while a != nil {
            if let b = a?.next {
                if b is UIViewController {
                    return b as? UIViewController
                }
            }
            a = a?.superview
        }
        return nil
    }
}
