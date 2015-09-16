//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicCommentCellHeader: UITableViewCell {
    
    @IBOutlet var viewUp: UIImageView!
    @IBOutlet var viewDown: UIImageView!
    @IBOutlet var viewVoteLine: UIView!
    @IBOutlet var labelNum: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTime: UILabel!
    var data: NSDictionary!
    var arr: NSMutableArray?
    var delegateVote: RedditDelegate?
    
    override func awakeFromNib() {
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeight(0.5)
        viewVoteLine.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            layout(data)
            let time = data.stringAttributeForKey("created_at")
            let uid = data.stringAttributeForKey("user_id")
            labelName.text = data.stringAttributeForKey("username")
            labelTime.text = V.relativeTime(time)
            imageHead.setHead(uid)
            imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
            labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
        }
    }
    
    // 通过 data 来设置布局
    func layout(data: NSDictionary) {
        let content = data.stringAttributeForKey("content").decode()
        let numLike = Int(data.stringAttributeForKey("like_count"))
        let numDislike = Int(data.stringAttributeForKey("dislike_count"))
        let num = SAThousand("\(numLike! - numDislike!)")
        
        // 填充内容
        labelNum.text = num
        
        // 填充正文
        if arr == nil {
            arr = getRedditArray(content)
            var numBottom = labelTime.bottom() + 16
            for d in arr! {
                let data = d as! NSDictionary
                let type = data.stringAttributeForKey("type")
                if type == "text" {
                    let c = data.stringAttributeForKey("content")
                    let h = c.stringHeightWith(14, width: globalWidth - 80)
                    let label = UILabel(frame: CGRectMake(64, numBottom, globalWidth - 80, h))
                    label.text = c
                    label.numberOfLines = 0
                    label.textColor = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1)
                    label.font = UIFont.systemFontOfSize(14)
                    numBottom = numBottom + h + 16
                    self.addSubview(label)
                } else if type == "image" {
                    let w = CGFloat((data.stringAttributeForKey("width") as NSString).floatValue)
                    var h = CGFloat((data.stringAttributeForKey("height") as NSString).floatValue)
                    let count = data.stringAttributeForKey("count")
                    let url = data.stringAttributeForKey("url")
                    if w > 0 {
                        h = (globalWidth - 80) * h / w
                        let image = UIImageView(frame: CGRectMake(64, numBottom, globalWidth - 80, h))
                        image.setImage("http://img.nian.so/bbs/\(url)!large", placeHolder: IconColor)
                        image.userInteractionEnabled = true
                        image.tag = Int(count)!
                        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage:"))
                        numBottom = numBottom + h + 16
                        self.addSubview(image)
                    }
                } else if type == "dream" {
                    let id = data.stringAttributeForKey("id")
                    let b = numBottom
                    Api.getDream(id) { json in
                        if json != nil {
                            let d = json!.objectForKey("data") as! NSDictionary
                            let img = d.stringAttributeForKey("image")
                            let numSteps = d.stringAttributeForKey("steps_count")
                            let title = d.stringAttributeForKey("title").decode()
                            let v = (NSBundle.mainBundle().loadNibNamed("AddRedditDream", owner: self, options: nil) as NSArray).objectAtIndex(0) as! AddRedditDream
                            v.title = title
                            v.content = "\(numSteps) 进展"
                            v.image = "http://img.nian.so/dream/\(img)!dream"
                            v.frame = CGRectMake(64, b, 232, 64)
                            v.userInteractionEnabled = true
                            v.tag = Int(id)!
                            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDream:"))
                            self.addSubview(v)
                        }
                    }
                    numBottom = numBottom + 64 + 16
                }
            }
            
            // 设定高度与宽度
            viewLine.setY(numBottom + 8)
            delegateVote?.updateData(0, key: "heightCell", value: "\(viewLine.bottom())", section: 0)
            delegateVote?.updateTable()
        }
        setupVote()
    }
    
    // 点击记本
    func onDream(sender: UIGestureRecognizer) {
        let id = (sender.view?.tag)!
        let vc = DreamViewController()
        vc.Id = "\(id)"
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onImage(sender: UIGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let tag = imageView.tag
        if arr != nil {
            for d in arr! {
                let data = d as! NSDictionary
                let count = data.stringAttributeForKey("count")
                if count == "\(tag)" {
                    let url = data.stringAttributeForKey("url")
                    imageView.showImage("http://img.nian.so/bbs/\(url)!large")
                    break
                }
            }
        }
    }
    
    // 投票 - 绑定事件
    func setupVote() {
        Vote().setupVote(data!, viewUp: viewUp, viewDown: viewDown, viewVoteLine: viewVoteLine, labelNum: labelNum)
        viewUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUp"))
        viewDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDown"))
    }
    
    // 投票 - 赞
    func onUp() {
        Vote.onUp(data!, delegate: delegateVote, index: 0, section: 0)
    }
    
    // 投票 - 踩
    func onDown() {
        Vote.onDown(data!, delegate: delegateVote, index: 0, section: 0)
    }
    
    func onUser() {
        let uid = data.stringAttributeForKey("user_id")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}