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
    var isDynamic: Bool = false
    
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
        self.labelContent.setWidth(globalWidth-40)
        self.imageHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageClick"))
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
            img = self.data.stringAttributeForKey("image") as NSString as String
            img0 = (self.data.stringAttributeForKey("width") as NSString).floatValue
            img1 = (self.data.stringAttributeForKey("height") as NSString).floatValue
            var like = self.data.stringAttributeForKey("likes") as String
            var comment = self.data.stringAttributeForKey("comments")
            var title = SADecode(SADecode(self.data.stringAttributeForKey("title")))
            lastdate = V.relativeTime(lastdate)
            
            self.labelTime.text = lastdate
            self.imageHead.setHead(uid)
            self.labelLike.tag = sid.toInt()!
            var height = content.stringHeightWith(16,width:globalWidth-40)
            if content == "" {
                height = 0
            }
            
            // setup label content , detect name && link
            self.labelContent.setHeight(height)
            self.labelContent.text = content.decode()
            
            self.labelContent.userHandleLinkTapHandler = ({
                (label: KILabel, string: String, range: NSRange) in
                var _string = string
                _string.removeAtIndex(advance(string.startIndex, 0))
                
                var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                var _frame = self.superview?.superview?.frame
                spinner.frame.origin = CGPointMake(_frame!.width/2, _frame!.height/2)
                self.superview?.superview?.addSubview(spinner)
                
                spinner.startAnimating()
                
                Api.postUserNickName(_string) {
                    json in
                    if json != nil {
                        let error = json!["error"] as! NSNumber
                        spinner.stopAnimating()
                        
                        if error == 0 {
                            if let uid = json!["data"] as? String {
                                var UserVC = PlayerViewController()
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
                    var urlString = "http://\(string)"
                    var web = WebViewController()
                    web.urlString = urlString
                    
                    self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
                } else {
                    var web = WebViewController()
                    web.urlString = string
                    
                    self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
                }
            })
            
            
            
            self.btnMore.tag = sid.toInt()!
            if comment != "0" {
                comment = "\(comment) 回应"
            }else{
                comment = "回应"
            }
            if like == "0" {
                self.labelLike.hidden = true
            }else{
                self.labelLike.hidden = false
                like = "\(like) 赞"
                self.labelLike.text = like
                var likeWidth = like.stringWidthWith(13, height: 32) + 16
                likeWidth = SACeil(likeWidth, 0)
                self.labelLike.setWidth(likeWidth)
            }
            self.labelComment.text = comment
            var commentWidth = comment.stringWidthWith(13, height: 32) + 16
            commentWidth = SACeil(commentWidth, 0)
            self.labelComment.setWidth(commentWidth)
            self.labelLike.setX(commentWidth+28)
            if img0 == 0.0 {
                if content == "" {  // 没有图片，没有文字
                    self.imageHolder.hidden = false
                    self.imageHolder.image = UIImage(named: "check")
                    self.imageHolder.frame.size = CGSizeMake(50, 23)
                    self.imageHolder.setX(20)
                }else{  // 没有图片，有文字
                    self.imageHolder.hidden = true
                    imgHeight = 0
                    self.labelContent.setY(self.imageHead.bottom() + 20)
                }
            }else{
                imgHeight = img1 * Float(globalWidth - 40) / img0
                ImageURL = "http://img.nian.so/step/\(img)!large" as NSString as String
                largeImageURL = "http://img.nian.so/step/\(img)!large" as NSString as String
                self.imageHolder.setImage(ImageURL,placeHolder: IconColor)
                self.imageHolder.setHeight(CGFloat(imgHeight))
                self.imageHolder.setWidth(globalWidth - 40)
                self.imageHolder.hidden = false
                self.labelContent.setY(self.imageHolder.bottom()+20)
            }
            if content == "" {
                self.viewMenu.setY(self.imageHolder.bottom()+20)
            }else{
                self.viewMenu.setY(self.labelContent.bottom()+20)
            }
            self.viewLine.setY(self.viewMenu.bottom()+25)
            
            //主人
            var cookieuid: String = NSUserDefaults.standardUserDefaults().objectForKey("uid") as! String
            if cookieuid == uid {
                self.btnLike.hidden = true
                self.btnUnLike.hidden = true
                self.btnMore.setX(globalWidth - 52)
            }else{
                self.btnMore.setX(globalWidth - 52 - 32 - 8)
                if liked == "0" {
                    self.btnLike.hidden = false
                    self.btnUnLike.hidden = true
                }else{
                    self.btnLike.hidden = true
                    self.btnUnLike.hidden = false
                }
            }
            //==
            
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
                var uidlike = data.stringAttributeForKey("uidlike")
                var userlike = data.stringAttributeForKey("userlike")
                self.imageHead.setHead(uidlike)
                self.labelName.text = userlike
                self.labelDream.text = "赞了「\(title)」"
            }
            
            //==
            
            
        }
    }
    
    func onLike() {
        if let like = data.stringAttributeForKey("likes").toInt() {
            var num = "\(like + 1)"
            delegate?.updateStep(index, key: "likes", value: num)
            delegate?.updateStep(index, key: "liked", value: "1")
            delegate?.updateStep()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "1") { json in
            }
        }
    }
    
    func onUnLike() {
        if let like = data.stringAttributeForKey("likes").toInt() {
            var num = "\(like - 1)"
            delegate?.updateStep(index, key: "likes", value: num)
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
        customActivity.saActivityType = "举报"
        customActivity.saActivityImage = UIImage(named: "av_report")
        customActivity.saActivityFunction = {
            self.showTipText("举报好了！", delay: 2)
        }
        //编辑按钮
        var editActivity = SAActivity()
        editActivity.saActivityTitle = "编辑"
        editActivity.saActivityType = "编辑"
        editActivity.saActivityImage = UIImage(named: "av_edit")
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
        deleteActivity.saActivityImage = UIImage(named: "av_delete")
        deleteActivity.saActivityFunction = {
            self.actionSheetDelete = UIActionSheet(title: "再见了，进展 #\(sid)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheetDelete.addButtonWithTitle("确定")
            self.actionSheetDelete.addButtonWithTitle("取消")
            self.actionSheetDelete.cancelButtonIndex = 1
            self.actionSheetDelete.showInView(self.findRootViewController()?.view)
        }
        
        var ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), customActivity ]
        if uid == SAUid() {
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
        var img = data.stringAttributeForKey("image")
        var width = CGFloat((data.stringAttributeForKey("width") as NSString).floatValue)
        var height = CGFloat((data.stringAttributeForKey("height") as NSString).floatValue)
        var point = self.imageHolder.getPoint()
        if width * height != 0 {
            height = height * (globalWidth - 40) / width
            var rect = CGRectMake(-point.x, -point.y, globalWidth - 40, height)
            self.imageHolder.showImage(V.urlStepImage(img, tag: .Large), rect: rect)
        }
    }
    
    func onCommentClick() {
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
        if isDynamic {
            uid = data.stringAttributeForKey("uidlike")
        }
        var userVC = PlayerViewController()
        userVC.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(userVC, animated: true)
    }
    
    class func cellHeightByData(data: NSDictionary)->CGFloat {
        var content = SADecode(data.stringAttributeForKey("content"))
        var img0 = (data.stringAttributeForKey("width") as NSString).floatValue
        var img1 = (data.stringAttributeForKey("height") as NSString).floatValue
        var height = content.stringHeightWith(16,width:globalWidth-40)
        if (img0 == 0.0) {
            var h = content == "" ? 155 + 23 : height + 155
            return h
        } else {
            var heightImage = CGFloat(img1 * Float(globalWidth - 40) / img0)
            var h = content == "" ? 155 + heightImage : height + 175 + heightImage
            return h
        }
    }
    
    func countUp(coin: String, isfirst: String){
    }
    
    func Editstep() {
        var content = editStepData?.stringAttributeForKey("content")
        var img = editStepData?.stringAttributeForKey("image")
        var img0 = editStepData?.stringAttributeForKey("width")
        var img1 = editStepData?.stringAttributeForKey("height")
        delegate?.updateStep(index, key: "image", value: img!)
        delegate?.updateStep(index, key: "width", value: img0!)
        delegate?.updateStep(index, key: "height", value: img1!)
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
