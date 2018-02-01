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
    @objc optional func onAddStep()
    @objc optional func onFo()
    @objc optional func onUnFo()
    @objc optional func Join()
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
    @IBOutlet var viewNav: UIImageView!
    
    /* 当加入记本时，创建一个头像出来，但 setup() 时要移除 */
    var imageJoin: UIImageView?
    
    var delegate: topDelegate?
    
    var data: NSMutableDictionary!
    var toggle:Int = 0
    var tagArray: Array<String> = []  // 加 tag
    
    func setup() {
        /* 解析数据 */
        imageJoin?.removeFromSuperview()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        scrollView.setWidth(globalWidth)
        btnMain.backgroundColor = UIColor.HighlightColor()
        contentView.backgroundColor = UIColor.BackgroundColor()
        labelTitle.backgroundColor = UIColor.BackgroundColor()
        labelDes.backgroundColor = UIColor.BackgroundColor()
        imageDream.layer.borderWidth = 3
        imageDream.layer.borderColor = UIColor.BackgroundColor().cgColor
        viewNav.layer.masksToBounds = true
        viewNav.setWidth(globalWidth)
        viewNav.backgroundColor = UIColor.NavColor()
        btnMain.setX(globalWidth - SIZE_PADDING - btnMain.width())
        imageDream.backgroundColor = UIColor.GreyBackgroundColor()
        
        if data != nil {
            var title = data.stringAttributeForKey("title")
            let content = data.stringAttributeForKey("content")
            let user = data.stringAttributeForKey("user")
            let img = data.stringAttributeForKey("image")
            let step = data.stringAttributeForKey("step")
            let followers = data.stringAttributeForKey("followers")
            let thePrivate = data.stringAttributeForKey("private")
            let percent = data.stringAttributeForKey("percent")
            let uid = data.stringAttributeForKey("uid")
            tagArray = data.object(forKey: "tags") as! Array
            let heightTitle = data.object(forKey: "heightTitle") as! CGFloat
            let heightContent = data.object(forKey: "heightContent") as! CGFloat
            
            
            let widthStep = data.object(forKey: "widthStep") as! CGFloat
            let widthLike = data.object(forKey: "widthLike") as! CGFloat
            let widthFollowers = data.object(forKey: "widthFollowers") as! CGFloat
            
            /* 判断是否加入该记本了，0 未加入，1 已加入，2 邀请中 */
            let isJoined = data.stringAttributeForKey("joined")
            
            /* 判断是否正在关注这个记本 */
            let isFollowed = data.stringAttributeForKey("followed")
            
            /* 封面图 */
            imageDream.setImage("http://img.nian.so/dream/\(img)!dream")
            imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCellTop.onImage)))
            imageDream.setX(SIZE_PADDING)
            
            /* 导航栏 */
