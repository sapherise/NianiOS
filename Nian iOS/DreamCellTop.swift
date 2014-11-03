//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCellTop: UITableViewCell{

    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var dreamhead:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var Seg: UISegmentedControl?
    var segSelected:String = ""
    var dreamid:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.Seg!.tintColor = LineColor
        var Sa = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_main_queue(), {
            var url = NSURL(string:"http://nian.so/api/dream.php?id=\(self.dreamid)&uid=\(safeuid)&shell=\(safeshell)")
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var sa: AnyObject! = json.objectForKey("dream")
            var title: AnyObject! = sa.objectForKey("title")
            var img: AnyObject! = sa.objectForKey("img")
            var percent: String! = sa.objectForKey("percent") as String
            var isPrivate: String! = sa.objectForKey("private") as String
            
            
            if isPrivate == "1" {
                var string = NSMutableAttributedString(string: "\(title)（私密）")
                var len = string.length
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, len-4))
                string.addAttribute(NSForegroundColorAttributeName, value: BlueColor, range: NSMakeRange(len-4, 4))
                self.nickLabel!.attributedText = string
            }else if percent == "1" {
                var string = NSMutableAttributedString(string: "\(title)（已完成）")
                var len = string.length
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, len-5))
                string.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(len-5, 5))
                self.nickLabel!.attributedText = string
            }else{
                self.nickLabel!.text = "\(title)"
            }
            var userImageURL = "http://img.nian.so/dream/\(img)!dream"
            self.dreamhead!.setImage(userImageURL,placeHolder: IconColor)
            self.View!.backgroundColor = BGColor
            self.selectionStyle = UITableViewCellSelectionStyle.None
        })
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
    
}
