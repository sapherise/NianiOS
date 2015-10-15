//
//  SAStepCell.swift
//  Nian iOS
//
//  Created by Sa on 15/5/14.
//  Copyright (c) 2015年 Sa. All rights reserved.
//  食用指南
//  a) 添加 delegate：delegateSAStepCell
//  b) 添加 delegate 中的 4 个函数
//  c) 记得注册这个 Cell
//  d) 修改 cellfor 里的
//    var c = dreamTableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
//    c.delegate = self
//    c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
//    c.index = indexPath.row
//    if indexPath.row == self.dataArrayStep.count - 1 {
//        c.viewLine.hidden = true
//    } else {
//        c.viewLine.hidden = false
//    }
//    return c

import UIKit

protocol delegateSAStepCell {
    func updateStep(index: Int, key: String, value: String)
    func updateStep(index: Int)
    func updateStep()
    func updateStep(index: Int, delete: Bool)
}

class SAStepCell: UITableViewCell, AddstepDelegate, UIActionSheetDelegate{
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var imageHolder: UIImageView!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var btnMore: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnUnLike: UIButton!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelContent: KILabel!
    @IBOutlet var labelLike: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var viewLine: UIView!
    
    var actionSheetDelete: UIActionSheet!
    var data :NSDictionary?
    
    //    var indexSection: Int = 0
    //    var indexPathRow: Int = 0
    var indexPath: NSIndexPath?
    
