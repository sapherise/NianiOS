//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation
extension NSDictionary {
    func stringAttributeForKey(key:String)->String {
        if let obj: AnyObject = self[key] {
            if obj.isKindOfClass(NSNumber) {
                let num = obj as! NSNumber
                return num.stringValue
            }
            return "\(obj)"
        }
        return ""
    }
}
