//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


class CommentCell: UITableViewCell {
    
    @IBOutlet var imageHead:UIImageView!
    @IBOutlet var labelName:UILabel!
    @IBOutlet var labelContent:UILabel!
    @IBOutlet var imageContent:UIImageView!
    var data: NSDictionary!
    
    func setup() {
        selectionStyle = .None
        labelName.textColor = UIColor.HighlightColor()
        imageHead.layer.masksToBounds = true
        imageHead.layer.cornerRadius = 16
        let uid = data.stringAttributeForKey("uid")
        let name = data.stringAttributeForKey("user")
        let time = data.stringAttributeForKey("lastdate")
        let content = data.stringAttributeForKey("content")
        let heightContent = data.objectForKey("heightContent") as! CGFloat
        let widthContent = data.objectForKey("widthContent") as! CGFloat
        let wImage = data.objectForKey("widthImage") as! CGFloat
        let hImage = data.objectForKey("heightImage") as! CGFloat
        let heightCell = data.objectForKey("heightCell") as! CGFloat
        
        imageHead.setHead(uid)
        imageHead.tag = Int(uid)!
        labelContent.frame.size = CGSizeMake(widthContent, heightContent)
        labelContent.text = content
        imageContent.frame.size = CGSizeMake(wImage, hImage)
        imageHead.setY(heightCell - 32 - 4)
        labelName.setY(heightCell - 22)
        
        if uid == SAUid() {
            imageHead.setX(globalWidth - 32 - 16)
            labelName.setX(globalWidth - 64 - 231)
            labelName.text = time
            labelName.textColor = UIColor.secAuxiliaryColor()
            labelName.textAlignment = NSTextAlignment.Right
            imageContent.image = UIImage(named: "bubble_me")
            imageContent.setX(globalWidth - imageContent.width() - 60)
            labelContent.setX(globalWidth - labelContent.width() - 73)
            labelContent.textColor = UIColor.MainColor()
        } else {
            let attrStr = NSMutableAttributedString(string: "\(name)  \(time)")
            attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.HighlightColor(), range: NSMakeRange(0, (name as NSString).length))
            attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.secAuxiliaryColor(), range: NSMakeRange((name as NSString).length + 2, (time as NSString).length))
            labelName.attributedText = attrStr
            labelName.textAlignment = NSTextAlignment.Left
            labelContent.textColor = UIColor.BackgroundColor()
        }
    }
}

extension String {
    func toCGFloat() -> CGFloat {
        let f = CGFloat((self as NSString).floatValue)
        if f != 0 {
            return f
        }
        return 0
    }
}