    var index: Int = 0
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    var activityViewController: UIActivityViewController!
    var isDynamic: Bool = false
    var delegate: delegateSAStepCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        self.viewMenu.setWidth(globalWidth)
        self.setWidth(globalWidth)
        self.labelTime.setX(globalWidth - 82 - 20)
        self.btnMore.setX(globalWidth - 52)
        self.btnLike.setX(globalWidth - 52)
        self.btnUnLike.setX(globalWidth - 52)
        self.viewLine.setWidth(globalWidth - 40)
        self.labelContent.setWidth(globalWidth - 40)
        self.imageHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageClick"))
        imageHolder.backgroundColor = IconColor
        self.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick"))
        self.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLikeClick"))
        self.btnMore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMoreClick"))
        self.btnLike.addTarget(self, action: "onLike", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnUnLike.addTarget(self, action: "onUnLike", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnLike.layer.borderColor = lineColor.CGColor
        self.btnMore.layer.borderColor = lineColor.CGColor
        self.btnUnLike.layer.borderColor = SeaColor.CGColor
        self.btnUnLike.backgroundColor = SeaColor
        viewLine.setHeightHalf()
    }
    
    override func layoutSubviews() {
//        super.layoutSubviews()
        if data != nil {
            let sid = self.data!.stringAttributeForKey("sid")
            let uid = self.data!.stringAttributeForKey("uid")
            let user = self.data!.stringAttributeForKey("user")
            var lastdate = self.data!.stringAttributeForKey("lastdate")
            let liked = self.data!.stringAttributeForKey("liked")
            let content = self.data!.stringAttributeForKey("content")
            let img = self.data!.stringAttributeForKey("image")
            let img0 = (self.data!.stringAttributeForKey("width") as NSString).floatValue
            let img1 = (self.data!.stringAttributeForKey("height") as NSString).floatValue
            var like = self.data!.stringAttributeForKey("likes")
            var comment = self.data!.stringAttributeForKey("comments")
            var heightCell = CGFloat((data!.stringAttributeForKey("heightContent") as NSString).floatValue)
            let title = self.data!.stringAttributeForKey("title")
            lastdate = V.relativeTime(lastdate)
            
            self.labelTime.text = lastdate
            self.imageHead.setHead(uid)
            
            logError("\(data)")
            
            self.labelLike.tag = Int(sid)!
            
            if content == "" {
                heightCell = 0
            }
            
            // setup label content , detect name && link
            self.labelContent.setHeight(heightCell)
            self.labelContent.text = content
            
            self.labelContent.userHandleLinkTapHandler = ({
                (label: KILabel, string: String, range: NSRange) in
                var _string = string
                _string.removeAtIndex(string.startIndex.advancedBy(0))
                self.findRootViewController()?.viewLoadingShow()
                Api.postUserNickName(_string) {
                    json in
                    if json != nil {
                        let error = json!.objectForKey("error") as! NSNumber
                        self.findRootViewController()?.viewLoadingHide()
                        if error == 0 {
                            if let uid = json!.objectForKey("data") as? String {
                                let UserVC = PlayerViewController()
                                UserVC.Id = uid
                                self.findRootViewController()?.navigationController?.pushViewController(UserVC, animated: true)
                            }
                        } else {
                            self.showTipText("没有人叫这个名字...", delay: 2)
                        }
                    }
                }
                
            })
            
            self.labelContent.urlLinkTapHandler = ({
                (label: KILabel, string: String, range: NSRange) in
                
                if !string.hasPrefix("http://") && !string.hasPrefix("https://") {
                    let urlString = "http://\(string)"
                    let web = WebViewController()
                    web.urlString = urlString
                    
                    self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
                } else {
                    let web = WebViewController()
                    web.urlString = string
                    
                    self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
                }
            })
            
            self.btnMore.tag = Int(sid)!
            
            if comment != "0" {
                comment = "回应 \(comment)"
            } else {
                comment = "回应"
            }
            
            if like == "0" {
                self.labelLike.hidden = true
            } else {
                self.labelLike.hidden = false
                like = "赞 \(like)"
                self.labelLike.text = like
                let widthLike = data!.objectForKey("widthLike") as! CGFloat
                self.labelLike.setWidth(widthLike)
            }
            
            self.labelComment.text = comment
            let commentWidth = data!.objectForKey("widthComment") as! CGFloat
            self.labelComment.setWidth(commentWidth)
            self.labelLike.setX(commentWidth+28)
            
            if img0 == 0.0 {
                if content == "" {  // 没有图片，没有文字
                    self.imageHolder.hidden = false
                    self.imageHolder.image = UIImage(named: "check")
                    self.imageHolder.frame.size = CGSizeMake(50, 23)
                    self.imageHolder.setX(20)
                } else {  // 没有图片，有文字
                    self.imageHolder.hidden = true
                    self.labelContent.setY(self.imageHead.bottom() + 20)
                }
            } else {
                let imgHeight = img1 * Float(globalWidth - 40) / img0
                let ImageURL = "http://img.nian.so/step/\(img)!large"
                self.imageHolder.setImage(ImageURL, placeHolder: IconColor, bool: false, ignore: false, animated: false)
                
                self.imageHolder.setHeight(CGFloat(imgHeight))
                self.imageHolder.setWidth(globalWidth - 40)
                self.imageHolder.hidden = false
                self.labelContent.setY(self.imageHolder.bottom()+20)
            }
            
            if content == "" {
                self.viewMenu.setY(self.imageHolder.bottom()+20)
            } else {
                self.viewMenu.setY(self.labelContent.bottom()+20)
            }
            self.viewLine.setY(self.viewMenu.bottom()+25)
            
            let cookieuid = SAUid()
            
            if cookieuid == uid {
                self.btnLike.hidden = true
                self.btnUnLike.hidden = true
                self.btnMore.setX(globalWidth - 52)
            } else {
                self.btnMore.setX(globalWidth - 52 - 32 - 8)
                if liked == "0" {
                    self.btnLike.hidden = false
                    self.btnUnLike.hidden = true
                } else {
                    self.btnLike.hidden = true
                    self.btnUnLike.hidden = false
                }
            }
            
            if !isDynamic {
                self.imageHead.setHead(uid)
                self.labelName.text = user
                if title == "" {
                    self.labelDream.text = lastdate
                    self.labelTime.hidden = true
                } else {
                    self.labelDream.text = title
                    self.labelTime.hidden = false
                }
            } else {
                let uidlike = data!.stringAttributeForKey("uidlike")
                let userlike = data!.stringAttributeForKey("userlike")
                self.imageHead.setHead(uidlike)
                self.labelName.text = userlike
                self.labelDream.text = "赞了「\(title)」"
            }
        }
    }
    
    func onLike() {
        if let like = Int(data!.stringAttributeForKey("likes")) {
            let num = "\(like + 1)"
            delegate?.updateStep(index, key: "likes", value: num)
            delegate?.updateStep(index, key: "liked", value: "1")
            delegate?.updateStep(index, key: "isEdit", value: "1")
            delegate?.updateStep()
            let sid = data!.stringAttributeForKey("sid")
            Api.postLike(sid, like: "1") { json in
            }
        }
    }
    
    // 停止滚动时加载图片
    func loadImage() {
        if imageHolder.image == nil {
            if data != nil {
                let img = data!.stringAttributeForKey("image")
                let ImageURL = "http://img.nian.so/step/\(img)!large"
                imageHolder.setImage(ImageURL, placeHolder: IconColor, bool: false, ignore: false, animated: true)
            }
        }
    }
    
    func onUnLike() {
        if let like = Int(data!.stringAttributeForKey("likes")) {
            let num = "\(like - 1)"
            delegate?.updateStep(index, key: "likes", value: num)
            delegate?.updateStep(index, key: "liked", value: "0")
            delegate?.updateStep()
            let sid = data!.stringAttributeForKey("sid")
            Api.postLike(sid, like: "0") { json in
            }
        }
    }
    
    func onMoreClick(){
        btnMore.setImage(nil, forState: UIControlState())
        let ac = UIActivityIndicatorView()
        ac.transform = CGAffineTransformMakeScale(0.7, 0.7)
        ac.color = UIColor.b3()
        viewMenu.addSubview(ac)
        ac.center = btnMore.center
        ac.startAnimating()
        go {
            let sid = self.data!.stringAttributeForKey("sid")
            let content = self.data!.stringAttributeForKey("content").decode()
            let uid = self.data!.stringAttributeForKey("uid")
            let url = NSURL(string: "http://nian.so/m/step/\(sid)")!
            let row = self.index
            
            // 分享的内容
            var arr = [content, url]
            let card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
            card.content = content
            card.widthImage = self.data!.stringAttributeForKey("width")
            card.heightImage = self.data!.stringAttributeForKey("height")
            card.url = "http://img.nian.so/step/" + self.data!.stringAttributeForKey("image") + "!large"
            arr.append(card.getCard())
            
            let customActivity = SAActivity()
            customActivity.saActivityTitle = "举报"
            customActivity.saActivityType = "举报"
            customActivity.saActivityImage = UIImage(named: "av_report")
            customActivity.saActivityFunction = {
                self.showTipText("举报好了！", delay: 2)
            }
            // 保存卡片
            let cardActivity = SAActivity()
            cardActivity.saActivityTitle = "保存卡片"
            cardActivity.saActivityType = "保存卡片"
            cardActivity.saActivityImage = UIImage(named: "card")
            cardActivity.saActivityFunction = {
                card.onCardSave()
                self.showTipText("保存好了！", delay: 2)
            }
            //编辑按钮
            let editActivity = SAActivity()
            editActivity.saActivityTitle = "编辑"
            editActivity.saActivityType = "编辑"
            editActivity.saActivityImage = UIImage(named: "av_edit")
            editActivity.saActivityFunction = {
                let addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
                addstepVC.isEdit = 1
                addstepVC.data = self.data
                addstepVC.row = row
                addstepVC.delegate = self
                self.findRootViewController()?.navigationController?.pushViewController(addstepVC, animated: true)
            }
            //删除按钮
            let deleteActivity = SAActivity()
            deleteActivity.saActivityTitle = "删除"
            deleteActivity.saActivityType = "删除"
            deleteActivity.saActivityImage = UIImage(named: "av_delete")
            deleteActivity.saActivityFunction = {
                self.actionSheetDelete = UIActionSheet(title: "再见了，进展 #\(sid)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                self.actionSheetDelete.addButtonWithTitle("确定")
                self.actionSheetDelete.addButtonWithTitle("取消")
                self.actionSheetDelete.cancelButtonIndex = 1
                self.actionSheetDelete.showInView((self.findRootViewController()?.view)!)
            }
            
            var ActivityArray = [customActivity, cardActivity]
            if uid == SAUid() {
                ActivityArray = [deleteActivity, editActivity, cardActivity]
            }
            self.activityViewController = SAActivityViewController.shareSheetInView(arr, applicationActivities: ActivityArray, isStep: true)
            
            // 禁用原来的保存图片
            self.activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]
            back {
                ac.removeFromSuperview()
                self.btnMore.setImage(UIImage(named: "btnmore"), forState: UIControlState())
                self.findRootViewController()?.presentViewController(self.activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == actionSheetDelete {
            if buttonIndex == 0 {
                delegate?.updateStep(index, delete: true)
                let sid = data!.stringAttributeForKey("sid")
                Api.postDeleteStep(sid) { string in
                }
            }
        }
    }
    
    func onImageClick() {
        let img = data!.stringAttributeForKey("image")
        self.imageHolder.showImage(V.urlStepImage(img, tag: .Large))
    }
    
    func onCommentClick() {
        let id = data!.stringAttributeForKey("dream")
        let sid = data!.stringAttributeForKey("sid")
        let uid = data!.stringAttributeForKey("uid")
        let dreamCommentVC = DreamCommentViewController()
        dreamCommentVC.dreamID = Int(id)!
        dreamCommentVC.stepID = Int(sid)!
        let safeuid = SAUid()
        dreamCommentVC.dreamowner = uid == safeuid ? 1 : 0
        self.findRootViewController()?.navigationController?.pushViewController(dreamCommentVC, animated: true)
    }
    
    func onLikeClick() {
        let sid = data!.stringAttributeForKey("sid")
        let LikeVC = LikeViewController()
        LikeVC.Id = sid
        self.findRootViewController()?.navigationController?.pushViewController(LikeVC, animated: true)
    }
    
    func onUserClick() {
        var uid = data!.stringAttributeForKey("uid")
        if isDynamic {
            uid = data!.stringAttributeForKey("uidlike")
        }
        let userVC = PlayerViewController()
        userVC.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(userVC, animated: true)
    }
    
    class func cellHeight(data: NSDictionary) -> NSArray {
        let content = data.stringAttributeForKey("content").decode()
        let img0 = (data.stringAttributeForKey("width") as NSString).floatValue
        let img1 = (data.stringAttributeForKey("height") as NSString).floatValue
        var comment = data.stringAttributeForKey("comments")
        comment = comment == "0" ? "回应" : "回应 \(comment)"
        var like = data.stringAttributeForKey("likes")
        like = like == "0" ? like : "赞 \(like)"
        let widthLike = like.stringWidthWith(13, height: 32) + 16
        let widthComment = comment.stringWidthWith(13, height: 32) + 16
        let height = content.stringHeightWith(16,width:globalWidth-40)
        var h: CGFloat = 0
        if (img0 == 0.0) {
            h = content == "" ? 155 + 23 : height + 155
        } else {
            let heightImage = CGFloat(img1 * Float(globalWidth - 40) / img0)
            h = content == "" ? 155 + heightImage : height + 175 + heightImage
        }
        return [h, height, widthComment, widthLike]
    }
    
    func countUp(coin: String, isfirst: String){
    }
    
    func Editstep() {
        let content = editStepData?.stringAttributeForKey("content")
        let img = editStepData?.stringAttributeForKey("image")
        let img0 = editStepData?.stringAttributeForKey("width")
        let img1 = editStepData?.stringAttributeForKey("height")
        delegate?.updateStep(index, key: "image", value: img!)
        delegate?.updateStep(index, key: "width", value: img0!)
        delegate?.updateStep(index, key: "height", value: img1!)
        delegate?.updateStep(index, key: "content", value: content!)
        delegate?.updateStep(index, key: "isEdit", value: "1")
        delegate?.updateStep(index)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageHolder.cancelImageRequestOperation()
        self.imageHolder.image = nil
        self.labelContent.text = nil
        self.imageHead.image = nil
        data = nil
    }
    
}

