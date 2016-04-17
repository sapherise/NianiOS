//
//  ListCell.swift
//  Nian iOS
//
//  Created by Sa on 16/1/12.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

protocol ListDelegate {
    func update(index: Int, key: String, value: String)
}

class ListCell: UITableViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelButton: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLine: UIView!
//    @IBOutlet weak var heightViewLine: NSLayoutConstraint!
    
    var data: NSDictionary!
    var type: ListType!
    
    /* 判断是否已经激活按钮 */
    var hasSelected = false
    
    /* List 的代理协议 */
    var delegate: ListDelegate?
    
    /* indexPath */
    var num = -1
    
    /* 传入的记本 id */
    var id = "-1"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
//        heightViewLine.constant = globalHalf
        viewLine.frame = CGRectMake(70, 70, globalWidth - 85, globalHalf)
        imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onHead)))
        labelTitle.setWidth(globalWidth - 170)
    }
    
    func setup() {
        let uid = data.stringAttributeForKey("uid")
        let name = data.stringAttributeForKey("name")
        
        labelTitle.text = name
        imageHead.setHead(uid)
        
        if type == ListType.Members {
            labelButton.hidden = true
        } else if type == ListType.Invite {
            labelButton.layer.borderColor = UIColor.HighlightColor().CGColor
            labelButton.layer.borderWidth = 1
            labelButton.setX(globalWidth - 15 - labelButton.width())
            
            /* 通过判断 hasSelected 来显示按钮与绑定动作 */
            if !hasSelected {
                labelButton.backgroundColor = UIColor.whiteColor()
                labelButton.textColor = UIColor.HighlightColor()
                labelButton.text = "邀请"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onSelect)))
            } else {
                labelButton.backgroundColor = UIColor.HighlightColor()
                labelButton.textColor = UIColor.whiteColor()
                labelButton.text = "已邀请"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onUnSelect)))
            }
        } else {
            labelTitle.text = data.stringAttributeForKey("username")
            
            /* 赞的类型 */
            let type = data.stringAttributeForKey("type")
            let rewardType = data.stringAttributeForKey("rewardtype")
            
            if type == "0" || type == "1" {
                labelButton.setWidth(70)
                labelButton.layer.borderColor = UIColor.HighlightColor().CGColor
                labelButton.layer.borderWidth = 1
                labelButton.setX(globalWidth - 15 - labelButton.width())
                
                let hasFollowed = data.stringAttributeForKey("follow") == "1"
                if hasFollowed {
                    labelButton.backgroundColor = UIColor.HighlightColor()
                    labelButton.textColor = UIColor.whiteColor()
                    labelButton.text = "已关注"
                    labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onUnSelect)))
                } else {
                    labelButton.backgroundColor = UIColor.whiteColor()
                    labelButton.textColor = UIColor.HighlightColor()
                    labelButton.text = "关注"
                    labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onSelect)))
                }
                labelButton.layer.cornerRadius = 15
            } else {
                /* 奖励的赞 */
                labelButton.setWidth(labelButton.height())
                labelButton.layer.borderColor = UIColor.PremiumColor().CGColor
                labelButton.layer.borderWidth = 1
                labelButton.setX(globalWidth - 15 - labelButton.width())
                labelButton.backgroundColor = UIColor.PremiumColor()
                labelButton.layer.cornerRadius = 4
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPremium)))
                if let _rewardType = Int(rewardType) {
                    let arr = ["🍭", "🍮", "☕️", "🍺", "🍧", "💩"]
                    let premium = arr[_rewardType]
                    labelButton.text = premium
                }
            }
        }
    }
    
    func onPremium() {
        let vc = Premium()
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onSelect() {
        let uid = data.stringAttributeForKey("uid")
        if type == ListType.Invite {
            delegate?.update(num, key: "inviting", value: "1")
            Api.getInvite(id, uid: uid) { json in
                print(json)
            }
        } else if type == ListType.Like {
            delegate?.update(num, key: "follow", value: "1")
            Api.getFollow(uid) { json in
                print(json)
            }
        }
    }
    
    func onUnSelect() {
        let uid = data.stringAttributeForKey("uid")
        if type == ListType.Like {
            delegate?.update(num, key: "follow", value: "0")
            Api.getUnfollow(uid) { json in
                print(json)
            }
        }
    }
    
    func onHead() {
        let uid = data.stringAttributeForKey("uid")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}