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
    func update(_ index: Int, key: String, value: String)
}

class ListCell: UITableViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelButton: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLine: UIView!
//    @IBOutlet weak var heightViewLine: NSLayoutConstraint!
    
    var data: NSDictionary!
    var type: ListType!
    
    /* List 的代理协议 */
    var delegate: ListDelegate?
    
    /* indexPath */
    var num = -1
    
    /* 传入的记本 id */
    var id = "-1"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
//        heightViewLine.constant = globalHalf
        viewLine.frame = CGRect(x: 70, y: 70, width: globalWidth - 85, height: globalHalf)
        imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onHead)))
        labelTitle.setWidth(globalWidth - 170)
    }
    
    func setup() {
        let uid = data.stringAttributeForKey("uid")
        let name = data.stringAttributeForKey("name")
        
        labelTitle.text = name
        imageHead.setHead(uid)
        
        if type == ListType.members {
            labelButton.isHidden = true
        } else if type == ListType.invite {
            labelButton.layer.borderColor = UIColor.HighlightColor().cgColor
            labelButton.layer.borderWidth = 1
            labelButton.setX(globalWidth - 15 - labelButton.width())
            let inviting = data.stringAttributeForKey("inviting")
            if inviting == "0" {
                labelButton.backgroundColor = UIColor.white
                labelButton.textColor = UIColor.HighlightColor()
                labelButton.text = "邀请"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onSelect)))
            } else {
                labelButton.backgroundColor = UIColor.HighlightColor()
                labelButton.textColor = UIColor.white
                labelButton.text = "已邀请"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onUnSelect)))
            }
        } else if type == ListType.like {
            labelTitle.text = data.stringAttributeForKey("username")
            
            /* 赞的类型 */
            let type = data.stringAttributeForKey("type")
            let rewardType = data.stringAttributeForKey("rewardtype")
            
            if type == "0" || type == "1" {
                labelButton.setWidth(70)
                labelButton.layer.borderColor = UIColor.HighlightColor().cgColor
                labelButton.layer.borderWidth = 1
                labelButton.setX(globalWidth - 15 - labelButton.width())
                
                let hasFollowed = data.stringAttributeForKey("follow") == "1"
                if hasFollowed {
                    labelButton.backgroundColor = UIColor.HighlightColor()
                    labelButton.textColor = UIColor.white
                    labelButton.text = "已关注"
                    labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onUnSelect)))
                } else {
                    labelButton.backgroundColor = UIColor.white
                    labelButton.textColor = UIColor.HighlightColor()
                    labelButton.text = "关注"
                    labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onSelect)))
                }
                labelButton.layer.cornerRadius = 15
            } else {
                /* 奖励的赞 */
                labelButton.setWidth(labelButton.height())
                labelButton.layer.borderColor = UIColor.PremiumColor().cgColor
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
        } else if type == ListType.followers {
            labelTitle.text = data.stringAttributeForKey("user")
            labelButton.layer.borderColor = UIColor.HighlightColor().cgColor
            labelButton.layer.borderWidth = 1
            labelButton.setX(globalWidth - 15 - labelButton.width())
            
            /* 通过判断 hasSelected 来显示按钮与绑定动作 */
            if data.stringAttributeForKey("follow") == "0" {
                labelButton.backgroundColor = UIColor.white
                labelButton.textColor = UIColor.HighlightColor()
                labelButton.text = "关注"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onSelect)))
            } else {
                labelButton.backgroundColor = UIColor.HighlightColor()
                labelButton.textColor = UIColor.white
                labelButton.text = "已关注"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onUnSelect)))
            }
        } else if type == ListType.dreamLikes {
            labelTitle.text = data.stringAttributeForKey("user")
            labelButton.layer.borderColor = UIColor.HighlightColor().cgColor
            labelButton.layer.borderWidth = 1
            labelButton.setX(globalWidth - 15 - labelButton.width())
            
            /* 通过判断 hasSelected 来显示按钮与绑定动作 */
            if data.stringAttributeForKey("follow") == "0" {
                labelButton.backgroundColor = UIColor.white
                labelButton.textColor = UIColor.HighlightColor()
                labelButton.text = "关注"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onSelect)))
            } else {
                labelButton.backgroundColor = UIColor.HighlightColor()
                labelButton.textColor = UIColor.white
                labelButton.text = "已关注"
                labelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ListCell.onUnSelect)))
            }
        }
    }
    
    func onPremium() {
        let vc = Premium()
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onSelect() {
        let uid = data.stringAttributeForKey("uid")
        if type == ListType.invite {
            delegate?.update(num, key: "inviting", value: "1")
            Api.getInvite(id, uid: uid) { json in
            }
        } else if type == ListType.like {
            delegate?.update(num, key: "follow", value: "1")
            Api.getFollow(uid) { json in
            }
        } else if type == ListType.dreamLikes {
            delegate?.update(num, key: "follow", value: "1")
            Api.getFollow(uid) { json in
            }
        } else if type == ListType.followers {
            delegate?.update(num, key: "follow", value: "1")
            Api.getFollow(uid) { json in
            }
        }
    }
    
    func onUnSelect() {
        let uid = data.stringAttributeForKey("uid")
        if type == ListType.like {
            delegate?.update(num, key: "follow", value: "0")
            Api.getUnfollow(uid) { json in
            }
        } else if type == ListType.dreamLikes {
            delegate?.update(num, key: "follow", value: "0")
            Api.getUnfollow(uid) { json in
            }
        } else if type == ListType.followers {
            delegate?.update(num, key: "follow", value: "0")
            Api.getUnfollow(uid) { json in
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
