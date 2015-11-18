//
//  ResponsedTopicCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/17/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class ResponsedTopicCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelContent: KILabel!
    @IBOutlet weak var viewUp: UIImageView!
    @IBOutlet weak var viewDown: UIImageView!
    @IBOutlet weak var viewVoteLine: UIView!
    @IBOutlet weak var labelNum: UILabel!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var imageHead: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTime: UILabel!

    @IBOutlet weak var voteLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!
    
    var data = NSDictionary()
    var indexVote: Int = 0
    var delegate: RedditDelegate?
    var delegateDelete: RedditDeleteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.bounds = UIScreen.mainScreen().bounds
        self.titleLabel.text = ""
        self.labelContent.text = ""
        
        self.selectionStyle = .None
        self.voteLineHeightConstraint.constant = globalHalf
        self.lineHeightConstraint.constant = globalHalf
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        self.voteLineHeightConstraint.constant = globalHalf
        self.lineHeightConstraint.constant = globalHalf
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpContent(data: NSDictionary) {
        let title = data.stringAttributeForKey("title")
        let content = data.stringAttributeForKey("content").decode().toRedditReduce()
        let uid = data.stringAttributeForKey("user_id")
        let lastdate = data.stringAttributeForKey("created_at")
        let time = V.relativeTime(lastdate)

        let numLike = Int(data.stringAttributeForKey("like_count"))
        let numDislike = Int(data.stringAttributeForKey("dislike_count"))
        let num = SAThousand("\(numLike! - numDislike!)")
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        // 填充内容
        titleLabel.text = title
        labelContent.text = content
        labelNum.text = num
        labelTime.text = time
        imageHead.setHead(uid)
        labelName.text = userDefault.objectForKey("user") as? String
        labelNum.text = num
        
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
                        self.showTipText("没有人叫这个名字...", delay: 2)
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
        
        self.viewUp.layer.cornerRadius = 4
        self.viewUp.layer.borderWidth = 0.5
        self.viewUp.layer.masksToBounds = true

        // 下按钮
        viewDown.layer.borderColor = UIColor.e6().CGColor
        viewDown.backgroundColor = UIColor.whiteColor()
        
        self.viewDown.layer.cornerRadius = 4
        self.viewDown.layer.borderWidth = 0.5
        self.viewDown.layer.masksToBounds = true
        
        // 绑定事件
        imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
        labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUser"))
        
        setupVote()
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
