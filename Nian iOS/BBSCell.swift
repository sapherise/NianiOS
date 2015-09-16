//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class BBSCell: UITableViewCell {
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    @IBOutlet var Line:UIView?
    var data :NSDictionary!
    var content:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.contentLabel?.setWidth(globalWidth-85)
        self.Line?.setWidth(globalWidth - 40)
        self.Line?.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let uid = self.data.stringAttributeForKey("uid")
            let user = self.data.stringAttributeForKey("user")
            let lastdate = self.data.stringAttributeForKey("lastdate")
            content = SADecode(SADecode(self.data.stringAttributeForKey("content")))
            self.nickLabel!.text = user
            self.lastdate!.text = V.relativeTime(lastdate)
            self.avatarView!.setHead(uid)
            self.avatarView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser"))
            let height = content.stringHeightWith(16,width:globalWidth-85)
            self.contentLabel!.setHeight(height)
            self.contentLabel!.text = content
            self.Line!.setY(self.contentLabel!.bottom()+25)
            Line?.setHeightHalf()
        }
    }
    
    func toUser() {
        let vc = PlayerViewController()
        vc.Id = data.stringAttributeForKey("uid")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        let content = SADecode(SADecode(data.stringAttributeForKey("content")))
        let height = content.stringHeightWith(16,width:globalWidth-85)
        return height + 77 + 26
    }
}
