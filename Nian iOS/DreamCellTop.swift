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
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        var Sa = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = NSURL(string:"http://nian.so/api/dream.php?id=\(dreamid)&uid=\(safeuid)&shell=\(safeshell)")
        var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var sa: AnyObject! = json.objectForKey("dream")
        var title: AnyObject! = sa.objectForKey("title")
        var img: AnyObject! = sa.objectForKey("img")
        
        self.nickLabel!.text = "\(title)"
        var userImageURL = "http://img.nian.so/dream/\(img)!head"
        self.dreamhead!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        self.View!.backgroundColor = BGColor
        self.Seg!.tintColor = LineColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
}
