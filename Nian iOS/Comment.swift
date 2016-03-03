//
//  Comment.swift
//  Nian iOS
//
//  Created by Sa on 16/3/3.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Comment: UITableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var imageContent: UIImageView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var labelName: UILabel!
    let wImage: CGFloat = 32
    var data: NSDictionary!
    
    func setup() {
        let uid = data.stringAttributeForKey("uid")
        let name = data.stringAttributeForKey("user")
        let lastdate = data.stringAttributeForKey("lastdate")
        let content = data.stringAttributeForKey("content")
        labelName.text = "\(name) \(lastdate)"
        labelContent.text = content
        imageHead.setHead(uid)
        
        
        
//        let uid = self.data.stringAttributeForKey("uid")
//        let user = self.data.stringAttributeForKey("user")
//        let lastdate = self.data.stringAttributeForKey("lastdate")
//        let content = self.data.stringAttributeForKey("content")
        let hContent = data.objectForKey("heightContent") as! CGFloat
        let wContent = data.objectForKey("widthContent") as! CGFloat
        let wImage = data.objectForKey("widthImage") as! CGFloat
        let hImage = data.objectForKey("heightImage") as! CGFloat
        let h = data.objectForKey("heightCell") as! CGFloat
        
        labelContent.frame.size = CGSizeMake(wContent, hContent)
        imageContent.frame.size = CGSizeMake(wImage, hImage)
//        imageHead.setBottom(height + 55)
        imageHead.setY(h - imageHead.height())
        labelName.setY(h - labelName.height())
        print(h, imageHead.height())
        print(imageHead)
        
//
        
//        self.avatarView.setBottom(height + 55)
//        self.nickLabel.setBottom(height + 60)
//        self.nickLabel.setWidth(user.stringWidthWith(11, height: 21))
//        self.lastdate.setWidth(lastdate.stringWidthWith(11, height: 21))
//        self.lastdate.setBottom(height + 60)
//        
//        self.lastdate.setX(user.stringWidthWith(11, height: 21)+83)
//        self.contentLabel.setX(80)
    }
}
