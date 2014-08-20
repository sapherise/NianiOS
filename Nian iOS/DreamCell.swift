//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class DreamCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var holder:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var imageholder:UIImageView?
    @IBOutlet var View:UIView?
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews()
    {
        
        
        super.layoutSubviews()
        var uid = self.data.stringAttributeForKey("uid")
        var user = self.data.stringAttributeForKey("user")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        var content = self.data.stringAttributeForKey("content")
        var img = self.data.stringAttributeForKey("img") as NSString
        var img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (self.data.stringAttributeForKey("img1") as NSString).floatValue
        
        self.nickLabel!.text = user
        self.lastdate!.text = lastdate
        self.View!.backgroundColor = BGColor
        
        var userImageURL = "http://img.nian.so/head/\(uid).jpg!head"
        self.avatarView!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        
        var height = content.stringHeightWith(17,width:280)
        
        
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        self.holder!.layer.cornerRadius = 4;
        self.holder!.layer.masksToBounds = true;
        
        if img0 == 0.0 {
            self.imageholder!.hidden = true
            self.holder!.setHeight(height+86+15)
        }else{
            var imgHeight = img1 * 250 / img0
            var ImageURL = "http://img.nian.so/step/\(img)!iosfo" as NSString
            self.imageholder!.setImage(ImageURL,placeHolder: UIImage(named: "1.jpg"))
            self.imageholder!.setHeight(CGFloat(imgHeight))
            var sapherise = self.imageholder!.frame.size.height
            self.imageholder!.hidden = false
            self.holder!.setHeight(height+86+30+sapherise)
        }
        
        self.imageholder!.setY(self.contentLabel!.bottom()+10)
    }
    
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        var content = data.stringAttributeForKey("content")
        var img0 = (data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("img1") as NSString).floatValue
        var height = content.stringHeightWith(17,width:280)
        if(img0 == 0.0){
            return 59.0 + height + 40.0 + 15.0
        }else{
            return 59.0 + height + 40.0 + 30.0 + CGFloat(img1*250/img0)
        }
    }
    
}
