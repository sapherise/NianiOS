//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCellTop: UITableViewCell, UIGestureRecognizerDelegate{

    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var dreamhead:UIImageView!
    @IBOutlet var View:UIView!
    @IBOutlet var labelDes:UILabel!
    @IBOutlet var btnMain:UIButton!
    @IBOutlet var viewRight:UIView!
    @IBOutlet var viewLeft:UIView!
    @IBOutlet var dotLeft:UIView!
    @IBOutlet var dotRight:UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var numLeft:UIView!
    @IBOutlet var numMiddle:UIView!
    @IBOutlet var numLeftNum:UILabel!
    @IBOutlet var numMiddleNum:UILabel!
    
    @IBOutlet var viewLineLeft: UIView!
    @IBOutlet var viewBG: UIView!
    @IBOutlet var viewHolder: UIView!
    var data: NSDictionary?
    var panStartPoint:CGPoint!
    var toggle:Int = 0
    var panGesture:UIGestureRecognizer!
    var tagArray: Array<String> = []  // 加 tag
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        self.panGesture.delegate = self
        self.View?.addGestureRecognizer(self.panGesture)
        self.btnMain.backgroundColor = SeaColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.viewLeft.setX(globalWidth/2-160)
        self.viewRight.setX(globalWidth/2-160+globalWidth)
        self.viewBG.setWidth(globalWidth)
        self.btnMain.setX(globalWidth/2-50)
        self.dotLeft.setX(globalWidth/2-5)
        self.dotRight.setX(globalWidth/2+5)
        self.scrollView.setWidth(globalWidth)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
    }
    
    func moveUp() {
        var bottom = self.nickLabel.bottom()
        
        self.viewRight.setY(0)
        self.viewBG.setY(0)
        self.btnMain.setY(bottom + 84)
        self.dotLeft.setY(bottom + 137)
        self.dotRight.setY(bottom + 137)
    }

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }else{
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let panY = panGesture.locationInView(self).y
            let translation = panGesture.translationInView(self)
            if fabs(translation.y) > fabs(translation.x) {  //如果是往下划
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
    
    override func layoutSubviews(){
        super.layoutSubviews()
        if data != nil {
            var title = SADecode(SADecode(data!.stringAttributeForKey("title")))
            var content = SADecode(SADecode(data!.stringAttributeForKey("content")))
            var img = data!.stringAttributeForKey("image")
            var step = data!.stringAttributeForKey("step")
            var likeDream = data!.stringAttributeForKey("like")
            var likeStep = data!.stringAttributeForKey("like_step")
            var like = likeDream.toInt()! + likeStep.toInt()!
            var thePrivate = data!.stringAttributeForKey("private")
            var percent = data!.stringAttributeForKey("percent")
            var isFollow = data!.stringAttributeForKey("follow")
            var uid = data!.stringAttributeForKey("uid")
            dreamhead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
            dreamhead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
            var h: CGFloat = title.stringHeightBoldWith(19, width: 242)
            if thePrivate == "1" {
                title = "\(title)（私密）"
                var textTitle = NSMutableAttributedString(string: title)
                var l = textTitle.length
                textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSForegroundColorAttributeName, value: SeaColor, range: NSMakeRange(l-4, 4))
                nickLabel.attributedText = textTitle
                h = title.stringHeightBoldWith(19, width: 242)
            } else if percent == "1" {
                title = "\(title)（完成）"
                var textTitle = NSMutableAttributedString(string: title)
                var l = textTitle.length
                textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(l-4, 4))
                nickLabel.attributedText = textTitle
                h = title.stringHeightBoldWith(19, width: 242)
            } else {
                nickLabel.text = title
            }
            if content == "" {
                content = "暂无简介"
            }
            var bottom = nickLabel.bottom()
            viewHolder.setY(bottom + 13)
            var heightContent = content.stringHeightWith(12, width: 200)
            labelDes.text = content
            labelDes.setHeight(heightContent)
            labelDes.setY(110 - heightContent / 2)
            viewRight.setY(44)
            viewBG.setY(44)
            btnMain.setY(bottom + 128)
            dotLeft.setY(bottom + 181)
            dotRight.setY(bottom + 181)
            viewBG.setHeight(h + 256)
            viewLeft.setHeight(h + 256)
            viewRight.setHeight(h + 256)
            numLeftNum.text = "\(like)"
            numMiddleNum.text = step
            numLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLike"))
            //==
            if SAUid() != uid {
                if isFollow == "0" {
                    btnMain.setTitle("关注", forState: UIControlState.allZeros)
                    btnMain.addTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
                } else {
                    btnMain.setTitle("关注中", forState: UIControlState.allZeros)
                    btnMain.addTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
            self.contentView.hidden = false
            
            tagArray = data!.objectForKey("tags") as! Array
            
            scrollView.contentSize =  CGSizeMake(8, 0)
            var views: NSArray = scrollView.subviews
            for view: AnyObject in views {
                if view is NILabel {
                    (view as! UIView).removeFromSuperview()
                } else {
                    println(NSStringFromClass(view.classForCoder))
                }
            }
            
            if tagArray.count == 0 {
                scrollView.hidden = true
            } else {
                scrollView.hidden = false
                for var i = 0; i < tagArray.count; i++ {
                    // 避免 Layout 多次调用时添加了多个 Tag
                    var label = NILabel(frame: CGRectMake(0, 0, 0, 0))
                    label.userInteractionEnabled = true
                    label.text = tagArray[i] as String
                    self.labelWidthWithItsContent(label, content: SADecode(tagArray[i]))
                    label.frame.origin.x = scrollView.contentSize.width + 8
                    label.frame.origin.y = 10
                    label.tag = 12000 + i
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toSearch:"))
                    scrollView.addSubview(label)
                    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + 8 + label.frame.width , scrollView.frame.height)
                }
                
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + CGFloat(16), scrollView.frame.height)
                scrollView.canCancelContentTouches = false
                scrollView.delaysContentTouches = false
                scrollView.userInteractionEnabled = true
                scrollView.exclusiveTouch = true
            }
            
        } else {
            self.contentView.hidden = true
        }
    }
    
    func onImage() {
        var img = data!.stringAttributeForKey("image")
        var point = self.dreamhead.getPoint()
        var rect = CGRectMake(-point.x, -point.y, 60, 60)
        dreamhead.showImage("http://img.nian.so/dream/\(img)!large", rect: rect)
    }
    
    func onFo() {
        btnMain.setTitle("关注中", forState: UIControlState.allZeros)
        btnMain.removeTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
        btnMain.addTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
        var id = data!.stringAttributeForKey("id")
        Api.postFollowDream(id, follow: "1") { string in }
    }
    
    func onUnFo() {
        btnMain.setTitle("关注", forState: UIControlState.allZeros)
        btnMain.removeTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
        btnMain.addTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
        var id = data!.stringAttributeForKey("id")
        Api.postFollowDream(id, follow: "0") { string in }
    }
    
    func onLike() {
        var vc = LikeViewController()
        vc.Id = data!.stringAttributeForKey("id")
        vc.urlIdentify = 3
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func toSearch(sender: UIGestureRecognizer) {
        let label = sender.view
        var storyboard = UIStoryboard(name: "Explore", bundle: nil)
        var vc = storyboard.instantiateViewControllerWithIdentifier("ExploreSearch") as! ExploreSearch
        vc.preSetSearch = tagArray[label!.tag - 12000]
        vc.shouldPerformSearch = true
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 自定义 label
    func labelWidthWithItsContent(label: NILabel, content: NSString) {
        var dict = [NSFontAttributeName: UIFont.systemFontOfSize(12)]
        var labelSize = CGSizeMake(ceil(content.sizeWithAttributes(dict).width), ceil(content.sizeWithAttributes(dict).height))
        
        label.numberOfLines = 1
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12)
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(red: 0xe6/255, green: 0xe6/255, blue: 0xe6/255, alpha: 1).CGColor
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        label.textColor = UIColor(red: 0x99/255, green: 0x99/255, blue: 0x99/255, alpha: 1)
        label.backgroundColor = UIColor.whiteColor()
        label.frame = CGRectMake(0, 0, labelSize.width + 16, 24)
    }
}
