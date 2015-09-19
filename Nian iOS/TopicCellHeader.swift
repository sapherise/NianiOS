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
    func updateData(index: Int, key: String, value: String, section: Int)
}

protocol RedditTopDelegate {
    func updateDic(data: NSMutableDictionary)
}

class TopicCellHeader: UITableViewCell, getCommentDelegate {
    
    @IBOutlet var labelTitle: UILabel!
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
    @IBOutlet var viewHolder: UIView!
    var data: NSMutableDictionary?
    var delegate: TopicDelegate?
    var index: Int = 0
    var delegateVote: RedditDelegate?
    var delegateComment: getCommentDelegate?
    var delegateTop: RedditTopDelegate?
    var indexVote: Int = 0
    var arr: NSMutableArray?
    var url: String = ""
    var id: String = ""
    
    override func awakeFromNib() {
        self.selectionStyle = .None
//        self.setWidth(globalWidth)
        viewUp.setVote()
        viewDown.setVote()
        labelTitle.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 32)
        viewVoteLine.setHeightHalf()
        labelComment.backgroundColor = SeaColor
        labelHot.setX(globalWidth - 32 - 48 * 2 - 1)
        labelNew.setX(globalWidth - 32 - 48)
        labelHot.layer.borderWidth = 0.5
        labelHot.layer.borderColor = lineColor.CGColor
        viewLine.setWidth(globalWidth - 32)
        viewLine.setHeightHalf()
        viewLine.setY(31.5)
        viewLineClick.frame = CGRectMake(labelHot.x() + 0.5, 31.5, 47, 0.5)
        labelNew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onNew"))
        labelHot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHot"))
        labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onComment"))
        viewHolder.setWidth(globalWidth)
    }
    
    func onNew() {
        delegate?.changeTopic(1)
    }
    
    func onHot() {
        delegate?.changeTopic(0)
    }
    
    func getComment(content: String) {
        delegateComment?.getComment(content)
    }
    
    func onComment() {
        let vc = AddTopic(nibName: "AddTopic", bundle: nil)
        vc.type = 1
        vc.id = data!.stringAttributeForKey("id")
        vc.delegateComment = self
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 加入 count 以避免某个奇怪的 bug，
    // 这个 bug 已经没法重现了，但是会导致一直重复请求服务器
    var count = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            layout(data)
        } else {
            if index == 0 && id != ""{
                if count == 0 {
                    Api.getTopic(id) { json in
                        if json != nil {
                            self.data = json!.objectForKey("data") as? NSMutableDictionary
                            self.layout(self.data)
                            self.delegateVote?.updateTable()
                            self.count++
                        }
                    }
                }
            }
        }
    }
    
    // 通过 data 来设置布局
    func layout(data: NSMutableDictionary?) {
        let title = data!.stringAttributeForKey("title").decode()
        let content = data!.stringAttributeForKey("content").decode()
        let comment = data!.stringAttributeForKey("answers_count")
        let numLike = Int(data!.stringAttributeForKey("like_count"))
        let numDislike = Int(data!.stringAttributeForKey("dislike_count"))
        let num = SAThousand("\(numLike! - numDislike!)")
        
        // 计算高度与宽度
        let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
        let tags = data!.objectForKey("tags") as? Array<String>
        
        // 填充内容
        labelTitle.text = title
        labelNum.text = num
        labelTotal.text = "\(comment) 条回应"
        
        // 填充正文
        if arr == nil {
            arr = getRedditArray(content)
            var numBottom = labelTitle.bottom() + 16
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
                    self.viewHolder.addSubview(label)
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
                        self.viewHolder.addSubview(image)
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
                            self.viewHolder.addSubview(v)
                        }
                    }
                    numBottom = numBottom + 64 + 16
                }
            }
            
            // 设定高度与宽度
            labelTitle.setHeight(hTitle)
            labelComment.setY(numBottom)
            viewBottom.setY(labelComment.bottom() + 24)
            
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
            
            // 设置标签
            var x: CGFloat = 11
            if tags != nil {
                if tags?.count > 0 {
                    for tag in tags! {
                        let t = tag.decode()
                        let label = UILabel()
                        label.setTagLabel(t)
                        label.setX(x)
                        label.userInteractionEnabled = true
                        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toSearch:"))
                        scrollView.addSubview(label)
                        x = x + label.width() + 8
                    }
                    scrollView.contentSize = CGSizeMake(x + 3, scrollView.frame.height)
                    scrollView.setTag()
                    viewHolder.setHeight(viewBottom.bottom() + 52)
                    delegateTop?.updateDic(data!)
                    delegate?.updateData(index, key: "heightCell", value: "\(viewBottom.bottom() + 52)", section: 0)
                } else {
                    scrollView.hidden = true
                    viewHolder.setY(0)
                    viewHolder.setHeight(viewBottom.bottom())
                    delegateTop?.updateDic(data!)
                    delegate?.updateData(index, key: "heightCell", value: "\(viewBottom.bottom())", section: 0)
                }
            }
        }
        setupVote()
    }
    
    // 搜索标签
    func toSearch(sender: UIGestureRecognizer) {
        let label = sender.view as! UILabel
        let storyboard = UIStoryboard(name: "Explore", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ExploreSearch") as! ExploreSearch
        vc.preSetSearch = label.text!
        vc.shouldPerformSearch = true
        vc.index = 3
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
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
        Vote.onUp(data!, delegate: delegateVote, index: indexVote, section: 0)
    }
    
    // 投票 - 踩
    func onDown() {
        Vote.onDown(data!, delegate: delegateVote, index: indexVote, section: 0)
    }
}