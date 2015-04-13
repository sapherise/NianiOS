//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleDetailTop: UITableViewCell, UIGestureRecognizerDelegate{
    
    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var dreamhead:UIImageView!
    @IBOutlet var View:UIView!
    @IBOutlet var labelDes:UILabel!
    @IBOutlet var btnMain:UIButton!
    @IBOutlet var viewRight:UIView!
    @IBOutlet var viewLeft:UIView!
    @IBOutlet var dotLeft:UIView!
    @IBOutlet var dotRight:UIView!
    
    @IBOutlet var numLeft:UIView!
    @IBOutlet var numMiddle:UIView!
    @IBOutlet var numLeftNum:UILabel!
    @IBOutlet var numMiddleNum:UILabel!
    @IBOutlet var viewLineLeft: UIView!
    
    @IBOutlet var labelTag: UILabel!
    @IBOutlet var labelPrivate: UILabel!
    @IBOutlet var viewBG: UIView!
    @IBOutlet var line1: UIView!
    @IBOutlet var line2: UIView!
    @IBOutlet var line3: UIView!
    @IBOutlet var switchNotice: UISwitch!
    @IBOutlet var viewSettings: UIView!
    @IBOutlet var viewNotice: UIView!
    @IBOutlet var labelMember: UILabel!
    
    var dreamid:String = ""
    var desHeight:CGFloat = 0
    var panStartPoint:CGPoint!
    var toggle:Int = 0
    var panGesture:UIGestureRecognizer!
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setWidth(globalWidth)
        self.viewSettings.setWidth(globalWidth)
        self.viewNotice.setWidth(globalWidth)
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        self.panGesture.delegate = self
        self.View?.addGestureRecognizer(self.panGesture)
        self.btnMain.backgroundColor = SeaColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.dreamhead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamHeadClick:"))
        self.viewBG.setWidth(globalWidth)
        self.viewRight.setX(globalWidth + globalWidth/2 - 160)
        self.viewLeft.setX(globalWidth/2 - 160)
        self.btnMain.setX(globalWidth/2-50)
        self.dotLeft.setX(globalWidth/2-5)
        self.dotRight.setX(globalWidth/2+5)
        self.line1.setWidth(globalWidth-30)
        self.line2.setWidth(globalWidth-30)
        self.line3.setWidth(globalWidth-30)
        self.labelTag.setX(globalWidth-210)
        self.labelPrivate.setX(globalWidth-210)
        self.switchNotice.layer.cornerRadius = 16
        self.switchNotice.thumbTintColor = UIColor.whiteColor()
        self.switchNotice.onTintColor = SeaColor
        self.switchNotice.tintColor = SeaColor
        self.switchNotice.setGlobalX(x: 15)
        self.viewNotice.hidden = true
        self.labelMember.setY(212 - 48)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }else{
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let panY = panGesture.locationInView(self).y
            let translation = panGesture.translationInView(self)
            if panY > 287 {
                return false
            }else if fabs(translation.y) > fabs(translation.x) {  //如果是往下划
                return false
            }else{
                return true
            }
        }
    }
    
    func pan(pan:UIPanGestureRecognizer){
        var point = pan.locationInView(self.View)
        if pan.state == UIGestureRecognizerState.Began {
            panStartPoint = point
        }
        if pan.state == UIGestureRecognizerState.Changed {
            var distanceX = pan.translationInView(self.View!).x
            self.View!.layer.removeAllAnimations()
            if self.toggle == 0 {
                var ratio:CGFloat = (distanceX > 0) ? 0.5 : 1
                self.viewLeft.frame.origin.x = distanceX * ratio + globalWidth/2 - 160
                self.viewRight.frame.origin.x = distanceX * ratio + globalWidth + globalWidth/2 - 160
            }else{
                var ratio:CGFloat = (distanceX > 0) ? 1 : 0.5
                self.viewLeft.frame.origin.x = distanceX * ratio - globalWidth + globalWidth/2 - 160
                self.viewRight.frame.origin.x = distanceX * ratio + globalWidth/2 - 160
            }
        }
        if pan.state == UIGestureRecognizerState.Ended {
            if panStartPoint.x > point.x {
                self.toggle = 1
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = -globalWidth + globalWidth/2 - 160
                    self.viewRight.frame.origin.x = globalWidth/2 - 160
                    self.dotLeft.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
                    self.dotRight.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
                    }, completion: { (finished:Bool) -> Void in
                        if !finished {
                            return
                        }
                })
            }else{
                self.toggle = 0
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = globalWidth/2 - 160
                    self.viewRight.frame.origin.x = globalWidth + globalWidth/2 - 160
                    self.dotLeft.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
                    self.dotRight.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
                    }, completion: { (finished:Bool) -> Void in
                        if !finished {
                            return
                        }
                })
            }
        }
    }
}
