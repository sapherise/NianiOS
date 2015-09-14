//
//  Topic + Function.swift
//  Nian iOS
//
//  Created by Sa on 15/9/14.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

func getRedditArray(content: String) -> NSMutableArray {
    let length = (content as NSString).length
    let regexImage = "<image:[a-z0-9._]* w:[0-9.]* h:[0-9.]*>"
    let regexDream = "<dream:[0-9]*>"
    let expImage = try! NSRegularExpression(pattern: regexImage, options: NSRegularExpressionOptions.CaseInsensitive)
    let expDream = try! NSRegularExpression(pattern: regexDream, options: NSRegularExpressionOptions.CaseInsensitive)
    let dreams = expDream.matchesInString(content, options: .ReportCompletion, range: NSMakeRange(0, length))
    let images = expImage.matchesInString(content, options: .ReportCompletion, range: NSMakeRange(0, length))
    let arr = NSMutableArray()
    for result in images {
        arr.addObject(result)
    }
    for result in dreams {
        arr.addObject(result)
    }
    if arr.count >= 2 {
        for _ in 0...(arr.count - 1) {
            for j in 0...(arr.count - 2) {
                if arr[j].range.location > arr[j + 1].range.location {
                    let tmp = arr[j]
                    arr[j] = arr[j + 1]
                    arr[j + 1] = tmp
                }
            }
        }
    }
    
    let dataArray = NSMutableArray()
    var location: Int = 0
    var count: Int = 0
    for result in arr {
        let range = result.range
        let subStr = (content as NSString).substringWithRange(NSMakeRange(location, range.location - location))
        if location < range.location {
            count++
            dataArray.addObject(["type": "text", "content": subStr, "count": "\(count)"])
        }
        location = NSMaxRange(range)
        var typeStr = (content as NSString).substringWithRange(NSMakeRange(range.location, range.length))
        if typeStr.isDream() {
            typeStr = SAReplace(typeStr, before: "<dream:", after: "") as String
            typeStr = SAReplace(typeStr, before: ">", after: "") as String
            count++
            dataArray.addObject(["type": "dream", "count": "\(count)", "id": typeStr])
        } else if typeStr.isImage() {
            let arrTypeStr = typeStr.componentsSeparatedByString(" ")
            let url = SAReplace(arrTypeStr[0], before: "<image:", after: "")
            let width = SAReplace(arrTypeStr[1], before: "w:", after: "")
            var height = SAReplace(arrTypeStr[2], before: "h:", after: "")
            height = SAReplace(height as String, before: ">", after: "")
            count++
            dataArray.addObject(["type": "image", "count": "\(count)", "url": url, "width": width, "height": height])
        }
    }
    if (location < (content as NSString).length) {
        let subStr = (content as NSString).substringWithRange(NSMakeRange(location, length - location))
        count++
        dataArray.addObject(["type": "text", "content": subStr, "count": "\(count)"])
    }
    return dataArray
}