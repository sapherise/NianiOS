//
//  Guide.swift
//  Nian iOS
//
//  Created by Sa on 16/3/6.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Guide: UIView {
    var ghost: UIImageView!
    var os: UIView!
    var label: UILabel!
    
    /* 台词与 OS 的间距 */
    let padding: CGFloat = 20
    var arr = [String]()
    
    /* 鬼的高度 */
    let h = globalWidth * 35.0 / (2.0 * 38.0)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight))
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.isUserInteractionEnabled = true
        self.tag = 0
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Guide.onTap(_:))))
    }
    
    func setup() {
        let xOS: CGFloat = 36
        let yOS: CGFloat = 90
        let hOS: CGFloat = 110
        
        if let name = Cookies.get("user") as? String {
            arr = [
                "欢迎光临！\n\(name) 同学！",
                "念是一个可以养宠物的日记本！",
                "每天你写下一些内容时",
                "都会获得一些金币 💰💰💰",
                "依靠这些金币\n培养出可爱的宠物！👻",
                "试着点底部栏的蓝色按钮，\n随便写点什么",
                "来获得第一个宠物蛋吧！🐣",
                "如果你不知道写什么...",
                "发一张照片也可以~"
            ]
            
            ghost = UIImageView(frame: CGRect(x: -10, y: globalHeight - h - 30, width: globalWidth / 2, height: h))
            ghost.image = UIImage(named: "guide")
            ghost.contentMode = UIViewContentMode.scaleAspectFit
            self.addSubview(ghost)
            
            os = UIView(frame: CGRect(x: globalWidth/2 - xOS, y: globalHeight - h - yOS, width: globalWidth / 2 - xOS + 40, height: hOS))
            os.layer.borderWidth = 4
            os.layer.masksToBounds = true
            os.layer.cornerRadius = 8
            os.layer.borderColor = UIColor.black.cgColor
            os.backgroundColor = UIColor.colorWithHex("#fffef8")
            self.addSubview(os)
            
            label = UILabel(frame: CGRect(x: padding, y: padding, width: os.width() - padding * 2, height: 0))
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = UIColor.black
            os.addSubview(label)
            
            say(arr[0])
        }
    }
    
    func say(_ content: String) {
        let tag = self.tag
        self.tag = tag + 1
        label.text = ""
        let hLabel = content.stringHeightWith(17, width: os.width() - padding * 2)
        label.setHeight(hLabel)
        os.setHeight(hLabel + padding * 2)
        os.setY(globalHeight - h - os.height())
        
        let l = (content as NSString).length
        for i in 1...l {
            if self.tag == tag + 1 {
                delay(0.05 * Double(i), closure: { () -> () in
                    let c = (content as NSString).substring(with: NSRange(location: 0, length: i))
                    self.label.text = c
                })
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap(_ sender: UIGestureRecognizer) {
        if let v = sender.view {
            let tag = v.tag
            if arr.count > tag {
                say(arr[tag])
            } else {
                self.removeFromSuperview()
                Cookies.set("1" as AnyObject?, forKey: "guide")
            }
        }
    }
}
