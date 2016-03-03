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
    @IBOutlet var imageContent: FLAnimatedImageView!
    var data: NSDictionary!
    
    func setup() {
        
        print(data)
        selectionStyle = .None
        labelName.textColor = UIColor.HighlightColor()
        imageHead.layer.masksToBounds = true
        imageHead.layer.cornerRadius = 16
        let uid = data.stringAttributeForKey("uid")
        let name = data.stringAttributeForKey("user")
        let time = data.stringAttributeForKey("lastdate")
        let content = data.stringAttributeForKey("content")
        let type = data.stringAttributeForKey("type")
        let heightContent = data.objectForKey("heightContent") as! CGFloat
        let widthContent = data.objectForKey("widthContent") as! CGFloat
        let wImage = data.objectForKey("widthImage") as! CGFloat
        let hImage = data.objectForKey("heightImage") as! CGFloat
        let heightCell = data.objectForKey("heightCell") as! CGFloat
        
        imageHead.setHead(uid)
        labelContent.frame.size = CGSizeMake(widthContent, heightContent)
        labelContent.text = content
        imageContent.frame.size = CGSizeMake(wImage, hImage)
        imageHead.setY(heightCell - 32 - 4)
        labelName.setY(heightCell - 22)
        
        imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHead"))
        
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
        
        if type == "1" {
            labelContent.hidden = true
            let arr = content.componentsSeparatedByString("-")
            if arr.count == 2 {
                let code = arr[0]
                let num = arr[1]
                let url = "http://img.nian.so/emoji/\(code)/\(num).gif"
                imageContent.qs_setGifImageWithURL(NSURL(string: url)!, progress: nil, completed: nil)
                imageContent.frame.size = CGSizeMake(100, 100)
            }
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







