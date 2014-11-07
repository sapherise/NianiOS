//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCellTop: UITableViewCell, UIGestureRecognizerDelegate{

    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var dreamhead:UIImageView?
    @IBOutlet var View:UIView?
    @IBOutlet var labelDes:UILabel!
    @IBOutlet var viewLine:UIView!
    @IBOutlet var btnMain:UIButton!
    @IBOutlet var viewRight:UIView!
    @IBOutlet var viewLeft:UIView!
    @IBOutlet var dotLeft:UIView!
    @IBOutlet var dotRight:UIView!
    @IBOutlet var menuLeft:UIButton!
    @IBOutlet var menuMiddle:UIButton!
    @IBOutlet var menuRight:UIButton!
    @IBOutlet var menuSlider:UIView!
    var dreamid:String = ""
    var desHeight:CGFloat = 0
    var panStartPoint:CGPoint!
    var toggle:Int = 0
    var panGesture:UIGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        self.panGesture.delegate = self
        self.View?.addGestureRecognizer(self.panGesture)
        
        self.menuMiddle.setTitleColor(SeaColor, forState: UIControlState.Normal)
        self.menuMiddle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        self.menuMiddle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let panGesture = gestureRecognizer as UIPanGestureRecognizer
        let panY = panGesture.locationInView(self).y
        if panY > 242 {
            return false
        }
        let translation = panGesture.translationInView(self)
        return fabs(translation.y) < fabs(translation.x)
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
                self.viewLeft.frame.origin.x = distanceX
                self.viewRight.frame.origin.x = distanceX + 320
            }else{
                self.viewLeft.frame.origin.x = distanceX - 320
                self.viewRight.frame.origin.x = distanceX
            }
        }
        if pan.state == UIGestureRecognizerState.Ended {
            if panStartPoint.x > point.x {
                self.toggle = 1
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = -320
                    self.viewRight.frame.origin.x = 0
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
                    self.viewLeft.frame.origin.x = 0
                    self.viewRight.frame.origin.x = 320
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
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
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
            var des = sa.objectForKey("content") as String
            if des == "" {
                des = "暂无简介"
            }
            
            self.labelDes.text = des
            self.desHeight = des.stringHeightWith(12,width:200)
            self.labelDes.setHeight(self.desHeight)
            self.labelDes.setY( 90 - self.desHeight / 2 )
            self.viewLeft.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
            self.viewRight.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
            self.menuSlider.backgroundColor = SeaColor
            if isPrivate == "1" {
                var string = NSMutableAttributedString(string: "\(title)（私密）")
                var len = string.length
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, len-4))
                string.addAttribute(NSForegroundColorAttributeName, value: BlueColor, range: NSMakeRange(len-4, 4))
                self.nickLabel!.attributedText = string
            }else if percent == "1" {
                var string = NSMutableAttributedString(string: "\(title)（已完成）")
                var len = string.length
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, len-5))
                string.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(len-5, 5))
                self.nickLabel!.attributedText = string
            }else{
                self.nickLabel!.text = "\(title)"
            }
            var userImageURL = "http://img.nian.so/dream/\(img)!dream"
            self.dreamhead!.setImage(userImageURL,placeHolder: IconColor)
            self.selectionStyle = UITableViewCellSelectionStyle.None
        })
    }
}
