//
//  RedditCell.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

protocol RedditDelegate {
    func updateData(index: Int, key: String, value: String)
    func updateTable()
}

class RedditCell: UITableViewCell {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewUp: UIImageView!
    @IBOutlet var viewDown: UIImageView!
    @IBOutlet var viewVoteLine: UIView!
    @IBOutlet var viewBottom: UIScrollView!
    @IBOutlet var labelTag: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelNum: UILabel!
    @IBOutlet var viewBottomLine: UIView!
    @IBOutlet var viewBottomDot: UIView!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    var delegate: RedditDelegate?
    var index: Int = 0
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelTitle.setWidth(globalWidth - 80)
        labelContent.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeight(0.5)
        viewBottomLine.setWidth(0.5)
        viewVoteLine.setHeight(0.5)
        labelTag.backgroundColor = SeaColor
        labelTag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hello"))
    }
    
    func hello() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let title = data.stringAttributeForKey("title").decode()
            let content = data.stringAttributeForKey("content").decode().toRedditReduce()
            let comment = SAThousand(data.stringAttributeForKey("answers_count"))
            let lastdate = data.stringAttributeForKey("created_at")
            let time = V.relativeTime(lastdate)
            let numLike = Int(data.stringAttributeForKey("like_count"))
            let numDislike = Int(data.stringAttributeForKey("dislike_count"))
            let num = numLike! - numDislike!
            let vote = data.stringAttributeForKey("vote")
            let tags = data.objectForKey("tags") as! Array<String>
            var tag: String?
            if tags.count > 0 {
                tag = "\(tags[0])"
            }
            
            // 计算高度与宽度
            let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            let hContent = content.stringHeightWith(12, width: globalWidth - 80)
            let hTitleMax = "\n".stringHeightWith(16, width: globalWidth - 80)
            let hContentMax = "\n\n\n".stringHeightWith(12, width: globalWidth - 80)
            let wTag = tag == nil ? 0 : tag?.stringWidthWith(10, height: 18)
            let wComment = "回应 \(comment)".stringWidthWith(12, height: 18)
            let wTime = time.stringWidthWith(12, height: 18)
            
            // 填充内容
            labelTitle.text = title
            labelContent.text = content
            labelComment.text = "回应 \(comment)"
            labelTime.text = time
            labelTag.text = tag
            labelNum.text = "\(num)"
            
            // 设定高度与宽度
            labelTitle.setHeight(min(hTitle, hTitleMax))
            labelContent.setHeight(min(hContent, hContentMax))
            labelContent.setY(labelTitle.bottom() + 16)
            viewBottom.setY(labelContent.bottom() + 16)
            labelTag.setWidth(wTag! + 16)
            viewBottomLine.setX(labelTag.right() + 12)
            labelComment.setWidth(wComment)
            labelTime.setWidth(wTime)
            viewLine.setY(viewBottom.bottom() + 24)
            
            // 不存在标签
            if tag == nil {
                labelTag.hidden = true
                viewBottomLine.hidden = true
                labelComment.setX(0)
            } else {
                labelTag.hidden = false
                viewBottomLine.hidden = false
                labelComment.setX(viewBottomLine.right() + 12)
            }
            viewBottomDot.setX(labelComment.right() + 8)
            labelTime.setX(viewBottomDot.right() + 8)
            
//            if 1 == 0 {
//                viewUp.layer.borderColor = SeaColor.CGColor
//                viewUp.backgroundColor = SeaColor
//                labelNum.textColor = UIColor.whiteColor()
//                viewVoteLine.backgroundColor = UIColor.whiteColor()
//                viewUp.image = UIImage(named: "voteupwhite")
//            } else {
                // 上按钮
                viewUp.layer.borderColor = UIColor.e6().CGColor
                viewUp.backgroundColor = UIColor.whiteColor()
                labelNum.textColor = UIColor.b3()
                viewVoteLine.backgroundColor = UIColor.e6()
                viewUp.image = UIImage(named: "voteup")
                // 下按钮
                viewDown.layer.borderColor = UIColor.e6().CGColor
                viewDown.backgroundColor = UIColor.whiteColor()
//            }
            
            if vote == "1" {
                setupVoteUp(true)
                setupVoteDown(false)
            } else if vote == "-1" {
                setupVoteUp(false)
                setupVoteDown(true)
            } else {
                setupVoteUp(false)
                setupVoteDown(false)
            }
            
            // 绑定动作
            viewUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUp"))
            viewDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDown"))
        }
    }
    
    func setupVoteUp(selected: Bool) {
        if selected {
            viewUp.layer.borderColor = SeaColor.CGColor
            viewUp.backgroundColor = SeaColor
            labelNum.textColor = UIColor.whiteColor()
            viewVoteLine.backgroundColor = UIColor.whiteColor()
            viewUp.image = UIImage(named: "voteupwhite")
        } else {
            viewUp.layer.borderColor = UIColor.e6().CGColor
            viewUp.backgroundColor = UIColor.whiteColor()
            labelNum.textColor = UIColor.b3()
            viewVoteLine.backgroundColor = UIColor.e6()
            viewUp.image = UIImage(named: "voteup")
        }
    }
    
    func setupVoteDown(selected: Bool) {
        if selected {
            viewDown.layer.borderColor = SeaColor.CGColor
            viewDown.backgroundColor = SeaColor
            viewDown.image = UIImage(named: "votedownwhite")
        } else {
            viewDown.layer.borderColor = UIColor.e6().CGColor
            viewDown.backgroundColor = UIColor.whiteColor()
            viewDown.image = UIImage(named: "votedown")
        }
    }
    
    func onUp() {
        let vote = data.stringAttributeForKey("vote")
        let numLike = Int(data.stringAttributeForKey("like_count"))
        let numDislike = Int(data.stringAttributeForKey("dislike_count"))
        if vote == "0" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! + 1)")
            delegate?.updateData(index, key: "vote", value: "1")
            voteUp()
        } else if vote == "-1" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! + 1)")
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! - 1)")
            delegate?.updateData(index, key: "vote", value: "1")
            voteUp()
        } else if vote == "1" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! - 1)")
            delegate?.updateData(index, key: "vote", value: "0")
            voteUpDelete()
        }
        delegate?.updateTable()
    }
    
    func onDown() {
        let vote = data.stringAttributeForKey("vote")
        let numLike = Int(data.stringAttributeForKey("like_count"))
        let numDislike = Int(data.stringAttributeForKey("dislike_count"))
        if vote == "0" {
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! + 1)")
            delegate?.updateData(index, key: "vote", value: "-1")
            voteDown()
        } else if vote == "1" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! - 1)")
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! + 1)")
            delegate?.updateData(index, key: "vote", value: "-1")
            voteDown()
        } else if vote == "-1" {
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! - 1)")
            delegate?.updateData(index, key: "vote", value: "0")
            voteDownDelete()
        }
        delegate?.updateTable()
    }
    
    func voteUp() {
        let id = data.stringAttributeForKey("id")
        Api.getVoteUp(id) { json in
        }
    }
    
    func voteDown() {
        let id = data.stringAttributeForKey("id")
        Api.getVoteDown(id) { json in
        }
    }
    
    func voteUpDelete() {
        let id = data.stringAttributeForKey("id")
        Api.getVoteUpDelete(id) { json in
        }
    }
    
    func voteDownDelete() {
        let id = data.stringAttributeForKey("id")
        Api.getVoteDownDelete(id) { json in
        }
    }
}

extension UIView {
    func setVote() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
    }
}