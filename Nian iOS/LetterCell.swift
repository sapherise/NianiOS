//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class LetterCell: UITableViewCell {
    
    @IBOutlet var labelTitle:UILabel!
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelCount: UILabel!
    @IBOutlet var viewDelete: UIView!
    var data: NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.viewDelete.setX(globalWidth)
        self.setWidth(globalWidth)
        self.lastdate?.setX(globalWidth-92)
        self.viewLine.setWidth(globalWidth-85)
        self.imageHead.layer.cornerRadius = 20.0
        self.imageHead.layer.masksToBounds = true   
    }
    
    func onUserClick() {
        let uid = data.stringAttributeForKey("id")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setup() {
        self.selectionStyle = .none
        let id = self.data.stringAttributeForKey("id")
        let title = self.data.stringAttributeForKey("title")
        let content = self.data.stringAttributeForKey("content")
        let unread = self.data.stringAttributeForKey("unread")
        let lastdate = self.data.stringAttributeForKey("lastdate")
        self.imageHead.setHead(id)
        if let v = Int(id) {
            self.imageHead.tag = v
        }
        self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LetterCell.onUserClick)))
        self.labelTitle.text = title
        self.labelContent.text = content
        self.lastdate?.text = lastdate
        
        if unread == "0" {
            labelCount.text = "0"
            labelCount.isHidden = true
        } else {
            labelCount.isHidden = false
            let w = unread.stringWidthWith(11, height: 20) + 16
            labelCount.text = unread
            labelCount.setWidth(w)
            labelCount.setX(globalWidth - 15 - w)
        }
    }
}
