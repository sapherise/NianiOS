//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class CircleCell: UITableViewCell {
    
    @IBOutlet var labelTitle:UILabel!
    @IBOutlet var lastdate:UILabel?
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelCount: UILabel!
    
    var largeImageURL:String = ""
    var data :NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var id = self.data!.stringAttributeForKey("id")
            var title = self.data!.stringAttributeForKey("title")
            var img = self.data!.stringAttributeForKey("img")
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
            self.labelTitle.text = title
            
            let (resultSet2, err2) = SD.executeQuery("select * from circle where circle='\(id)' order by id desc limit 1")
            if err2 == nil {
                if resultSet2.count > 0 {
                    println("哈哈")
                    for row in resultSet2 {
                        var postdate = (row["lastdate"]!.asString() as NSString).doubleValue
                        var user = row["name"]!.asString()
                        var content = row["content"]!.asString()
                        var type = row["type"]!.asString()
                        var cuser = row["cname"]!.asString()
                        
                        
                        var textContent = ""
                        // 1: 文字消息，2: 图片消息，3: 进展更新，4: 成就通告，5: 用户加入，6: 管理员操作，7: 邀请用户
                        switch type {
                        case "1":   textContent = ": \(content)"
                        case "2":   textContent = "发来一张图片"
                        case "3":   textContent = "更新了梦想"
                        case "4":   textContent = "获得了成就"
                        case "5":   textContent = (content != "-1") ? "加入了梦境" : "离开了梦境"
                        case "6":   textContent = "\(content)\(cuser)"
                        case "7":   textContent = "邀请了\(cuser)"
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
            
            
            
            let (resultSet, err) = SD.executeQuery("select id from circle where circle='\(id)' and isread = 0")
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
                    self.labelCount.setX(305-widthCount)
                }
            }
            
        }
    }
}