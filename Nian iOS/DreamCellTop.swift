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
    @IBOutlet var viewLineTop: UIView!
    @IBOutlet var labelStep: UILabel!
    @IBOutlet var labelLike: UILabel!
    @IBOutlet var labelFollow: UILabel!
    @IBOutlet var dot1: UIView!
    @IBOutlet var dot2: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var viewHeaders: UIView!
    @IBOutlet var viewLineBottom: UIView!
    
    var delegate: topDelegate?
    
    var data: NSDictionary!
    var toggle:Int = 0
    var tagArray: Array<String> = []  // 加 tag
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        scrollView.setWidth(globalWidth)
        btnMain.backgroundColor = UIColor.HighlightColor()
        contentView.backgroundColor = UIColor.BackgroundColor()
        labelTitle.backgroundColor = UIColor.BackgroundColor()
        labelDes.backgroundColor = UIColor.BackgroundColor()
    }
    
    func setup() {
        /* 解析数据 */
        print(data)
        var title = data.stringAttributeForKey("title")
        let content = data.stringAttributeForKey("content")
        let user = data.stringAttributeForKey("user")
        let img = data.stringAttributeForKey("image")
        let step = data.stringAttributeForKey("step")
        let followers = data.stringAttributeForKey("followers")
        let like = data.stringAttributeForKey("like")
        let thePrivate = data.stringAttributeForKey("private")
        let percent = data.stringAttributeForKey("percent")
        let uid = data.stringAttributeForKey("uid")
        tagArray = data.objectForKey("tags") as! Array
        let heightTitle = data.objectForKey("heightTitle") as! CGFloat
        let heightContent = data.objectForKey("heightContent") as! CGFloat
        
        
        let widthStep = data.objectForKey("widthStep") as! CGFloat
        let widthLike = data.objectForKey("widthLike") as! CGFloat
        let widthFollowers = data.objectForKey("widthFollowers") as! CGFloat
        
        let heightCell = data.objectForKey("heightCell") as! CGFloat
        
        /* 判断是否加入该记本了，0 未加入，1 已加入，2 邀请中 */
        let isJoined = data.stringAttributeForKey("joined")
        
        /* 判断是否正在关注这个记本 */
        let isFollowed = data.stringAttributeForKey("followed")
        
        /* 封面图 */
        imageDream.setImage("http://img.nian.so/dream/\(img)!dream")
        imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCellTop.onImage)))
        imageDream.setX(SIZE_PADDING)
        
        /* 三个数字 */
        let p: CGFloat = 6
        let widthDot: CGFloat = dot1.width()
        viewHolder.setY(labelTitle.bottom())
        viewHolder.setWidth(globalWidth - SIZE_PADDING * 2)
        labelStep.textColor = UIColor.secAuxiliaryColor()
        labelLike.textColor = UIColor.secAuxiliaryColor()
        labelFollow.textColor = UIColor.secAuxiliaryColor()
        dot1.backgroundColor = UIColor.secAuxiliaryColor()
        dot2.backgroundColor = UIColor.secAuxiliaryColor()
        labelStep.setWidth(widthStep)
        labelLike.setWidth(widthLike)
        labelFollow.setWidth(widthFollowers)
        labelStep.setX(0)
        labelLike.setX(labelStep.right() + widthDot + p * 2)
        labelFollow.setX(labelLike.right() + widthDot + p * 2)
        labelStep.text = step
        labelLike.text = like
        labelFollow.text = followers
        dot1.setX(labelStep.right() + p)
        dot2.setX(labelLike.right() + p)
        
        
        /* 标题 */
        if thePrivate == "1" {
            title = "\(title)（私密）"
            let textTitle = NSMutableAttributedString(string: title)
            let l = textTitle.length
            textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, l-4))
            textTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.HighlightColor(), range: NSMakeRange(l-4, 4))
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
        labelTitle.setWidth(globalWidth - SIZE_PADDING * 2)
        labelTitle.setHeight(heightTitle)
        labelTitle.setX(SIZE_PADDING)
        
        /* 简介 */
        if content != "" {
            labelDes.frame = CGRectMake(SIZE_PADDING, viewHolder.bottom(), globalWidth - SIZE_PADDING * 2, heightContent)
            labelDes.text = content
            labelDes.hidden = false
        } else {
            labelDes.hidden = true
        }
        
        /* 按钮 */
        btnMain.setX(globalWidth - SIZE_PADDING - btnMain.width())
        
        /* 如果已经加入 */
        if isJoined == "1" || SAUid() == uid {
            btnMain.setTitle("更新", forState: UIControlState())
            btnMain.addTarget(self, action: #selector(DreamCellTop.onAdd), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            /* 如果未加入 */
            if isFollowed == "1" {
                btnMain.setTitle("已关注", forState: UIControlState())
                btnMain.addTarget(self, action: #selector(DreamCellTop.onUnFollow), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                btnMain.setTitle("关注", forState: UIControlState())
                btnMain.addTarget(self, action: #selector(DreamCellTop.onFollow), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        /* 标签行 */
        scrollView.contentSize =  CGSizeMake(8, 0)
        scrollView.setY(labelDes.bottom())
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
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCellTop.toEdit)))
            } else {
                label.text = user
                self.labelWidthWithItsContent(label, content: user)
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCellTop.toUser)))
            }
            
            label.frame.origin.x = scrollView.contentSize.width + 8
            label.frame.origin.y = 16
            scrollView.addSubview(label)
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + 8 + label.frame.width , scrollView.frame.height)
        } else {
            scrollView.hidden = false
            for i in 0 ..< tagArray.count {
                let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
                label.userInteractionEnabled = true
                let content = (tagArray[i] as String).decode()
                label.text = content
                self.labelWidthWithItsContent(label, content: content)
                label.frame.origin.x = scrollView.contentSize.width + 8
                label.frame.origin.y = 16
                label.tag = 12000 + i
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCellTop.toSearch(_:))))
                scrollView.addSubview(label)
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + 8 + label.frame.width , scrollView.frame.height)
            }
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width + CGFloat(16), scrollView.frame.height)
        }
        
        /* 分割线 */
        viewLineTop.frame = CGRectMake(SIZE_PADDING, scrollView.bottom(), globalWidth - SIZE_PADDING * 2, globalHalf)
        
        /* 成员 */
        viewHeaders.setY(viewLineTop.bottom())
        viewHeaders.setX(SIZE_PADDING)
        viewHeaders.setWidth(globalWidth - SIZE_PADDING * 2)
        viewHeaders.backgroundColor = UIColor.yellowColor()
        
        /* 分割线 */
        viewLineBottom.backgroundColor = UIColor.LineColor()
        viewLineBottom.frame = CGRectMake(SIZE_PADDING, viewHeaders.bottom(), globalWidth - SIZE_PADDING * 2, globalHalf)
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
//        imageDream.showImage("http://img.nian.so/dream/\(img)!dream")
        
        
        let images = NSMutableArray()
        let d = ["path": "\(img)", "width": "500", "height": "500"]
        images.addObject(d)
        imageDream.open(images, index: 0, exten: "!dream", folder: "dream")
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
        let uid = data.stringAttributeForKey("uid")
        let joined = data.stringAttributeForKey("joined")
        if uid == SAUid() || joined == "1" {
            vc.willShowInviteButton = true
        }
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
        self.backgroundColor = UIColor.WindowColor()
        let width = content.stringWidthWith(12, height: 24)
        self.frame = CGRectMake(0, 11, width + 16, 24)
        self.text = content
    }
}
