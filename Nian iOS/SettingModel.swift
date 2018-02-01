//
//  SettingModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/2/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class SettingModel: NSObject {
    
    var dailyMode: String = "0"
    var picOnCellar: String = "0"
    var saveCard: String = "1"
    var dailyRemind: String = "0"
    var findViaName: String = "0"
    
    var editProfileDictionary: Dictionary<String, String> = Dictionary()
    var accountBindDictionary: Dictionary<String, String> = Dictionary()
    
    override init() {
        super.init()
        
    }
}



















