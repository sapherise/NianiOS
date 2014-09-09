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
    
    var topcontent:String = ""
    var topuid:String = ""
    var toplastdate:String = ""
    var topuser:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.nickLabel!.text = "\(topuser)"
        self.lastdate!.text = "\(toplastdate)"
        var userImageURL = "http://img.nian.so/head/\(topuid).jpg!head"
        self.dreamhead!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        self.View!.backgroundColor = BGColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentLabel?.text = "\(topcontent)"
        
        var height = topcontent.stringHeightWith(17,width:225)
        self.contentLabel!.setHeight(height)
        
        self.Line!.backgroundColor = LittleLineColor
        self.Line!.setY(self.contentLabel!.bottom()+16)
    }
    class func cellHeightByData(topcontent:String)->CGFloat
    {
        var height = topcontent.stringHeightWith(17,width:225)
        return height + 80
    }
    
}
