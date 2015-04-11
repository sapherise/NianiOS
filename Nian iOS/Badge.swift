//
//  Badge.swift
//  Nian iOS
//
//  Created by Sa on 15/4/8.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import UIKit

class SABadgeView: UIImageView{
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).CGColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 7
        self.contentMode = UIViewContentMode.Center
        self.hidden = true
    }
    
    func setType(type: String) {
        switch type {
        case "1":
            self.image = UIImage(named: "user_star")
            self.backgroundColor = UIColor(red:0.96, green:0.84, blue:0.36, alpha:1)
            self.hidden = false
            break
        case "2":
            self.image = UIImage(named: "user_lightning")
            self.backgroundColor = UIColor(red:0.96, green:0.84, blue:0.36, alpha:1)
            self.hidden = false
            break
        case "3":
            self.image = UIImage(named: "user_water")
            self.backgroundColor = UIColor(red:0.36, green:0.73, blue:0.94, alpha:1)
            self.hidden = false
            break
        default:
            break
        }
    }
}
