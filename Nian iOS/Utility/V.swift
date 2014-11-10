//
//  V.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

struct V {
    
    static func relativeTime(time: NSTimeInterval, current: NSTimeInterval) -> String {
        var d = current - time
        println(time)
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
}
