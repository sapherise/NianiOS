//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicCellHeader: UITableViewCell {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewUp: UIImageView!
    @IBOutlet var viewDown: UIImageView!
    @IBOutlet var viewVoteLine: UIView!
    @IBOutlet var labelNum: UILabel!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var labelTotal: UILabel!
    @IBOutlet var labelHot: UILabel!
    @IBOutlet var labelNew: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewLineClick: UIView!
    var data: NSDictionary!
    var index: Int = 0
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelTitle.setWidth(globalWidth - 80)
        labelContent.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 32)
        viewVoteLine.setHeight(0.5)
        labelComment.backgroundColor = SeaColor
        labelHot.setX(globalWidth - 32 - 48 * 2 - 1)
        labelNew.setX(globalWidth - 32 - 48)
        labelHot.layer.borderWidth = 0.5
        labelHot.layer.borderColor = lineColor.CGColor
        viewLine.setWidth(globalWidth - 32)
        viewLine.setHeight(0.5)
        viewLine.setY(31.5)
        viewLineClick.frame = CGRectMake(labelHot.x() + 0.5, 31.5, 47, 0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let title = data.stringAttributeForKey("title").decode()
            let content = data.stringAttributeForKey("content").decode()
            let comment = data.stringAttributeForKey("reply")
            let num = SAThousand(data.stringAttributeForKey("reply"))
            
            // 计算高度与宽度
            let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            
            // 填充内容
            labelTitle.text = title
            labelContent.text = content
            labelNum.text = num
            labelTotal.text = "\(comment) 条回应"
            
            // 设定高度与宽度
            labelTitle.setHeight(hTitle)
            labelContent.setHeight(hContent)
            labelContent.setY(labelTitle.bottom() + 16)
            labelComment.setY(labelContent.bottom() + 24)
            viewBottom.setY(labelComment.bottom() + 24)
            
            // 上按钮
            viewUp.layer.borderColor = UIColor.e6().CGColor
            viewUp.backgroundColor = UIColor.whiteColor()
            labelNum.textColor = UIColor.b3()
            viewVoteLine.backgroundColor = UIColor.e6()
            viewUp.image = UIImage(named: "voteup")
            // 下按钮
            viewDown.layer.borderColor = UIColor.e6().CGColor
            viewDown.backgroundColor = UIColor.whiteColor()
        }
    }
}