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
    @IBOutlet var viewFlow: UILabel!
    
    var Id:String = ""
    var topcontent:String = ""
    var topuid:String = ""
    var toplastdate:String = ""
    var topuser:String = ""
    var toptitle:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.BBStitle?.setWidth(globalWidth-40)
        self.setWidth(globalWidth)
        self.contentLabel?.setWidth(globalWidth-85)
        self.Line?.setWidth(globalWidth)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        self.BBStitle!.text = "\(self.toptitle)"
        var titleHeight = self.toptitle.stringHeightWith(16,width:globalWidth-40)
        self.BBStitle!.setHeight(titleHeight)
        
        self.nickLabel!.text = "\(self.topuser)"
        self.lastdate!.text = "\(self.toplastdate)"
        self.dreamhead?.setHead(self.topuid)
        if let tag = self.topuid.toInt() {
            self.dreamhead!.tag = tag
        }
        self.contentLabel?.text = "\(topcontent)"
        
        var height = topcontent.stringHeightWith(16,width:globalWidth-85)
        self.contentLabel!.setHeight(height)
        
        self.dreamhead!.setY(self.BBStitle!.bottom()+20)
        self.nickLabel!.setY(self.BBStitle!.bottom()+20)
        self.lastdate!.setY(self.BBStitle!.bottom()+39)
        self.contentLabel!.setY(self.BBStitle!.bottom()+68)
        self.viewFlow.setY(self.contentLabel!.bottom()+26)
        self.Line!.setY(self.viewFlow!.bottom()+18)
        if self.topuid == "" {
            self.View?.hidden = true
        }else{
            self.View?.hidden = false
        }
    }
    class func cellHeightByData(topcontent:String, toptitle:String)->CGFloat{
        var height = topcontent.stringHeightWith(16,width:globalWidth-85)
        var titleHeight = toptitle.stringHeightWith(16,width:globalWidth-40)
        return height + 120 + titleHeight + 58
    }
    
}
