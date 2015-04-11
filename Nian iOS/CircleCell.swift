//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class CircleCell: MKTableViewCell {
    
    @IBOutlet var labelTitle:UILabel!
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelCount: UILabel!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var viewDelete: UIView!
    @IBOutlet var textDelete: UILabel!
    
    var largeImageURL:String = ""
    var data :NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.viewDelete.setX(globalWidth)
        self.viewHolder.setWidth(globalWidth)
        self.lastdate?.setX(globalWidth-92)
        self.viewLine.setWidth(globalWidth-85)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var id = self.data!.stringAttributeForKey("id")
            var title = self.data!.stringAttributeForKey("title")
            if id == "0" {
                self.textDelete.text = "前往"
                self.imageHead.setImage("http://img.nian.so/dream/1_1420533664.png!dream", placeHolder: IconColor)
                self.labelContent.text = "念的留言板"
                self.labelTitle.text = "广场"
                self.labelCount.hidden = true
                self.lastdate?.hidden = true
            }else{
                self.textDelete.text = "再见"
                var img = self.data!.stringAttributeForKey("img")
                if title == "梦境" {
                    Api.getCircleTitle(id) { json in
                        if json != nil {
                            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            var safeuid = Sa.objectForKey("uid") as String
                            var img = json!["img"] as String
                            var titleNew = json!["title"] as String
                            self.labelTitle.text = titleNew
                            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
                            SD.executeChange("insert into circlelist(id, circleid, title, image, postdate, owner) values (null, ?, ?, ?, '0', ?)", withArgs: [id, titleNew, img, safeuid])
                        }
                    }
                }else{
                    self.labelTitle.text = title
                    self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
                }
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as String
                let (resultSet2, err2) = SD.executeQuery("select * from circle where circle='\(id)' and owner = '\(safeuid)' order by id desc limit 1")
                if err2 == nil {
                    if resultSet2.count > 0 {
                        for row in resultSet2 {
                            var postdate = (row["lastdate"]!.asString() as NSString).doubleValue
                            var user = row["name"]!.asString()
                            var content = row["content"]!.asString()
                            var type = row["type"]!.asString()
                            var textContent = ""
                            switch type {
                            case "1":   textContent = ": \(content)"
                                break
                            case "2":   textContent = "发来一张图片"
                                break
                            case "3":   textContent = "更新了梦想"
                                break
                            case "4":   textContent = "获得了成就"
                                break
                            case "5":   textContent = content
                                break
                            case "6":   textContent = content
                                break
                            case "7":   textContent = content
                                break
                            default:    textContent = "触发了一个彩蛋"
                                break
                            }
                            self.lastdate!.text = V.relativeTime(postdate, current: NSDate().timeIntervalSince1970)
                            self.labelContent.text = "\(user)\(textContent)"
                            break
                        }
                    }else{
                        self.lastdate!.hidden = true
                        self.labelContent.text = "可以开始聊天啦"
                    }
                }
                let (resultSet, err) = SD.executeQuery("select id from circle where circle='\(id)' and isread = 0 and owner = '\(safeuid)'")
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
}