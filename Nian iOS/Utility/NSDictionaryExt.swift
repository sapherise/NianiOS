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
    func stringAttributeForKey(_ key:String)->String {
        if let value = self.object(forKey: key) {
            return "\(value)"
        }
        return ""
    }
}
