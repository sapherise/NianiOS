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
    
    class CustomActivity: UIActivity {
        
        var title: String?
        var image: UIImage?
        var callback: (([AnyObject]) -> Void)?
        
        init(title: String, image: UIImage?,callback: @escaping ([AnyObject]) -> Void) {
            super.init()
            self.title = title
            self.image = image
            self.callback = callback
        }
        
        // todo
//        override var activityType : String? {
//            return ""
//        }
        
        override var activityTitle : String? {
            return title
        }
        
        override var activityImage : UIImage? {
            return image
        }
        
        override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
            return true
        }
        
        override func prepare(withActivityItems activityItems: [Any]) {
            self.callback!(activityItems as [AnyObject])
        }
    }
    
    typealias StringCallback = (String?) -> Void
    typealias JsonCallback = (AnyObject?) -> Void
    
    static func httpGetForJson(_ requestURL: String, callback: @escaping JsonCallback) {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.get(requestURL,
            parameters: nil,
            success: {(op: URLSessionDataTask?, obj: Any?) in
                callback(obj as AnyObject?)
            },
            failure: {(op, error) in
        })
    }
    
    static func httpPostForJson_AFN(_ requestURL: String, content: Any?, callback: @escaping JsonCallback) {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.post(requestURL, parameters: content, success: { (op: URLSessionDataTask?, obj: Any?) in
                callback(obj as AnyObject?)
            }) { (op, error) in
        }
    }
    
    static func httpGetForJsonSync(_ requestURL: String, callback: @escaping JsonCallback) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let url = URL(string: requestURL)
            let data = try? Data(contentsOf: url!, options: NSData.ReadingOptions.uncached)
            var json: AnyObject? = nil
            if data != nil {
                json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
            }
            callback(json)
        })
    }
    
    static func httpGetForString(_ requestURL: String, callback: @escaping StringCallback) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let url = URL(string: requestURL)
            let data = try? Data(contentsOf: url!, options: NSData.ReadingOptions.uncached)
            var string: String?
            if data != nil {
                string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
            }
            DispatchQueue.main.async(execute: {
                callback(string)
            })
        })
    }
    
    static func httpPostForString(_ requestURL: String, content: String, callback: @escaping StringCallback) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let request = NSMutableURLRequest()
            request.url = URL(string: requestURL)
            request.httpMethod = "POST"
            request.httpBody = content.data(using: String.Encoding.utf8, allowLossyConversion : true)
            var response: URLResponse?
            var error: NSError?
            var data: Data?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning : &response)
            } catch let error1 as NSError {
                error = error1
                data = nil
            } catch {
                fatalError()
            }
            var string: String?
            if  error == nil {
                string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
            }
            DispatchQueue.main.async(execute: {
                callback(string)
            })
        })
        
    }
    
    static func httpPostForJson(_ requestURL: String, content: String, callback: @escaping JsonCallback) {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let request = NSMutableURLRequest()
            request.url = URL(string: requestURL)
            request.httpMethod = "POST"
            request.httpBody = content.data(using: String.Encoding.utf8, allowLossyConversion : true)
            var response: URLResponse?
            var data: Data?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning : &response)
            } catch _ as NSError {
                data = nil
            } catch {
                fatalError()
            }
            var json: AnyObject? = nil
            if data != nil {
                do {
                    json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
                } catch _ as NSError {
                    json = nil
                } catch {
                    fatalError()
                }

            }
            
            DispatchQueue.main.async(execute: {
                callback(json)
            })
        })
    }
    
    static func httpPostForJsonSync(_ requestURL: String, content: String, callback: @escaping JsonCallback) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let request = NSMutableURLRequest()
            request.url = URL(string: requestURL)
            request.httpMethod = "POST"
            request.httpBody = content.data(using: String.Encoding.utf8, allowLossyConversion : true)
            var response: URLResponse?
            var data: Data?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning : &response)
            } catch _ as NSError {
                data = nil
            } catch {
                fatalError()
            }
            var json: AnyObject? = nil
            if data != nil {
                json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
            }
            // 为什么没有回到主线程 ?
            callback(json)
        }
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
//        })
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
//        var view: UIView?
//        for view = self; view != nil; view = view!.superview {
//            if let responder = view?.next {
//                if responder is UIViewController {
//                    return responder as? UIViewController
//                }
//            }
//        }
         // todo
        return nil
    }
}
