//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class MeCell: UITableViewCell {
    
    @IBOutlet var avatarView:UIImageView?
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var wordLabel:UILabel?
    @IBOutlet var contentLabel:UILabel?
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var View:UIView?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelConfirm: UILabel!
    var largeImageURL:String = ""
    var data :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.View!.backgroundColor = BGColor
        self.imageDream.setX(globalWidth-55)
        self.lastdate!.setX(globalWidth-107)
        self.contentLabel?.setWidth(globalWidth-40)
        self.viewLine.setWidth(globalWidth - 40)
        viewLine.setHeightHalf()
        self.labelConfirm.setX(globalWidth/2-50)
    }
    
    func _layoutSubviews() {

        let uid = self.data.stringAttributeForKey("cuid")
        let user = self.data.stringAttributeForKey("cname")
        var lastdate = self.data.stringAttributeForKey("lastdate")
        lastdate = V.relativeTime(lastdate)
        let dreamtitle = self.data.stringAttributeForKey("dreamtitle")
        var content = self.data.stringAttributeForKey("content").decode()
        let type = self.data.stringAttributeForKey("type")
        let isread = self.data.stringAttributeForKey("isread")
        let img = self.data.stringAttributeForKey("image")
        let dream = self.data.stringAttributeForKey("dream")
        let isConfirm = self.data.stringAttributeForKey("isConfirm")
        var word:String = ""
        
        switch type {
        case "0": word = "在「\(dreamtitle)」留言"
        case "1": word = "在「\(dreamtitle)」提到你"
        case "2": word = "赞了你的记本「\(dreamtitle)」"
            content = "「\(dreamtitle)」"
        case "3": word = "关注了你"
            content = "去看看对方"
        case "4": word = "参与你的话题「\(dreamtitle)」"
        case "5": word = "在「\(dreamtitle)」提到你"
        case "6": word = "为你的记本「\(dreamtitle)」更新了"
        case "7": word = "添加你为「\(dreamtitle)」的伙伴"
            content = "「\(dreamtitle)」"
        case "8": word = "赞了你的进展"
            content = dreamtitle
        case "9": word = "申请加入梦境「\(dreamtitle)」"
        case "10": word = "邀请你加入梦境"
        content = "「\(dreamtitle)」"
        case "11": word = "回应了你的话题"
        case "12": word = "在话题中与你互动了"
        case "13": word = "赞了你的话题"
        case "14": word = "赞了你的回应"
        case "16": word = "在话题中与你互动了"
        default: word = "与你互动了"
        }
        
        self.nickLabel!.text = user
        self.wordLabel!.text = word
        self.lastdate!.text = lastdate
        if isread == "1" {
            self.nickLabel!.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }else{
            self.nickLabel!.textColor = SeaColor
        }
        self.avatarView?.setHead(uid)
        self.avatarView!.tag = Int(uid)!
        let height = content.stringHeightWith(16,width:globalWidth-30)
        
        self.contentLabel!.setHeight(height)
        self.contentLabel!.text = content
        if type == "9" {
            self.labelConfirm.setY(self.contentLabel!.bottom()+20)
            self.imageDream.hidden = false
            self.labelConfirm.hidden = false
            self.imageDream.tag = Int(dream)!
            self.imageDream.setImage("http://img.nian.so/dream/\(img)!dream")
            self.lastdate!.hidden = true
            self.viewLine.setY(self.labelConfirm!.bottom()+25)
            let tap = UITapGestureRecognizer(target: self, action: "onConfirmClick:")
            if isConfirm == "0" {
                self.labelConfirm.text = "接受"
                self.labelConfirm.backgroundColor = SeaColor
                self.labelConfirm.addGestureRecognizer(tap)
            }else{
                self.labelConfirm.text = "已接受"
                self.labelConfirm.backgroundColor = IconColor
                self.labelConfirm.removeGestureRecognizer(tap)
            }
        }else{
            self.imageDream.hidden = true
            self.labelConfirm.hidden = true
            self.lastdate!.hidden = false
            self.viewLine.setY(self.contentLabel!.bottom()+25)
        }
    }
    
    func onConfirmClick(sender:UIGestureRecognizer) {
        let view = sender.view! as! UILabel
        view.text = ""
        let id = self.data.stringAttributeForKey("id") as String
        Api.getCircleJoinConfirmOK(id) { json in
            if json != nil {
                let success = json!.objectForKey("success") as! String
                let reason = json!.objectForKey("reason") as! String
                if success == "1" {
                    view.text = "已接受"
                    view.backgroundColor = IconColor
                    view.removeGestureRecognizer(sender)
                }else{
                    view.text = "接受"
                    if reason == "1" {
                        self.View?.showTipText("遇到了一个奇怪的错误...", delay: 2)
                    }else if reason == "2" {
                        self.View?.showTipText("你的权限不够...", delay: 2)
                    }else if reason == "3" {
                        self.View?.showTipText("梦境的人满了！", delay: 2)
                    }else{
                        self.View?.showTipText("遇到了一个奇怪的错误...", delay: 2)
                    }
                }
            }
        }
    }
    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        let dreamtitle = data.stringAttributeForKey("dreamtitle")
        var content = data.stringAttributeForKey("content")
        let type = data.stringAttributeForKey("type")
        if type == "8" {
            content = dreamtitle
        }
        let height = content.stringHeightWith(16,width:globalWidth-30)
        if type == "9" {
            return 159 + height
        }else{
            return 103 + height
        }
    }
    
}
