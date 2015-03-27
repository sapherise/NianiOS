//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class PlayerCellTop: UIView, UIGestureRecognizerDelegate{
    
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var BGImage:UIImageView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var btnLetter: UIButton!
    @IBOutlet var UserFo: UILabel!
    @IBOutlet var UserFoed: UILabel!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var labelMenuLeft: UILabel!
    @IBOutlet var labelMenuRight: UILabel!
    @IBOutlet var labelMenuSlider: UIView!
    @IBOutlet var viewBlack: UIView!
    @IBOutlet var viewBanner: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.BGImage.clipsToBounds = true
        self.viewHolder.frame.size = CGSizeMake(globalWidth, globalHeight + 44)
        self.viewBanner.setY(320)
        self.viewBanner.setWidth(globalWidth)
        self.viewMenu.frame.origin = CGPointMake(globalWidth/2 - 160, 0)
        self.BGImage.frame.size = CGSizeMake(globalWidth, 320)
        self.UserHead.setX(globalWidth/2-30)
        self.viewBlack.frame.size = CGSizeMake(globalWidth, 320)
        self.btnMain.setX(globalWidth/2 - 105)
        self.btnLetter.setX(globalWidth/2 + 5)
        self.UserFo.setX(globalWidth/2 - 53)
        self.UserFoed.setX(globalWidth/2 + 1)
        self.layer.masksToBounds = true
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var viewHit = super.hitTest(point, withEvent: event)
        if let v = NSStringFromClass(viewHit?.classForCoder) {
            if v == "UIView" {
                return nil
            }
        }
        return viewHit
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
