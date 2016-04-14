//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import Foundation
import UIKit

class Comment: UITableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var labelHolder: UIView!
    @IBOutlet var imageBubble: UIImageView!
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
        labelContent.frame.size = CGSizeMake(widthContent, heightContent)
        labelContent.text = content
        labelHolder.frame.size = CGSizeMake(wImage, hImage)
        imageHead.setY(heightCell - 32 - 4)
        labelName.setY(heightCell - 22)
        let x: CGFloat = 2
        imageBubble.setBottom(labelHolder.bottom() + x)
        
        imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Comment.onHead)))
        
        
        if uid == SAUid() {
            imageHead.setX(globalWidth - 32 - 16)
            labelName.setX(globalWidth - 64 - 231)
            labelName.text = time
            labelName.textColor = UIColor.secAuxiliaryColor()
            labelName.textAlignment = NSTextAlignment.Right
//            imageContent.image = UIImage(named: "bubble_me")
            labelHolder.setX(globalWidth - labelHolder.width() - 60)
            labelContent.setX(globalWidth - labelContent.width() - 73)
            labelContent.textColor = UIColor.MainColor()
            labelHolder.backgroundColor = UIColor.GreyBackgroundColor()
            imageBubble.setX(globalWidth - imageBubble.width() - 60 + x)
            imageBubble.image = UIImage(named: "bubble_me")
        } else {
            let attrStr = NSMutableAttributedString(string: "\(name)  \(time)")
            attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.HighlightColor(), range: NSMakeRange(0, (name as NSString).length))
            attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.secAuxiliaryColor(), range: NSMakeRange((name as NSString).length + 2, (time as NSString).length))
            labelName.attributedText = attrStr
            labelName.textAlignment = NSTextAlignment.Left
            labelContent.textColor = UIColor.BackgroundColor()
            labelHolder.setX(60)
            labelContent.setX(73)
            labelName.setX(64)
//            imageContent.image = UIImage(named: "bubble")
            imageHead.setX(16)
            labelHolder.backgroundColor = UIColor.HighlightColor()
            imageBubble.setX(60)
            imageBubble.image = UIImage(named: "bubble")
        }
        
        if data.stringAttributeForKey("type") == "2" {
            labelHolder.backgroundColor = UIColor(red: 0xff/255.0, green: 0xe2/255.0, blue: 0x7e/255.0, alpha: 1)
            imageBubble.hidden = true
        } else {
            imageBubble.hidden = false
        }
    }
    
    func onHead(){
        let vc = PlayerViewController()
        vc.Id = data.stringAttributeForKey("uid")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
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