//            SDWebImageDownloader.sharedDownloader().downloadImageWithURL(NSURL(string: "http://img.nian.so/cover/\(cover)!cover")!, options: SDWebImageDownloaderOptions(rawValue: 0), progress: { (recvSize, totalSize) in
//                }, completed: { (image, data, error, finished) in
//                    self.viewNav.setImage("http://img.nian.so/cover/\(cover)!cover")
//            })
            
            /* 标题 */
            if thePrivate == "1" {
                title = "\(title)（私密）"
                let textTitle = NSMutableAttributedString(string: title)
                let l = textTitle.length
                textTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.HighlightColor(), range: NSMakeRange(l-4, 4))
                labelTitle.attributedText = textTitle
            } else if percent == "1" {
                title = "\(title)（完成）"
                let textTitle = NSMutableAttributedString(string: title)
                let l = textTitle.length
                textTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSMakeRange(0, l-4))
                textTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: GoldColor, range: NSMakeRange(l-4, 4))
                labelTitle.attributedText = textTitle
            } else {
                labelTitle.text = title
            }
            labelTitle.setWidth(globalWidth - SIZE_PADDING * 2)
            labelTitle.setHeight(heightTitle)
            labelTitle.setX(SIZE_PADDING)
            
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
            
            
            if let likeDream = Int(data.stringAttributeForKey("like")) {
                if let likeStep = Int(data.stringAttributeForKey("like_step")) {
                    let like = likeDream + likeStep
                    labelLike.text = "赞 \(like)"
                }
            }
            
            labelStep.text = "进展 \(step)"
            labelFollow.text = "关注 \(followers)"
            dot1.setX(labelStep.right() + p)
            dot2.setX(labelLike.right() + p)
            labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onLike)))
            labelLike.isUserInteractionEnabled = true
            labelFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onFollowers)))
            labelFollow.isUserInteractionEnabled = true
            
            /* 简介 */
            if content != "" {
                labelDes.frame = CGRect(x: SIZE_PADDING, y: viewHolder.bottom(), width: globalWidth - SIZE_PADDING * 2, height: heightContent)
                labelDes.text = content
                labelDes.isHidden = false
            } else {
                labelDes.isHidden = true
            }
            
            /* 按钮 */
            /* 如果已经加入 */
            if isJoined == "1" || SAUid() == uid {
                btnMain.setTitle("更新", for: UIControlState())
                btnMain.addTarget(self, action: #selector(DreamCellTop.onAdd), for: UIControlEvents.touchUpInside)
            } else {
                /* 如果未加入 */
                if isFollowed == "1" {
                    btnMain.setTitle("已关注", for: UIControlState())
                    btnMain.addTarget(self, action: #selector(DreamCellTop.onUnFollow), for: UIControlEvents.touchUpInside)
                } else {
                    btnMain.setTitle("关注", for: UIControlState())
                    btnMain.addTarget(self, action: #selector(DreamCellTop.onFollow), for: UIControlEvents.touchUpInside)
                }
            }
            
            /* 标签行 */
            scrollView.contentSize =  CGSize(width: SIZE_PADDING - 8, height: 0)
            if content != "" {
                scrollView.setY(labelDes.bottom())
            } else {
                scrollView.setY(viewHolder.bottom() - 8)
            }
            let views: NSArray = scrollView.subviews as NSArray
            for view in views {
                if view is UILabel {
                    (view as! UIView).removeFromSuperview()
                }
            }
            if tagArray.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                label.isUserInteractionEnabled = true
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
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width + 8 + label.frame.width , height: scrollView.frame.height)
            } else {
                scrollView.isHidden = false
                for i in 0 ..< tagArray.count {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    label.isUserInteractionEnabled = true
                    let content = (tagArray[i] as String).decode()
                    label.text = content
                    self.labelWidthWithItsContent(label, content: content)
                    label.frame.origin.x = scrollView.contentSize.width + 8
                    label.frame.origin.y = 16
                    label.tag = 12000 + i
                    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCellTop.toSearch(_:))))
                    scrollView.addSubview(label)
                    scrollView.contentSize = CGSize(width: scrollView.contentSize.width + 8 + label.frame.width , height: scrollView.frame.height)
                }
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width + SIZE_PADDING, height: scrollView.frame.height)
            }
            
            /* 分割线 */
            viewLineTop.frame = CGRect(x: SIZE_PADDING, y: scrollView.bottom(), width: globalWidth - SIZE_PADDING * 2, height: globalHalf)
            
            /* 成员 */
            viewHeaders.setY(viewLineTop.bottom())
            viewHeaders.setX(SIZE_PADDING)
            viewHeaders.setWidth(globalWidth - SIZE_PADDING * 2)
            
            /* 显示加入的按钮 */
            /* 如果未加入该记本 */
            if isJoined == "0" && uid != SAUid() {
                let permission = data.stringAttributeForKey("permission")
                let isFriend = data.stringAttributeForKey("is_friend")
                /* 如果 permission = 1 同时 isFriend = 1，显示加入 */
                /* 如果 permission = 2，显示加入 */
                if permission == "1" && isFriend == "1" {
                    showJoinButton()
                } else if permission == "2" {
                    showJoinButton()
                }
            }
            
            if let editors = data.object(forKey: "editors") as? NSArray {
                for i in 0 ..< editors.count {
                    let head = UIImageView(frame: CGRect(x: CGFloat(i) * (32 + 8), y: 16, width: 32, height: 32))
                    head.setHead("\(editors[i])")
                    head.layer.cornerRadius = 16
                    head.layer.masksToBounds = true
                    head.isUserInteractionEnabled = true
                    head.tag = Int("\(editors[i])")!
                    head.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onUser(_:))))
                    viewHeaders.addSubview(head)
                }
                
                /* 更多成员的按钮 */
                if let totalUsers = Int(data.stringAttributeForKey("total_users")) {
                    
                    /* 当成员数量超过 3 人时 */
                    var count = editors.count
                    if totalUsers > 3 {
                        let num = UILabel(frame: CGRect(x: CGFloat(count) * (32 + 8), y: 16, width: 32, height: 32))
                        num.backgroundColor = UIColor.WindowColor()
                        num.text = "+\(min(99, totalUsers - 3))"
                        num.textColor = UIColor.AuxiliaryColor()
                        num.textAlignment = .center
                        num.font = UIFont.systemFont(ofSize: 12)
                        num.layer.cornerRadius = 16
                        num.layer.masksToBounds = true
                        num.isUserInteractionEnabled = true
                        num.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onMembers)))
                        viewHeaders.addSubview(num)
                        count += 1
                    }
                    
                    /* 当用户是记本主人或是成员时，添加邀请的入口 */
                    if uid == SAUid() || isJoined == "1" {
                        let join = UILabel(frame: CGRect(x: CGFloat(count) * (32 + 8), y: 16, width: 32, height: 32))
                        join.backgroundColor = UIColor.WindowColor()
                        join.text = "+"
                        join.textColor = UIColor.AuxiliaryColor()
                        join.textAlignment = .center
                        join.font = UIFont.systemFont(ofSize: 16)
                        join.layer.cornerRadius = 16
                        join.layer.masksToBounds = true
                        join.isUserInteractionEnabled = true
                        join.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onMembers)))
                        viewHeaders.addSubview(join)
                    }
                }
            }
            
            /* 分割线 */
            viewLineBottom.backgroundColor = UIColor.LineColor()
            viewLineBottom.frame = CGRect(x: SIZE_PADDING, y: viewHeaders.bottom(), width: globalWidth - SIZE_PADDING * 2, height: globalHalf)
            
            scroll(0)
            viewLineBottom.isHidden = false
            viewLineTop.isHidden = false
            viewHolder.isHidden = false
            btnMain.isHidden = false
            labelTitle.isHidden = false
            labelDes.isHidden = false
            scrollView.isHidden = false
            
            /* 当不在记本中，没有加入的权限，编辑者只有作者一个人 */
            let willHeadersHidden = data.stringAttributeForKey("willHeadersHidden")
            if willHeadersHidden == "1" {
                viewHeaders.isHidden = true
                viewLineBottom.isHidden = true
                viewLineTop.setY(viewLineTop.y() + 8)
            }
        } else {
            viewLineBottom.isHidden = true
            viewLineTop.isHidden = true
            viewHolder.isHidden = true
            btnMain.isHidden = true
            labelTitle.isHidden = true
            labelDes.isHidden = true
            scrollView.isHidden = true
        }
    }
    
    /* 显示加入按钮 */
    func showJoinButton() {
        let btnJoin = UIButton(frame: CGRect(x: viewHeaders.width() - btnMain.width(), y: (viewHeaders.height() - btnMain.height())/2, width: btnMain.width(), height: btnMain.height()))
        btnJoin.setTitle("加入", for: UIControlState())
        btnJoin.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnJoin.setTitleColor(UIColor.HighlightColor(), for: UIControlState())
        btnJoin.layer.borderWidth = 1
        btnJoin.layer.borderColor = UIColor.HighlightColor().cgColor
        btnJoin.layer.cornerRadius = btnMain.height() * 0.5
        viewHeaders.addSubview(btnJoin)
        btnJoin.addTarget(self, action: #selector(self.join), for: UIControlEvents.touchUpInside)
    }
    
    @objc func join(_ sender: UIButton) {
        let w: CGFloat = 32
        imageJoin = UIImageView(frame: CGRect(x: SIZE_PADDING - 8 - w, y: viewHeaders.y() + (viewHeaders.height() - w) / 2, width: w, height: w))
        imageJoin!.setHead(SAUid())
        imageJoin!.layer.cornerRadius = w * 0.5
        imageJoin!.layer.masksToBounds = true
        imageJoin!.isUserInteractionEnabled = true
        imageJoin!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onHeadMe)))
        self.addSubview(imageJoin!)
        sender.isUserInteractionEnabled = false
        delegate?.Join!()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewHeaders.setX(SIZE_PADDING + 8 + w)
            self.imageJoin!.setX(SIZE_PADDING)
            sender.alpha = 0
            }, completion: { (Bool) in
                sender.isHidden = true
        }) 
        
        btnMain.removeTarget(nil, action: nil, for: UIControlEvents.touchUpInside)
        btnMain.setTitle("加入中..", for: UIControlState())
        
        /* 网络请求 */
        let id = data.stringAttributeForKey("id")
        Api.postJoin(id, cuid: "a") { json in
            if json != nil {
                if let d = json!.object(forKey: "data") as? NSDictionary {
                    let id = d.stringAttributeForKey("id")
                    let img = d.stringAttributeForKey("image")
                    let title = d.stringAttributeForKey("title").decode()
                    Nian.addDreamCallback(id, img: img, title: title)
                    self.btnMain.setTitle("更新", for: UIControlState())
                    self.btnMain.addTarget(self, action: #selector(DreamCellTop.onAdd), for: UIControlEvents.touchUpInside)
                }
            }
        }
    }
    
    @objc func onHeadMe() {
        let vc = PlayerViewController()
        vc.Id = SAUid()
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onUser(_ sender: UIGestureRecognizer) {
        if let v = sender.view {
            let tag = v.tag
            let vc = PlayerViewController()
            vc.Id = "\(tag)"
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scroll(_ y: CGFloat) {
        let marginTop: CGFloat = 8
        let widthBefore: CGFloat = 72
        let widthAfter: CGFloat = 48
        
        let bottom: CGFloat = 64 + marginTop + widthBefore
        
        /* 原来的导航栏的高度 */
        let heightViewNavBefore: CGFloat = 96
        
        /* 改变样式的 y 的临界点 */
        let yDidChange: CGFloat = 32
        
        /* 当 y = 0 时，头像的宽是 72，当 y = 32 时，头像的宽是 48 */
        var w = widthBefore
        if y > 32 {
            w = widthAfter
        } else if y > 0 {
            w = (widthAfter - widthBefore) * y / yDidChange + widthBefore
        }
        imageDream.frame.size = CGSize(width: w, height: w)
        imageDream.setY(bottom - w)
        viewNav.setY(y)
        viewNav.setHeight(heightViewNavBefore - y)
    }
    
    @objc func toEdit() {
        delegate?.editMyDream()
    }
    
    @objc func onAdd() {
        delegate?.onAddStep!()
    }
    
    @objc func onUnFollow() {
        delegate?.onUnFo!()
    }
    
    @objc func onFollow() {
        delegate?.onFo!()
    }
    
    @objc func toUser() {
        if data != nil {
            let vc = PlayerViewController()
            vc.Id = data!.stringAttributeForKey("uid")
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onImage() {
        let img = data!.stringAttributeForKey("image")
        let images = NSMutableArray()
        let d = ["path": "\(img)", "width": "500", "height": "500"]
        images.add(d)
        imageDream.open(images, index: 0, exten: "!dream", folder: "dream")
    }
    
    /* 查看按赞 */
    @objc func onLike() {
        let vc = List()
        vc.type = ListType.dreamLikes
        vc.id = data.stringAttributeForKey("id")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onFollowers() {
        let vc = List()
        vc.type = ListType.followers
        vc.id = data.stringAttributeForKey("id")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    /* 查看成员 */
    @objc func onMembers() {
        let vc = List()
        vc.type = ListType.members
        let id = data.stringAttributeForKey("id")
        vc.id = id
        let uid = data.stringAttributeForKey("uid")
        let joined = data.stringAttributeForKey("joined")
        if uid == SAUid() || joined == "1" {
            vc.willShowInviteButton = true
        }
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func toSearch(_ sender: UIGestureRecognizer) {
        let label = sender.view
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ExploreSearch") as! ExploreSearch
        vc.preSetSearch = tagArray[label!.tag - 12000].decode()
        vc.shouldPerformSearch = true
        vc.index = 1
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 自定义 label
    func labelWidthWithItsContent(_ label: UILabel, content: String) {
        label.setTagLabel(content)
    }
}

extension UILabel {
    func setTagLabel(_ content: String) {
        self.numberOfLines = 1
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 12)
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1).cgColor
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        self.textColor = UIColor.b3()
        self.backgroundColor = UIColor.WindowColor()
        let width = content.stringWidthWith(12, height: 24)
        self.frame = CGRect(x: 0, y: 11, width: width + 16, height: 24)
        self.text = content
    }
}
