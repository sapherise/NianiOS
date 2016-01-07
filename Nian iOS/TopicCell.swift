//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
protocol RedditDeleteDelegate {
    func onDelete(index: Int)
}
class TopicCell: UITableViewCell, UIActionSheetDelegate {
    
    @IBOutlet var labelContent: KILabel!
    @IBOutlet var viewUp: UIImageView!
    @IBOutlet var viewDown: UIImageView!
    @IBOutlet var viewVoteLine: UIView!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var labelNum: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var btnMore: UIButton!
    
    var ac = UIActionSheet()
    var deleteSheet = UIActionSheet()
    
    var data: NSDictionary!
    var index: Int = 0
    var delegate: RedditDelegate?
    var delegateDelete: RedditDeleteDelegate?
    var indexVote: Int = 0
    
    var topicId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelContent.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeightHalf()
        viewVoteLine.setHeightHalf()
        btnMore.setX(globalWidth - 80 - 35)
        btnMore.layer.borderColor = lineColor.CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let content = data.stringAttributeForKey("content").decode().toRedditReduce()
            let uid = data.stringAttributeForKey("user_id")
            let name = data.stringAttributeForKey("username")
            let lastdate = data.stringAttributeForKey("created_at")
            let time = V.relativeTime(lastdate)
            var comment = data.stringAttributeForKey("comments_count")
            if comment == "0" {
                comment = "回应"
            } else {
                comment = "回应 \(comment)"
            }
            let numLike = Int(data.stringAttributeForKey("like_count"))
            let numDislike = Int(data.stringAttributeForKey("dislike_count"))
            let num = SAThousand("\(numLike! - numDislike!)")
            
            // 计算高度与宽度
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            let hContentMax = "\n\n\n".stringHeightWith(14, width: globalWidth - 80)
            let hComment = comment.stringWidthWith(13, height: 32) + 16
            
            // 填充内容
            labelContent.text = content
            labelNum.text = num
            labelTime.text = time
            imageHead.setHead(uid)
            labelName.text = name
            labelNum.text = num
            labelComment.text = comment
            
            // 设定高度与宽度
            labelContent.setHeight(min(hContent, hContentMax))
            viewBottom.setY(labelContent.bottom() + 16)
            viewLine.setY(viewBottom.bottom() + 24)
            labelComment.setWidth(hComment)
            
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
                            self.findRootViewController()!.showTipText("没有人叫这个名字...")
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
            
            // 上按钮
            viewUp.layer.borderColor = UIColor.e6().CGColor
            viewUp.backgroundColor = UIColor.whiteColor()
            labelNum.textColor = UIColor.b3()
            viewVoteLine.backgroundColor = UIColor.e6()
            viewUp.image = UIImage(named: "voteup")
            
            // 下按钮
            viewDown.layer.borderColor = UIColor.e6().CGColor
            viewDown.backgroundColor = UIColor.whiteColor()
            
            // 绑定事件
            imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
            labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
            btnMore.addTarget(self, action: "onMore:", forControlEvents: .TouchUpInside)
            
            setupVote()
        }
    }
    
    func onMore(sender: UIButton) {
        ac.delegate = self
        let userA = data.stringAttributeForKey("user_id")
        let userMe = SAUid()
        var arr = ["举报"]
        if userA == userMe {
            arr = ["删除", "举报"]
        }
        for a in arr {
            ac.addButtonWithTitle(a)
        }
        ac.addButtonWithTitle("取消")
        ac.cancelButtonIndex = arr.count
        ac.showInView((self.findRootViewController()?.view)!)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == ac {
            let userA = data.stringAttributeForKey("user_id")
            let userMe = SAUid()
            if userA == userMe {
                if buttonIndex == 0 {
                    let id = data.stringAttributeForKey("id")
                    self.deleteSheet = UIActionSheet(title: "再见了，回复 #\(id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    self.deleteSheet.addButtonWithTitle("确定")
                    self.deleteSheet.addButtonWithTitle("取消")
                    self.deleteSheet.cancelButtonIndex = 1
                    self.deleteSheet.showInView((self.findRootViewController()?.view)!)
                } else if buttonIndex == 1 {
                    onReport()
                }
            } else {
                if buttonIndex == 0 {
                    onReport()
                }
            }
        } else if actionSheet == deleteSheet {
            if buttonIndex == 0 {
                onDelete()
            }
        }
    }
    
    func onReport() {
        self.findRootViewController()!.showTipText("举报好了！")
    }
    
    func onDelete() {
        delegateDelete?.onDelete(indexVote)
    }
    
    // 投票 - 绑定事件
    func setupVote() {
        Vote().setupVote(data, viewUp: viewUp, viewDown: viewDown, viewVoteLine: viewVoteLine, labelNum: labelNum)
        viewUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUp"))
        viewDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDown"))
    }
    
    // 投票 - 赞
    func onUp() {
        Vote.onUp(data, delegate: delegate, index: indexVote, section: 1)
    }
    
    // 投票 - 踩
    func onDown() {
        Vote.onDown(data, delegate: delegate, index: indexVote, section: 1)
    }
    
    func onUser() {
        let uid = data.stringAttributeForKey("user_id")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}