//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

protocol TopicDelegate {
    func changeTopic(index: Int)
    func updateData(index: Int, key: String, value: String)
}

class TopicCellHeader: UITableViewCell, NSLayoutManagerDelegate {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UITextView!
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
    @IBOutlet var scrollView: UIScrollView!
    var data: NSMutableDictionary!
    var delegate: TopicDelegate?
    var index: Int = 0
    var isLayoutSubviews: Bool = false
    var delegateVote: RedditDelegate?
    var indexVote: Int = 0
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelTitle.setWidth(globalWidth - 80)
        labelContent.setWidth(globalWidth - 80 + 8)
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
        scrollView.setTag()
        labelNew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onNew"))
        labelHot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHot"))
        labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onComment"))
        labelContent.layoutManager.delegate = self
    }
    
    func onNew() {
        delegate?.changeTopic(1)
    }
    
    func onHot() {
        delegate?.changeTopic(0)
    }
    
    func onComment() {
        let vc = AddTopic()
        vc.type = 1
        vc.id = data.stringAttributeForKey("id")
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            print("哈哈")
            let title = data.stringAttributeForKey("title").decode()
            let content = data.stringAttributeForKey("content").decode()
            let comment = data.stringAttributeForKey("answers_count")
            let numLike = Int(data.stringAttributeForKey("like_count"))
            let numDislike = Int(data.stringAttributeForKey("dislike_count"))
            let num = SAThousand("\(numLike! - numDislike!)")
            
            // 计算高度与宽度
            let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            let tags = data.objectForKey("tags") as! Array<String>
            
            // 填充内容
            labelTitle.text = title
            labelNum.text = num
            labelContent.attributedText = content.toRedditDecode()
            labelTotal.text = "\(comment) 条回应"
            
            // 设定高度与宽度
            labelTitle.setHeight(hTitle)
//            labelContent.setHeight(hContent)
            
            
            let hFits = labelContent.sizeThatFits(CGSizeMake(labelContent.bounds.width, 10000)).height
            labelContent.setHeight(hFits)
            
            
            labelContent.setY(labelTitle.bottom() + 16 - 4)
            labelComment.setY(labelContent.bottom() + 24)
            viewBottom.setY(labelComment.bottom() + 24)
            
            var x: CGFloat = 11
            for tag in tags {
                let t = tag.decode()
                let label = UILabel()
                label.setTagLabel(t)
                label.setX(x)
                scrollView.addSubview(label)
                x = x + label.width() + 8
            }
            scrollView.contentSize = CGSizeMake(x + 3, scrollView.frame.height)
            
            // 导航菜单
            if index == 0 {
                labelHot.layer.borderWidth = 0.5
                labelHot.layer.borderColor = lineColor.CGColor
                viewLineClick.setX(labelHot.x() + 0.5)
                labelNew.layer.borderWidth = 0
                labelHot.textColor = UIColor.C33()
                labelNew.textColor = UIColor.b3()
            } else {
                labelNew.layer.borderWidth = 0.5
                labelNew.layer.borderColor = lineColor.CGColor
                viewLineClick.setX(labelNew.x() + 0.5)
                labelHot.layer.borderWidth = 0
                labelNew.textColor = UIColor.C33()
                labelHot.textColor = UIColor.b3()
            }
            
            setupVote()
            delegate?.updateData(index, key: "heightCell", value: "\(viewBottom.bottom())")
        }
    }
    
    // 投票 - 绑定事件
    func setupVote() {
        Vote().setupVote(data, viewUp: viewUp, viewDown: viewDown, viewVoteLine: viewVoteLine, labelNum: labelNum)
        viewUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUp"))
        viewDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDown"))
    }
    
    // 投票 - 赞
    func onUp() {
        Vote.onUp(data, delegate: delegateVote, index: indexVote)
    }
    
    // 投票 - 踩
    func onDown() {
        Vote.onDown(data, delegate: delegateVote, index: indexVote)
    }
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 4
    }
}