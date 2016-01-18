//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

@objc protocol topDelegate {
    func editMyDream()
    optional func onAddStep()
    optional func onFo()
    optional func onUnFo()
}

class DreamCellTop: UITableViewCell {
    
    @IBOutlet var labelTitle:UILabel!
    @IBOutlet var imageDream:UIImageView!
    @IBOutlet var labelDes:UILabel!
    @IBOutlet var btnMain:UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var numLeft:UIView!
    @IBOutlet var numMiddle:UIView!
    @IBOutlet var numRight: UIView!
    
    @IBOutlet var numLeftNum:UILabel!
    @IBOutlet var numMiddleNum:UILabel!
    @IBOutlet var numRightNum: UILabel!
    
    @IBOutlet var viewLineLeft: UIView!
    @IBOutlet var viewLineRight: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var viewLineTop: UIView!
    
    var delegate: topDelegate?
    
    var data: NSDictionary!
    var toggle:Int = 0
    var tagArray: Array<String> = []  // 加 tag
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.btnMain.backgroundColor = SeaColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.viewLineTop.setWidth(globalWidth - 40)
        viewLineLeft.setWidth(0.5)
        viewLineRight.setWidth(0.5)
        viewLineTop.setHeightHalf()
        scrollView.setTag()
        btnMain.backgroundColor = SeaColor
    }
    
    //    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
    //            return false
    //        }else{
    //            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
    //            let panY = panGesture.locationInView(self).y
    //            let translation = panGesture.translationInView(self)
    //            if fabs(translation.y) > fabs(translation.x) {  //如果是往下划
    //                return false
    //            } else if panY < 52 {
    //                return false
    //            } else {
    //                return true
    //            }
    //        }
    //    }
    
    func setup() {
        /* 解析数据 */
        var title = data.stringAttributeForKey("title")
        let content = data.stringAttributeForKey("content")
        let user = data.stringAttributeForKey("user")
        let img = data.stringAttributeForKey("image")
        let step = data.stringAttributeForKey("step")
        let likeDream = data.stringAttributeForKey("like")
        let likeStep = data.stringAttributeForKey("like_step")
        let like = Int(likeDream)! + Int(likeStep)!
        let thePrivate = data.stringAttributeForKey("private")
        let percent = data.stringAttributeForKey("percent")
        let uid = data.stringAttributeForKey("uid")
        tagArray = data.objectForKey("tags") as! Array
        let identity = data.stringAttributeForKey("identity")
        let heightTitle = data.objectForKey("heightTitle") as! CGFloat
        let heightContent = data.objectForKey("heightContent") as! CGFloat
        let totalUsers = data.stringAttributeForKey("total_users")
        
        /* 判断是否加入该记本了，0 未加入，1 已加入，2 邀请中 */
        let isJoined = data.stringAttributeForKey("joined")
        
        /* 判断是否正在关注这个记本 */
        let isFollowed = data.stringAttributeForKey("followed")
        
        /* 封面图 */
        imageDream.setImage("http://img.nian.so/dream/\(img)!dream")
        imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        imageDream.setX((globalWidth - imageDream.width())/2)
        
        /* 标题 */
        if thePrivate == "1" {
            title = "\(title)（私密）"
            let textTitle = NSMutableAttributedString(string: title)
            let l = textTitle.length
            textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
            textTitle.addAttribute(NSForegroundColorAttributeName, value: SeaColor, range: NSMakeRange(l-4, 4))
            labelTitle.attributedText = textTitle
        } else if percent == "1" {
            title = "\(title)（完成）"
            let textTitle = NSMutableAttributedString(string: title)
            let l = textTitle.length
            textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
            textTitle.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(l-4, 4))
            labelTitle.attributedText = textTitle
        } else {
            labelTitle.text = title
        }
        labelTitle.setHeight(heightTitle)
        labelTitle.setX(globalWidth/2 - 120)
        
        /* 简介 */
        if content != "" {
            labelDes.frame = CGRectMake(globalWidth/2 - 120, labelTitle.bottom() + 8, 240, heightContent)
            labelDes.text = content
        } else {
            labelDes.hidden = true
        }
        
        /* 更多信息 */
        let yViewHolder = content == "" ? labelTitle.bottom() + 8 : labelDes.bottom() + 8
        viewHolder.setY(yViewHolder)
        viewHolder.setX(globalWidth/2 - 160)
        numLeftNum.text = "\(like)"
        numMiddleNum.text = step
        numRightNum.text = totalUsers
        numLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLike"))
        numRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMembers"))
        
        /* 按钮 */
        btnMain.setY(viewHolder.bottom() + 16)
        btnMain.setX((globalWidth - btnMain.width())/2)
        
        /* 分割线 */
        viewLineTop.setY(btnMain.bottom() + 32)
        
        /* 如果已经加入 */
        if isJoined == "1" || SAUid() == uid {
            btnMain.setTitle("更新", forState: UIControlState())
            btnMain.addTarget(self, action: "onAdd", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            /* 如果未加入 */
            if isFollowed == "1" {
                btnMain.setTitle("已关注", forState: UIControlState())
                btnMain.addTarget(self, action: "onUnFollow", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                btnMain.setTitle("关注", forState: UIControlState())
                btnMain.addTarget(self, action: "onFollow", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        // todo: 编辑记本有问题
        
        /* 标签行 */
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
    }
    
    func toEdit() {
        delegate?.editMyDream()
    }
    
    func onAdd() {
        delegate?.onAddStep!()
    }
    
    func onUnFollow() {
        delegate?.onUnFo!()
    }
    
    func onFollow() {
        delegate?.onFo!()
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
        imageDream.showImage("http://img.nian.so/dream/\(img)!dream")
    }
    
    /* 查看按赞 */
    func onLike() {
        let vc = LikeViewController()
        vc.Id = data!.stringAttributeForKey("id")
        vc.urlIdentify = 3
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    /* 查看成员 */
    func onMembers() {
        let vc = List()
        vc.type = ListType.Members
        let id = data.stringAttributeForKey("id")
        vc.id = id
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
        self.backgroundColor = UIColor.C98()
        let viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 0.5))
        let viewBottom = UIView(frame: CGRectMake(0, 51.5, globalWidth, 0.5))
        viewTop.backgroundColor = UIColor.f0()
        viewBottom.backgroundColor = UIColor.f0()
        self.superview?.addSubview(viewTop)
        self.superview?.addSubview(viewBottom)
//        self.exclusiveTouch = true
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
