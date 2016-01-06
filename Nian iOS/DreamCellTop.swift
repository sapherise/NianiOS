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

class DreamCellTop: UITableViewCell {

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
        viewLineLeft.setWidth(0.5)
        viewLineTop.setHeightHalf()
        scrollView.setTag()
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
        let point = pan.locationInView(self.View)
        if pan.state == UIGestureRecognizerState.Began {
            panStartPoint = point
        }
        if pan.state == UIGestureRecognizerState.Changed {
            let distanceX = pan.translationInView(self.View!).x
            self.View!.layer.removeAllAnimations()
            if self.toggle == 0 {
                let ratio:CGFloat = (distanceX > 0) ? 0.5 : 1
                self.viewLeft.frame.origin.x = distanceX * ratio + globalWidth/2 - 160
                self.viewRight.frame.origin.x = distanceX * ratio + globalWidth + globalWidth/2 - 160
            }else{
                let ratio:CGFloat = (distanceX > 0) ? 1 : 0.5
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
            var title = data!.stringAttributeForKey("title").decode()
            var content = data!.stringAttributeForKey("content").decode()
            let user = data!.stringAttributeForKey("user")
            let img = data!.stringAttributeForKey("image")
            let step = data!.stringAttributeForKey("step")
            let likeDream = data!.stringAttributeForKey("like")
            let likeStep = data!.stringAttributeForKey("like_step")
            let like = Int(likeDream)! + Int(likeStep)!
            let thePrivate = data!.stringAttributeForKey("private")
            let percent = data!.stringAttributeForKey("percent")
            let uid = data!.stringAttributeForKey("uid")
            dreamhead.setImage("http://img.nian.so/dream/\(img)!dream")
            dreamhead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
            var h: CGFloat = title.stringHeightBoldWith(18, width: 240)
            if thePrivate == "1" {
                title = "\(title)（私密）"
                let textTitle = NSMutableAttributedString(string: title)
                let l = textTitle.length
                textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSForegroundColorAttributeName, value: SeaColor, range: NSMakeRange(l-4, 4))
                nickLabel.attributedText = textTitle
                h = title.stringHeightBoldWith(18, width: 240)
            } else if percent == "1" {
                title = "\(title)（完成）"
                let textTitle = NSMutableAttributedString(string: title)
                let l = textTitle.length
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
            let bottom = nickLabel.bottom()
            viewHolder.setY(bottom + 8)
            let heightContent = content.stringHeightWith(12, width: 200)
            labelDes.text = content
            labelDes.setHeight(heightContent)
            labelDes.setY(110 - heightContent / 2)
            viewRight.setY(52)
            viewBG.setY(52)
            let bottomHolder = viewHolder.bottom() + 44
            btnMain.setY(bottomHolder + 16)
            let bottomBtn = btnMain.bottom()
            dotLeft.setY(bottomBtn + 16)
            dotRight.setY(bottomBtn + 16)
            viewBG.setHeight(h + 252)
            viewLeft.setHeight(h + 252)
            let bottomDot = dotLeft.bottom()
            viewLineTop.setY(bottomDot + 15)
            viewRight.setHeight(h + 252)
            
            numLeftNum.text = "\(like)"
            numMiddleNum.text = step
            numLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLike"))
            self.contentView.hidden = false
            
            tagArray = data!.objectForKey("tags") as! Array
            
            scrollView.contentSize =  CGSizeMake(8, 0)
            let views: NSArray = scrollView.subviews
            for view: AnyObject in views {
                if view is UILabel {
                    (view as! UIView).removeFromSuperview()
                }
            }
            
            if tagArray.count == 0 {
                let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
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
                    let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
                    label.userInteractionEnabled = true
                    let content = (tagArray[i] as String).decode()
                    label.text = content
                    self.labelWidthWithItsContent(label, content: content)
                    label.frame.origin.x = scrollView.contentSize.width + 8
                    label.frame.origin.y = 11
                    label.tag = 12000 + i
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toSearch:"))
                    scrollView.addSubview(label)
                    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + 8 + label.frame.width , scrollView.frame.height)
                }
                
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + CGFloat(16), scrollView.frame.height)
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
            let vc = PlayerViewController()
            vc.Id = data!.stringAttributeForKey("uid")
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onImage() {
        let img = data!.stringAttributeForKey("image")
        dreamhead.showImage("http://img.nian.so/dream/\(img)!dream")
    }
    
    func onLike() {
        let vc = LikeViewController()
        vc.Id = data!.stringAttributeForKey("id")
        vc.urlIdentify = 3
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func toSearch(sender: UIGestureRecognizer) {
        let label = sender.view
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ExploreSearch") as! ExploreSearch
        vc.preSetSearch = tagArray[label!.tag - 12000].decode()
        vc.shouldPerformSearch = true
        vc.index = 1
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 自定义 label
    func labelWidthWithItsContent(label: UILabel, content: String) {
        label.setTagLabel(content)
    }
}

extension UIScrollView {
    func setTag() {
        self.setWidth(globalWidth)
        self.setY(0)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.C98()
        let viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 0.5))
        let viewBottom = UIView(frame: CGRectMake(0, 51.5, globalWidth, 0.5))
        viewTop.backgroundColor = UIColor.f0()
        viewBottom.backgroundColor = UIColor.f0()
        self.superview?.addSubview(viewTop)
        self.superview?.addSubview(viewBottom)
        self.canCancelContentTouches = false
        self.delaysContentTouches = false
        self.userInteractionEnabled = true
        self.exclusiveTouch = true
    }
}

extension UILabel {
    func setTagLabel(content: String) {
        self.numberOfLines = 1
        self.textAlignment = .Center
        self.font = UIFont.systemFontOfSize(12)
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1).CGColor
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        self.textColor = UIColor.b3()
        self.backgroundColor = UIColor.whiteColor()
        let width = content.stringWidthWith(12, height: 30)
        self.frame = CGRectMake(0, 11, width + 16, 30)
        self.text = content
    }
}
