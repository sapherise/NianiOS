//
//  CircleCollectionCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/9/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CircleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var textOval: UIImageView!   // 提示是否有新消息，    ---- 左
    @IBOutlet weak var topicOval: UIImageView!  // 提示是否有新 topic   ---- 中
    @IBOutlet weak var chatOval: UIImageView!   // 提示是否有新对话，    ---- 右
    @IBOutlet weak var imageHeadView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var largeImageURL: String = ""
    var data: NSDictionary?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1).CGColor
        
        self.imageHeadView.layer.cornerRadius = 4.0
        self.imageHeadView.layer.masksToBounds = true
        self.imageHeadView.layer.borderWidth = 0.5
        self.imageHeadView.layer.borderColor = UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1).CGColor
    }
   
    /**
        画线和地下的阴影
    
    :param: rect
    */
    override func drawRect(rect: CGRect) {
        var color = UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
        color.set()
        
        var shadowPath = UIBezierPath()
        shadowPath.lineWidth = 1.0
        shadowPath.moveToPoint(CGPointMake(0, 178))
        shadowPath.addQuadCurveToPoint(CGPointMake(4.0, 182.0), controlPoint: CGPointMake(0, 182.0))
        shadowPath.addLineToPoint(CGPointMake(self.frame.width - 4, 182.0))
        shadowPath.addQuadCurveToPoint(CGPointMake(self.frame.width, 178.0), controlPoint: CGPointMake(self.frame.width, 182.0))
        shadowPath.stroke()
        
        var seperatorLine = UIBezierPath()
        seperatorLine.lineWidth = 0.5
        seperatorLine.moveToPoint(CGPointMake(0, 137))
        seperatorLine.addLineToPoint(CGPointMake(self.frame.width, 137))
        seperatorLine.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if data != nil {
            var id = self.data!.stringAttributeForKey("id")
            var title = self.data!.stringAttributeForKey("title")
            
            if id == "0" {
                self.imageHeadView.setImage("http://img.nian.so/dream/1_1420533664.png!dream", placeHolder: IconColor)
                self.titleLabel.text = "广场"
            } else {
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
                            case "2":   textContent = "发来一张图片"
                            case "3":   textContent = "更新了记本"
                            case "4":   textContent = "获得了成就"
                            case "5":   textContent = content
                            case "6":   textContent = content
                            case "7":   textContent = content
                            default:    textContent = "触发了一个彩蛋"
                            }
                            
                            break
                        }
                    } else {

                    }
                }
                
                let (resultSet, err) = SD.executeQuery("select id from circle where circle='\(id)' and isread = 0 and owner = '\(safeuid)'")
                if err == nil {
                    var count = resultSet.count
                    if count == 0 {
                        
                    }else{
                        
                    }
                }
            }
        }
    }
    
    // MARK: 处理 Button 的点击事件
    
    @IBAction func text(sender: UIButton) {
       toNewCircle(0)
    }
    
    @IBAction func topic(sender: UIButton) {
        toNewCircle(1)
    }
    
    @IBAction func chat(sender: UIButton) {
        toNewCircle(2)
    }
    
    func toNewCircle(current: Int) {
        if let id = self.data?.stringAttributeForKey("id") {
            var vc = NewCircleController()
            vc.id = id
            vc.current = current
            vc.textTitle = self.data!.stringAttributeForKey("title")
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}























