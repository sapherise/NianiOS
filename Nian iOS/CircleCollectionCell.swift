//
//  CircleCollectionCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/9/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CircleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var textOval: UIImageView!
    @IBOutlet weak var topicOval: UIImageView!
    @IBOutlet weak var chatOval: UIImageView!
    @IBOutlet weak var imageHeadView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var largeImageURL: String = ""
    var data: NSDictionary?
    
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1).CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var id = self.data!.stringAttributeForKey("id")
            var title = self.data!.stringAttributeForKey("title")
            if id == "0" {
//                self.textDelete.text = "前往"
                self.imageHeadView.setImage("http://img.nian.so/dream/1_1420533664.png!dream", placeHolder: IconColor)
//                self.labelContent.text = "念的留言板"
                self.titleLabel.text = "广场"
//                self.labelCount.hidden = true
//                self.lastdate?.hidden = true
            } else {
//                self.textDelete.text = "再见"
                var img = self.data!.stringAttributeForKey("img")
                if title == "梦境" {
                    Api.getCircleTitle(id) { json in
                        if json != nil {
                            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            var safeuid = Sa.objectForKey("uid") as! String
                            var img = json!["img"] as! String
                            var titleNew = json!["title"] as! String
                            self.titleLabel.text = titleNew
                            self.imageHeadView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
                            SD.executeChange("insert into circlelist(id, circleid, title, image, postdate, owner) values (null, ?, ?, ?, '0', ?)", withArgs: [id, titleNew, img, safeuid])
                        }
                    }
                } else {
                    self.titleLabel.text = title
                    self.imageHeadView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
                }
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                let (resultSet2, err2) = SD.executeQuery("select * from circle where circle='\(id)' and owner = '\(safeuid)' order by id desc limit 1")
                if err2 == nil {
                    if resultSet2.count > 0 {
                        for row in resultSet2 {
                            var postdate = (row["lastdate"]!.asString() as NSString).doubleValue
                            var user = row["name"]!.asString()
                            var content = row["content"]!.asString()
                            var type = (row["type"]!.asString())
                            var textContent = ""
                            switch type {
                            case "1":   textContent = ": \(content)"
                                break
                            case "2":   textContent = "发来一张图片"
                                break
                            case "3":   textContent = "更新了记本"
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
//                            self.lastdate!.text = V.relativeTime(postdate, current: NSDate().timeIntervalSince1970)
//                            self.labelContent.text = "\(user)\(textContent)"
                            
                            break
                        }
                    }else{
//                        self.lastdate!.hidden = true
//                        self.labelContent.text = "可以开始聊天啦"
                    }
                }
                let (resultSet, err) = SD.executeQuery("select id from circle where circle='\(id)' and isread = 0 and owner = '\(safeuid)'")
                if err == nil {
                    var count = resultSet.count
                    if count == 0 {
//                        self.labelCount.text = "0"
//                        self.labelCount.hidden = true
                    }else{
//                        self.labelCount.hidden = false
//                        var widthCount = ceil("\(count)".stringWidthWith(11, height: 20) + 16.0)
//                        self.labelCount.text = "\(count)"
//                        self.labelCount.setWidth(widthCount)
//                        self.labelCount.setX(globalWidth-15-widthCount)
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    @IBAction func text(sender: UIButton) {
    }
    
    @IBAction func topic(sender: UIButton) {
    }
    
    @IBAction func chat(sender: UIButton) {
    }
    
}
