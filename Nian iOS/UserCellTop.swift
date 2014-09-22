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
    @IBOutlet var foNumber: UILabel?
    @IBOutlet var foedNumber: UILabel?
    var segSelected:String = ""
    var userid:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.Seg!.tintColor = LineColor
        dispatch_async(dispatch_get_main_queue(), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var url = NSURL(string:"http://nian.so/api/user.php?uid=\(self.userid)&myuid=\(safeuid)")
            var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var sa: AnyObject! = json.objectForKey("user")
            var name: AnyObject! = sa.objectForKey("name")
            var fo: NSString! = sa.objectForKey("fo") as NSString
            var foed: NSString! = sa.objectForKey("foed") as NSString
            var isfo: NSString! = sa.objectForKey("isfo") as NSString
            self.nickLabel!.text = "\(name)"
            var userImageURL = "http://img.nian.so/head/\(self.userid).jpg!head"
            self.foNumber!.text = "\(fo) 关注"
            self.foedNumber!.text = "\(foed) 听众"
            self.dreamhead!.setImage(userImageURL,placeHolder: IconColor)
            self.View!.backgroundColor = BGColor
            self.selectionStyle = UITableViewCellSelectionStyle.None
            if isfo == "0" {
                if self.userid != safeuid {
                NSNotificationCenter.defaultCenter().postNotificationName("userIsFo", object:"0")
                }
            }else if isfo == "1" {
                NSNotificationCenter.defaultCenter().postNotificationName("userIsFo", object:"1")
            }
        })
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
