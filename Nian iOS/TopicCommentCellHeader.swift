//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicCommentCellHeader: UITableViewCell {
    
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewUp: UIImageView!
    @IBOutlet var viewDown: UIImageView!
    @IBOutlet var viewVoteLine: UIView!
    @IBOutlet var labelNum: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTime: UILabel!
    var data: NSDictionary!
    var index: Int = 0
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelContent.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeight(0.5)
        viewVoteLine.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let content = data.stringAttributeForKey("content").decode()
            let uid = data.stringAttributeForKey("uid")
            let name = data.stringAttributeForKey("user")
            let lastdate = data.stringAttributeForKey("lastdate")
            let time = V.relativeTime(lastdate)
            var comment = "12"
            comment = "回应 \(comment)"
            //            let num = SAThousand(data.stringAttributeForKey("reply"))
            let num = "32"
            
            // 计算高度与宽度
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            let hComment = comment.stringWidthWith(13, height: 32) + 16
            
            // 填充内容
            labelContent.text = content
            labelNum.text = num
            labelTime.text = time
            imageHead.setHead(uid)
            labelName.text = name
            labelNum.text = num
            
            // 设定高度与宽度
            labelContent.setHeight(hContent)
            viewLine.setY(labelContent.bottom() + 24)
            
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
        }
    }
    
    func onComment() {
        let vc = TopicComment()
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onUser() {
        let uid = data.stringAttributeForKey("uid")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}