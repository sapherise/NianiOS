//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class LetterCell: MKTableViewCell {
    
    @IBOutlet var labelTitle:UILabel!
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelCount: UILabel!
    @IBOutlet var viewDelete: UIView!
    
    var largeImageURL:String = ""
    var data :NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.viewDelete.setX(globalWidth)
        self.setWidth(globalWidth)
        self.lastdate?.setX(globalWidth-92)
        self.viewLine.setWidth(globalWidth-85)
    }
    
    func onUserClick(sender: UIGestureRecognizer) {
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.findRootViewController()?.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        if data != nil {
            var id = self.data!.stringAttributeForKey("id")
            var title = self.data!.stringAttributeForKey("title")
            self.imageHead.setHead(id)
            if let v = id.toInt() {
                self.imageHead.tag = v
            }
            self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick:"))
            self.labelTitle.text = title
            let (resultSet2, err2) = SD.executeQuery("select * from letter where circle='\(id)' and owner = '\(safeuid)' order by id desc limit 1")
            if resultSet2.count > 0 {
                for row in resultSet2 {
                    var postdate = (row["lastdate"]!.asString() as NSString).doubleValue
                    var content = row["content"]!.asString()
                    var type = row["type"]!.asString()
                    var textContent = content
                    if type == "2" {
                        textContent = "发了一张图片"
                    }
                    self.lastdate!.text = V.relativeTime(postdate, current: NSDate().timeIntervalSince1970)
                    self.labelContent.text = textContent
                    break
                }
            }else{
                self.lastdate!.hidden = true
                self.labelContent.text = "可以开始聊天啦"
            }
            let (resultSet, err) = SD.executeQuery("select id from letter where circle='\(id)' and isread = 0 and owner = '\(safeuid)'")
            if err == nil {
                var count = resultSet.count
                if count == 0 {
                    self.labelCount.text = "0"
                    self.labelCount.hidden = true
                }else{
                    self.labelCount.hidden = false
                    var widthCount = ceil("\(count)".stringWidthWith(11, height: 20) + 16.0)
                    self.labelCount.text = "\(count)"
                    self.labelCount.setWidth(widthCount)
                    self.labelCount.setX(globalWidth-15-widthCount)
                }
            }
        }
    }
}