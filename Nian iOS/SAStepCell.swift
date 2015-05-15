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
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var labelLike: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var viewLine: UIView!
    var actionSheetDelete: UIActionSheet!
    var largeImageURL:String = ""
    var data :NSDictionary!
    var imgHeight:Float = 0.0
    var content:String = ""
    var img:String = ""
    var img0:Float = 0.0
    var img1:Float = 0.0
    var ImageURL:String = ""
    var indexPathRow:Int = 0
    var sid:Int = 0
    var delegate: delegateSAStepCell?
    var index: Int = 0
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    var activityViewController: UIActivityViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.viewMenu.setWidth(globalWidth)
        self.setWidth(globalWidth)
        self.labelTime.setX(globalWidth - 92 - 15)
        self.btnMore.setX(globalWidth - 50)
        self.btnLike.setX(globalWidth - 50)
        self.btnUnLike.setX(globalWidth - 50)
        self.viewLine.setWidth(globalWidth)
        self.labelContent.setWidth(globalWidth-30)
        self.imageHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageClick"))
        self.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick"))
        self.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLikeClick"))
        self.btnMore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMoreClick"))
        self.btnLike.addTarget(self, action: "onLike", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnUnLike.addTarget(self, action: "onUnLike", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var sid = self.data.stringAttributeForKey("sid")
        if sid.toInt() != nil {
            self.sid = sid.toInt()!
            var uid = self.data.stringAttributeForKey("uid")
            var user = self.data.stringAttributeForKey("user")
            var lastdate = self.data.stringAttributeForKey("lastdate")
            var liked = self.data.stringAttributeForKey("liked")
            content = SADecode(self.data.stringAttributeForKey("content"))
            img = self.data.stringAttributeForKey("img") as NSString as String
            img0 = (self.data.stringAttributeForKey("img0") as NSString).floatValue
            img1 = (self.data.stringAttributeForKey("img1") as NSString).floatValue
            var like = self.data.stringAttributeForKey("like") as String
            var comment = self.data.stringAttributeForKey("comment")
            var dreamtitle = SADecode(self.data.stringAttributeForKey("dreamtitle"))
            var dream = SADecode(self.data.stringAttributeForKey("title"))
            var time = (data.stringAttributeForKey("lastdate") as NSString).doubleValue
            var absoluteTime = V.absoluteTime(time)
            
            self.labelName.text = user
            self.labelTime.text = absoluteTime
            self.labelDream.text = (count(dreamtitle) != 0) ? dreamtitle : dream
            self.imageHead.setHead(uid)
            self.imageHead.tag = uid.toInt()!
            self.labelName.tag = uid.toInt()!
            self.labelLike.tag = sid.toInt()!
            var height = content.stringHeightWith(16,width:globalWidth-30)
            if content == "" {
                height = 0
            }
            self.labelContent.setHeight(height)
            self.labelContent.text = SADecode(content)
            self.btnMore.tag = sid.toInt()!
            if comment != "0" {
                comment = "\(comment) 评论"
            }else{
                comment = "评论"
            }
            if like == "0" {
                self.labelLike.hidden = true
            }else{
                self.labelLike.hidden = false
                like = "\(like) 赞"
                self.labelLike.text = like
                var likeWidth = like.stringWidthWith(13, height: 30) + 17
                self.labelLike.setWidth(likeWidth)
            }
            self.labelComment.text = comment
            var commentWidth = comment.stringWidthWith(13, height: 30) + 17
            self.labelComment.setWidth(commentWidth)
            self.labelLike.setX(commentWidth+23)
            if img0 == 0.0 {
                if content == "" {  // 没有图片，没有文字
                    self.imageHolder.hidden = false
                    self.imageHolder.image = UIImage(named: "check")
                    self.imageHolder.frame.size = CGSizeMake(50, 23)
                    self.imageHolder.setX(15)
                }else{  // 没有图片，有文字
                    self.imageHolder.hidden = true
                    imgHeight = 0
                    self.labelContent.setY(70)
                }
            }else{
                imgHeight = img1 * Float(globalWidth) / img0
                ImageURL = "http://img.nian.so/step/\(img)!large" as NSString as String
                largeImageURL = "http://img.nian.so/step/\(img)!large" as NSString as String
                self.imageHolder.setImage(ImageURL,placeHolder: IconColor)
                self.imageHolder.setHeight(CGFloat(imgHeight))
                self.imageHolder.setWidth(globalWidth)
                self.imageHolder.hidden = false
                self.labelContent.setY(self.imageHolder.bottom()+15)
            }
            if content == "" {
                self.viewMenu.setY(self.imageHolder.bottom()+5)
            }else{
                self.viewMenu.setY(self.labelContent.bottom()+5)
            }
            self.viewLine.setY(self.viewMenu.bottom()+10)
            
            //主人
            var cookieuid: String = NSUserDefaults.standardUserDefaults().objectForKey("uid") as! String
            if cookieuid == uid {
                self.btnLike.hidden = true
                self.btnUnLike.hidden = true
                self.btnMore.setX(globalWidth - 50)
            }else{
                self.btnMore.setX(globalWidth - 90)
                if liked == "0" {
                    self.btnLike.hidden = false
                    self.btnUnLike.hidden = true
                }else{
                    self.btnLike.hidden = true
                    self.btnUnLike.hidden = false
                }
            }
        }
    }
    
    func onLike() {
        if let like = data.stringAttributeForKey("like").toInt() {
            var num = "\(like + 1)"
            delegate?.updateStep(index, key: "like", value: num)
            delegate?.updateStep(index, key: "liked", value: "1")
            delegate?.updateStep()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "1") { json in
            }
        }
    }
    
    func onUnLike() {
        if let like = data.stringAttributeForKey("like").toInt() {
            var num = "\(like - 1)"
            delegate?.updateStep(index, key: "like", value: num)
            delegate?.updateStep(index, key: "liked", value: "0")
            delegate?.updateStep()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "0") { json in
            }
        }
    }
    
    func onMoreClick(){
        var sid = data.stringAttributeForKey("sid")
        var content = SADecode(data.stringAttributeForKey("content"))
        var uid = data.stringAttributeForKey("uid")
        var url = NSURL(string: "http://nian.so/m/step/\(sid)")!
        var row = index
        
        var customActivity = SAActivity()
        customActivity.saActivityTitle = "举报"
        customActivity.saActivityImage = UIImage(named: "flag")!
        customActivity.saActivityFunction = {
            UIView.showAlertView("谢谢", message: "如果这个进展不合适，我们会将其移除。")
        }
        //编辑按钮
        var editActivity = SAActivity()
        editActivity.saActivityTitle = "编辑"
        editActivity.saActivityType = "编辑"
        editActivity.saActivityImage = UIImage(named: "edit")!
        editActivity.saActivityFunction = {
            var addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
            addstepVC.isEdit = 1
            addstepVC.data = self.data
            addstepVC.row = row
            addstepVC.delegate = self
            self.findRootViewController()?.navigationController?.pushViewController(addstepVC, animated: true)
        }
        //删除按钮
        var deleteActivity = SAActivity()
        deleteActivity.saActivityTitle = "删除"
        deleteActivity.saActivityType = "删除"
        deleteActivity.saActivityImage = UIImage(named: "goodbye")!
        deleteActivity.saActivityFunction = {
            self.actionSheetDelete = UIActionSheet(title: "再见了，进展 #\(sid)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheetDelete.addButtonWithTitle("确定")
            self.actionSheetDelete.addButtonWithTitle("取消")
            self.actionSheetDelete.cancelButtonIndex = 1
            self.actionSheetDelete.showInView(self.findRootViewController()?.view)
        }
        
        var ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), customActivity ]
        if uid == getuid() {
            ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), deleteActivity, editActivity]
        }
        var arr = [content, url]
        if img0 * img1 != 0 {
            var image = getCacheImage(ImageURL)
            if image != nil {
                arr.append(image!)
            }
        }
        self.activityViewController = UIActivityViewController(
            activityItems: arr,
            applicationActivities: ActivityArray)
        self.activityViewController?.excludedActivityTypes = [
            UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
        ]
        if let v = self.findRootViewController()?.navigationController {
            v.presentViewController(self.activityViewController, animated: true, completion: nil)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == actionSheetDelete {
            if buttonIndex == 0 {
                delegate?.updateStep(index, delete: true)
                var sid = data.stringAttributeForKey("sid")
                Api.postDeleteStep(sid) { string in
                }
            }
        }
    }
    
    func onImageClick() {
        var img = data.stringAttributeForKey("img")
        var width = CGFloat((data.stringAttributeForKey("img0") as NSString).floatValue)
        var height = CGFloat((data.stringAttributeForKey("img1") as NSString).floatValue)
        var point = self.imageHolder.getPoint()
        if width * height != 0 {
            height = height * globalWidth / width
            var rect = CGRectMake(-point.x, -point.y, globalWidth, height)
            self.imageHolder.showImage(V.urlStepImage(img, tag: .Large), rect: rect)
        }
    }
    
    func onCommentClick() {
        println(data)
        var id = data.stringAttributeForKey("dream")
        var sid = data.stringAttributeForKey("sid")
        var uid = data.stringAttributeForKey("uid")
        var dreamCommentVC = DreamCommentViewController()
        dreamCommentVC.dreamID = id.toInt()!
        dreamCommentVC.stepID = sid.toInt()!
        var UserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = UserDefaults.objectForKey("uid") as! String
        dreamCommentVC.dreamowner = uid == safeuid ? 1 : 0
        self.findRootViewController()?.navigationController?.pushViewController(dreamCommentVC, animated: true)
    }
    
    func onLikeClick() {
        var sid = data.stringAttributeForKey("sid")
        var LikeVC = LikeViewController()
        LikeVC.Id = sid
        self.findRootViewController()?.navigationController?.pushViewController(LikeVC, animated: true)
    }
    
    func onUserClick() {
        var uid = data.stringAttributeForKey("uid")
        var userVC = PlayerViewController()
        userVC.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(userVC, animated: true)
    }
    
    class func cellHeightByData(data: NSDictionary)->CGFloat {
        var content = SADecode(data.stringAttributeForKey("content"))
        var img0 = (data.stringAttributeForKey("img0") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("img1") as NSString).floatValue
        var height = content.stringHeightWith(16,width:globalWidth-30)
        if (img0 == 0.0) {
            var h = content == "" ? 179 : height + 151
            return h
        } else {
            var heightImage = CGFloat(img1 * Float(globalWidth) / img0)
            var h = content == "" ? 156 + heightImage : height + 171 + heightImage
            return h
        }
    }
    
    func countUp(coin: String, isfirst: String){
    }
    
    func Editstep() {
        var content = editStepData?.stringAttributeForKey("content")
        var img = editStepData?.stringAttributeForKey("img")
        var img0 = editStepData?.stringAttributeForKey("img0")
        var img1 = editStepData?.stringAttributeForKey("img1")
        delegate?.updateStep(index, key: "img", value: img!)
        delegate?.updateStep(index, key: "img0", value: img0!)
        delegate?.updateStep(index, key: "img1", value: img1!)
        delegate?.updateStep(index, key: "content", value: content!)
        delegate?.updateStep(index)
    }
}

extension UIImageView {
    func getPoint() -> CGPoint {
        var y = self.convertPoint(CGPointZero, fromView: self.window)
        return y
    }
}
