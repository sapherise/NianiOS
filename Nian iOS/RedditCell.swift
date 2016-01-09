//
//  RedditCell.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

@objc protocol RedditDelegate {
    func updateData(index: Int, key: String, value: String, section: Int)
    func updateTable()
    
    /* 凑合着先用吧 */
    optional func deleteCellInTable(index: Int)
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
        super.awakeFromNib()
        
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelTitle.setWidth(globalWidth - 80)
        labelContent.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeightHalf()
        viewBottomLine.setWidth(0.5)
        viewVoteLine.setHeightHalf()
        labelTag.backgroundColor = SeaColor
    }
    
    func setup() {
        if data != nil {
            let title = data.stringAttributeForKey("title").decode()
            let content = data.stringAttributeForKey("content").decode().toRedditReduce()
            let comment = SAThousand(data.stringAttributeForKey("answers_count"))
            let lastdate = data.stringAttributeForKey("created_at")
            let time = V.relativeTime(lastdate)
            let numLike = Int(data.stringAttributeForKey("like_count"))
            let numDislike = Int(data.stringAttributeForKey("dislike_count"))
            let num = numLike! - numDislike!
            let tags = data.objectForKey("tags") as? Array<String>
            var tag: String?
            if tags != nil {
                if tags!.count > 0 {
                    tag = "\(tags![0])"
                }
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
            
//            self.labelContent.userHandleLinkTapHandler = ({
//                (label: KILabel, string: String, range: NSRange) in
//                var _string = string
//                _string.removeAtIndex(string.startIndex.advancedBy(0))
//                self.findRootViewController()?.viewLoadingShow()
//                Api.postUserNickName(_string) {
//                    json in
//                    if json != nil {
//                        let error = json!.objectForKey("error") as! NSNumber
//                        self.findRootViewController()?.viewLoadingHide()
//                        if error == 0 {
//                            if let uid = json!.objectForKey("data") as? String {
//                                let UserVC = PlayerViewController()
//                                UserVC.Id = uid
//                                self.findRootViewController()?.navigationController?.pushViewController(UserVC, animated: true)
//                            }
//                        } else {
//                            self.showTipText("没有人叫这个名字...")
//                        }
//                    }
//                }
//                
//            })
//            
//            self.labelContent.urlLinkTapHandler = ({
//                (label: KILabel, string: String, range: NSRange) in
//                
//                if !string.hasPrefix("http://") && !string.hasPrefix("https://") {
//                    let urlString = "http://\(string)"
//                    let web = WebViewController()
//                    web.urlString = urlString
//                    
//                    self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
//                } else {
//                    let web = WebViewController()
//                    web.urlString = string
//                    
//                    self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
//                }
//            })
//            
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
            
            setupVote()
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
        Vote.onUp(data, delegate: delegate, index: index, section: 0)
    }
    
    // 投票 - 踩
    func onDown() {
        Vote.onDown(data, delegate: delegate, index: index, section: 0)
    }
}

extension UIView {
    func setVote() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
    }
}