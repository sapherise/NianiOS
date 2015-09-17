//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicCell: UITableViewCell, UIActionSheetDelegate {
    
    @IBOutlet var labelContent: UILabel!
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
    var data: NSDictionary!
    var index: Int = 0
    var delegate: RedditDelegate?
    var indexVote: Int = 0
    
    var topicId: String = ""
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelContent.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeight(0.5)
        viewVoteLine.setHeight(0.5)
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
            var comment = "12"
            comment = "回应 \(comment)"
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
        let ac = UIActionSheet()
        ac.delegate = self
        let userA = data.stringAttributeForKey("user_id")
        let userMe = SAUid()
        var arr = ["标记为不合适"]
        if userA == userMe {
            arr = ["删除", "标记为不合适"]
        }
        for a in arr {
            ac.addButtonWithTitle(a)
        }
        ac.addButtonWithTitle("取消")
        ac.cancelButtonIndex = arr.count
        ac.showInView((self.findRootViewController()?.view)!)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let userA = data.stringAttributeForKey("user_id")
        let userMe = SAUid()
        if userA == userMe {
            if buttonIndex == 0 {
                onDelete()
            } else if buttonIndex == 1 {
                onReport()
            }
        } else {
            if buttonIndex == 0 {
                onReport()
            }
        }
    }
    
    func onReport() {
        self.viewLine.showTipText("举报好了！", delay: 2)
    }
    
    func onDelete() {
        // todo: 需要接入删除的 API
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