//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class BBSCellTop: UITableViewCell{
    
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var dreamhead:UIImageView!
    @IBOutlet var View:UIView!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var lastdate:UILabel!
    @IBOutlet var Line:UIView!
    @IBOutlet var BBStitle:UILabel!
    @IBOutlet var viewFlow: UILabel!
    var Id:String = ""
    var data: NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.BBStitle?.setWidth(globalWidth-40)
        self.setWidth(globalWidth)
        self.contentLabel?.setWidth(globalWidth-85)
        self.Line?.setWidth(globalWidth - 40)
        self.Line?.setHeight(0.5)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        let title = SADecode(SADecode(data.stringAttributeForKey("title")))
        let user = data.stringAttributeForKey("user")
        let uid = data.stringAttributeForKey("uid")
        let lastdate = data.stringAttributeForKey("postdate")
        let content = SADecode(SADecode(data.stringAttributeForKey("content")))
        self.BBStitle.text = title
        let titleHeight = title.stringHeightWith(16,width:globalWidth-40)
        self.BBStitle!.setHeight(titleHeight)
        
        self.nickLabel.text = user
        self.lastdate.text = V.relativeTime(lastdate)
        self.dreamhead.setHead(uid)
        self.contentLabel.text = content
        
        let height = content.stringHeightWith(16,width:globalWidth-85)
        self.contentLabel.setHeight(height)
        
        self.dreamhead!.setY(self.BBStitle!.bottom()+20)
        self.nickLabel!.setY(self.BBStitle!.bottom()+20)
        self.lastdate!.setY(self.nickLabel!.bottom()+6)
        self.contentLabel!.setY(self.dreamhead!.bottom()+20)
        self.viewFlow.setY(self.contentLabel!.bottom()+20)
        self.Line!.setY(self.viewFlow!.bottom()+25)
        if uid == "" {
            View.hidden = true
        } else {
            View.hidden = false
        }
        Line.setHeightHalf()
    }
    
    class func cellHeightByData(data: NSDictionary)->CGFloat{
        let title = SADecode(SADecode(data.stringAttributeForKey("title")))
        let content = SADecode(SADecode(data.stringAttributeForKey("content")))
        let titleHeight = title.stringHeightWith(16,width:globalWidth-40)
        let height = content.stringHeightWith(16,width:globalWidth-85)
        return height + 178 + titleHeight
    }
}
