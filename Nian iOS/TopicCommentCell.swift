//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicCommentCell: UITableViewCell {
    
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTime: UILabel!
    var data: NSDictionary!
    var index: Int = 0
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        labelContent.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let content = data.stringAttributeForKey("content").decode()
            let uid = data.stringAttributeForKey("user_id")
            let name = data.stringAttributeForKey("username")
            let lastdate = data.stringAttributeForKey("created_at")
            var time = V.relativeTime(lastdate)
            if lastdate == "-1" {
                time = "发送中..."
            }
            var comment = "12"
            comment = "回应 \(comment)"
            
            // 计算高度与宽度
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            
            // 填充内容
            labelContent.text = content
            labelTime.text = time
            imageHead.setHead(uid)
            labelName.text = name
            viewLine.setY(labelContent.bottom() + 24)
            
            // 设定高度与宽度
            labelContent.setHeight(hContent)
            
            // 绑定事件
            imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
            labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
        }
    }
    
    func onUser() {
        let uid = data.stringAttributeForKey("user_id")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}