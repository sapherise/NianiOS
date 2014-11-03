//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class BBSCellTop: UITableViewCell{
    
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var dreamhead:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var Line:UIView?
    @IBOutlet var BBStitle:UILabel?
    
    var Id:String = ""
    var topcontent:String = ""
    var topuid:String = ""
    var toplastdate:String = ""
    var topuser:String = ""
    var toptitle:String = ""
    var getContent:String = "0" //为0时是传值，1时是自力更生去拉取数据
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.View!.backgroundColor = BGColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.Line!.backgroundColor = LittleLineColor
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        if getContent == "1" {
            var url = NSURL(string:"http://nian.so/api/bbstop.php?id=\(self.Id)")
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var sa: AnyObject! = json.objectForKey("bbstop")
            self.toptitle = sa.objectForKey("title") as String
            self.topcontent = sa.objectForKey("content") as String
            self.topuid = sa.objectForKey("uid") as String
            self.toplastdate = sa.objectForKey("lastdate") as String
            self.topuser = sa.objectForKey("user") as String
        }
        
        self.BBStitle!.text = "\(self.toptitle)"
        var titleHeight = self.toptitle.stringHeightWith(17,width:280)
        self.BBStitle!.setHeight(titleHeight)
        
        self.nickLabel!.text = "\(self.topuser)"
        self.lastdate!.text = "\(self.toplastdate)"
        var userImageURL = "http://img.nian.so/head/\(self.topuid).jpg!head"
        self.dreamhead!.setImage(userImageURL,placeHolder: IconColor)
        self.dreamhead!.tag = self.topuid.toInt()!
        
        self.contentLabel?.text = "\(topcontent)"
        
        var height = topcontent.stringHeightWith(17,width:225)
        self.contentLabel!.setHeight(height)
        
        self.dreamhead!.setY(self.BBStitle!.bottom()+20)
        self.nickLabel!.setY(self.BBStitle!.bottom()+20)
        self.lastdate!.setY(self.BBStitle!.bottom()+39)
        self.contentLabel!.setY(self.BBStitle!.bottom()+68)
        
        self.Line!.setY(self.contentLabel!.bottom()+16)
    }
    class func cellHeightByData(topcontent:String, toptitle:String)->CGFloat{
        var height = topcontent.stringHeightWith(17,width:225)
        var titleHeight = toptitle.stringHeightWith(17,width:280)
        return height + 105 + titleHeight
    }
    
}
