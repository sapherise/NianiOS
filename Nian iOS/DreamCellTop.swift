//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol topDelegate {
    func editMyDream()
}

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
    @IBOutlet var viewLineTop: UIView!
    @IBOutlet var viewLineTag: UIView!
    @IBOutlet var viewLineTagTop: UIView!
    var delegate: topDelegate?
    
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
        self.dotLeft.setX(globalWidth/2-8)
        self.dotRight.setX(globalWidth/2+2)
        self.viewLineTop.setWidth(globalWidth - 40)
        self.viewLineTag.setWidth(globalWidth)
        self.viewLineTagTop.setWidth(globalWidth)
//        self.viewLineTag.setHeight(0.5)
//        self.viewLineTagTop.setHeight(0.5)
        viewLineLeft.setWidth(0.5)
//        viewLineTop.setHeight(0.5)
        
        viewLineTag.setHeightHalf()
        viewLineTagTop.setHeightHalf()
        viewLineTop.setHeightHalf()
    
        self.scrollView.setWidth(globalWidth)
        self.scrollView.setY(0)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
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
            } else if panY < 52 {
                return false
            } else {
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
            var user = data!.stringAttributeForKey("user")
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
            var h: CGFloat = title.stringHeightBoldWith(18, width: 240)
            if thePrivate == "1" {
                title = "\(title)（私密）"
                var textTitle = NSMutableAttributedString(string: title)
                var l = textTitle.length
                textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSForegroundColorAttributeName, value: SeaColor, range: NSMakeRange(l-4, 4))
                nickLabel.attributedText = textTitle
                h = title.stringHeightBoldWith(18, width: 240)
            } else if percent == "1" {
                title = "\(title)（完成）"
                var textTitle = NSMutableAttributedString(string: title)
                var l = textTitle.length
                textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(l-4, 4))
                nickLabel.attributedText = textTitle
                h = title.stringHeightBoldWith(18, width: 240)
            } else {
                nickLabel.text = title
            }
            nickLabel.setHeight(h)
            if content == "" {
                content = "暂无简介"
            }
            var bottom = nickLabel.bottom()
            viewHolder.setY(bottom + 8)
            var heightContent = content.stringHeightWith(12, width: 200)
            labelDes.text = content
            labelDes.setHeight(heightContent)
            labelDes.setY(110 - heightContent / 2)
            viewRight.setY(52)
            viewBG.setY(52)
            var bottomHolder = viewHolder.bottom() + 44
            btnMain.setY(bottomHolder + 16)
            var bottomBtn = btnMain.bottom()
            dotLeft.setY(bottomBtn + 16)
            dotRight.setY(bottomBtn + 16)
            viewBG.setHeight(h + 252)
            viewLeft.setHeight(h + 252)
            var bottomDot = dotLeft.bottom()
            viewLineTop.setY(bottomDot + 15)
            viewRight.setHeight(h + 252)
            
            numLeftNum.text = "\(like)"
            numMiddleNum.text = step
            numLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLike"))
            self.contentView.hidden = false
            
            tagArray = data!.objectForKey("tags") as! Array
            
            scrollView.contentSize =  CGSizeMake(8, 0)
            var views: NSArray = scrollView.subviews
            for view: AnyObject in views {
                if view is NILabel {
                    (view as! UIView).removeFromSuperview()
                }
            }
            
            if tagArray.count == 0 {
                var label = NILabel(frame: CGRectMake(0, 0, 0, 0))
                label.userInteractionEnabled = true
                if SAUid() == uid {
                    label.text = "添加标签"
                    self.labelWidthWithItsContent(label, content: "添加标签")
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toEdit"))
                } else {
                    label.text = user
                    self.labelWidthWithItsContent(label, content: user)
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser"))
                }
                
                label.frame.origin.x = scrollView.contentSize.width + 8
                label.frame.origin.y = 11
                scrollView.addSubview(label)
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + 8 + label.frame.width , scrollView.frame.height)
            } else {
                scrollView.hidden = false
                for var i = 0; i < tagArray.count; i++ {
                    var label = NILabel(frame: CGRectMake(0, 0, 0, 0))
                    label.userInteractionEnabled = true
                    label.text = SADecode(SADecode(tagArray[i] as String))
                    self.labelWidthWithItsContent(label, content: SADecode(tagArray[i]))
                    label.frame.origin.x = scrollView.contentSize.width + 8
                    label.frame.origin.y = 11
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
    
    func toEdit() {
        delegate?.editMyDream()
    }
    
    func toUser() {
        if data != nil {
            var vc = PlayerViewController()
            vc.Id = data!.stringAttributeForKey("uid")
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onImage() {
        var img = data!.stringAttributeForKey("image")
        var point = self.dreamhead.getPoint()
        var rect = CGRectMake(-point.x, -point.y, 60, 60)
        dreamhead.showImage("http://img.nian.so/dream/\(img)!large", rect: rect)
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
        vc.preSetSearch = SADecode(SADecode(tagArray[label!.tag - 12000]))
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
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1).CGColor
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        label.backgroundColor = UIColor.whiteColor()
        label.frame = CGRectMake(0, 0, labelSize.width + 16, 30)
    }
}
