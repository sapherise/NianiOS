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
    var desHeight:CGFloat = 0
    var panStartPoint:CGPoint!
    var toggle:Int = 0
    var panGesture:UIGestureRecognizer!
    
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
        self.scrollView.contentSize =  CGSizeMake(8, 0)
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
            println(data)
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
            //==
            if SAUid() == uid {
                btnMain.setTitle("更新", forState: UIControlState.allZeros)
                btnMain.addTarget(self, action: "onAddStep", forControlEvents: UIControlEvents.TouchUpInside)
            } else if isFollow == "0" {
                btnMain.setTitle("关注", forState: UIControlState.allZeros)
                btnMain.addTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                btnMain.setTitle("关注中", forState: UIControlState.allZeros)
                btnMain.addTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            self.contentView.hidden = false
        } else {
            self.contentView.hidden = true
        }
    }
    
    func onAddStep() {
//        
//        var AddstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
//        AddstepVC.Id = self.Id
//        AddstepVC.delegate = self    //😍
//        self.navigationController?.pushViewController(AddstepVC, animated: true)
        var vc = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        var id = data!.stringAttributeForKey("id")
        vc.Id = id
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
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
    
//        if self.owneruid == safeuid {
//            self.topCell.btnMain.setTitle("更新", forState: UIControlState.Normal)
//            self.topCell.btnMain.addTarget(self, action: "addStepButton", forControlEvents: UIControlEvents.TouchUpInside)
//        } else {
//            if self.likeJson == "0" {
//                self.topCell.btnMain.setTitle("赞", forState: UIControlState.Normal)
//                self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
//            } else {
//                self.topCell.btnMain.setTitle("分享", forState: UIControlState.Normal)
//                self.topCell.btnMain.addTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
//            }
//        }
//
//        self.userImageURL = "http://img.nian.so/dream/\(self.imgJson)!dream"
//        self.topCell.dreamhead!.setImage(self.userImageURL, placeHolder: IconColor)
//        self.topCell.dreamhead!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamHeadClick:"))
//        
//        if (count(self.tagArray) == 0 || (count(self.tagArray) == 1 && count(tagArray[0]) == 0)) {
//            self.topCell.scrollView.hidden = true
//            self.topCell.frame.size = CGSizeMake(self.topCell.frame.size.width, self.topCell.frame.size.height - 44)
//            self.topCell.frame.origin = CGPointMake(self.topCell.frame.origin.x, self.topCell.frame.origin.y)
//            self.loadTopCellDone = true
//            self.tableView.reloadData()
//        } else {
//            self.topCell.scrollView.hidden = false
//            
//            for var i = 0; i < count(self.tagArray); i++ {
//                var label = NILabel(frame: CGRectMake(0, 0, 0, 0))
//                label.userInteractionEnabled = true
//                label.text = self.tagArray[i] as String
//                self.labelWidthWithItsContent(label, content: SADecode(self.tagArray[i]))
//                label.frame.origin.x = self.topCell.scrollView.contentSize.width + 8
//                label.frame.origin.y = 10
//                label.tag = 12000 + i
//                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toSearch:"))
//                self.topCell.scrollView.addSubview(label)
//                self.topCell.scrollView.contentSize = CGSizeMake(self.topCell.scrollView.contentSize.width + 8 + label.frame.width , self.topCell.scrollView.frame.height)
//            }
//            
//            self.topCell.scrollView.contentSize = CGSizeMake(self.topCell.scrollView.contentSize.width + CGFloat(16), self.topCell.scrollView.frame.height)
//            self.topCell.scrollView.canCancelContentTouches = false
//            self.topCell.scrollView.delaysContentTouches = false
//            self.topCell.scrollView.userInteractionEnabled = true
//            self.topCell.scrollView.exclusiveTouch = true
//            
//            self.loadTopCellDone = true
//            self.tableView.reloadData()
//        }
//    }
}
