//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class UserCellTop: UITableViewCell{
    
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var dreamhead:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var Seg: UISegmentedControl?
    var segSelected:String = ""
    var userid:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        var url = NSURL(string:"http://nian.so/api/user.php?uid=\(userid)")
        var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var sa: AnyObject! = json.objectForKey("user")
        var name: AnyObject! = sa.objectForKey("name")
        
        self.nickLabel!.text = "\(name)"
        var userImageURL = "http://img.nian.so/head/\(userid).jpg!head"
        self.dreamhead!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        self.View!.backgroundColor = BGColor
        self.Seg!.tintColor = LineColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
}
