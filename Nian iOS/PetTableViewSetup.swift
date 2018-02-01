//
//  PetTableViewFooter.swift
//  Nian iOS
//
//  Created by Sa on 15/7/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension PetViewController: NIAlertDelegate {
    func setupTable() {
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        tableViewPet = UITableView()
        tableViewPet.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI/2))
        tableViewPet.frame = CGRect(x: 0, y: 0, width: globalWidth, height: 320)
        tableViewPet.separatorStyle = .none
        tableViewPet.delegate = self
        tableViewPet.dataSource = self
        
        if let viewLevel = (Bundle.main.loadNibNamed("Level", owner: self, options: nil))?.first as? LevelView {
            viewLevel.setup()
            tableView.tableFooterView = viewLevel
        }
        
        tableViewPet.showsVerticalScrollIndicator = false
        tableViewPet.register(UINib(nibName: "PetCell", bundle: nil), forCellReuseIdentifier: "PetCell")
        
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: (globalWidth - NORMAL_WIDTH)/2))
        viewHeader.isUserInteractionEnabled = true
        viewHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PetViewController.showPetInfo)))
        
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: (globalWidth - NORMAL_WIDTH)/2))
        viewFooter.isUserInteractionEnabled = true
        viewFooter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PetViewController.showPetInfo)))
        tableViewPet.tableHeaderView = viewHeader
        tableViewPet.tableFooterView = viewFooter
        
        
        imageView = UIImageView(frame: CGRect(x: globalWidth/2 - 60, y: 96, width: 120, height: 120))
        tableView.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        self.btnUpgrade = NIButton(string: "升级", frame:  CGRect(x: (globalWidth - 100)/2, y: 252, width: 100, height: 36))
        self.btnUpgrade.bgColor = BgColor.blue
        self.btnUpgrade.addTarget(self, action: #selector(PetViewController.toUpgrade), for: UIControlEvents.touchUpInside)
        tableView.addSubview(self.btnUpgrade)
        
        labelName = UILabel(frame: CGRect(x: globalWidth/2 - 160, y: 32, width: 320, height: 24))
        labelName.textAlignment = NSTextAlignment.center
        labelName.textColor = UIColor.colorWithHex("#333333")
        labelName.font = UIFont.boldSystemFont(ofSize: 18)
        tableView.addSubview(labelName)
        
        labelLevel = UILabel(frame: CGRect(x: globalWidth/2 - 160, y: 56, width: 320, height: 24))
        labelLevel.textAlignment = NSTextAlignment.center
        labelLevel.textColor = UIColor.colorWithHex("#B3B3B3")
        labelLevel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        tableView.addSubview(labelLevel)
        
        
        labelLeft = UILabel(frame: CGRect(x: 20, y: 258, width: 100, height: 36))
        labelLeft.textAlignment = NSTextAlignment.left
        labelLeft.textColor = UIColor.colorWithHex("#B3B3B3")
        labelLeft.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        labelLeft.isUserInteractionEnabled = true
        tableView.addSubview(labelLeft)
        
        labelRight = UILabel(frame: CGRect(x: globalWidth - 100 - 20, y: 258, width: 100, height: 36))
        labelRight.textAlignment = NSTextAlignment.right
        labelRight.textColor = UIColor.colorWithHex("#B3B3B3")
        labelRight.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        labelRight.isUserInteractionEnabled = true
        tableView.addSubview(labelRight)
        
        getPlankton()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableViewPet {
            let _y = tableViewPet.contentOffset.y
            current = max(min(Int(floor((_y+36)/72)), dataArray.count - 1), 0)
            if pre != current {
                setPetTitle()
                tableViewPet.reloadData()
                pre = current
            }
        }
    }
    
    func setPetTitle() {
        if dataArray.count > 0 {
            let data = dataArray[current] as! NSDictionary
            let name = data.stringAttributeForKey("name")
            let level = data.stringAttributeForKey("level")
            let owned = data.stringAttributeForKey("owned")
            let image = data.stringAttributeForKey("image")
            labelName.text = name
            if owned == "1" {   // 拥有这个宠物
                labelLevel.text = "Lv \(level)"
                if level == "15" {
                    labelLevel.textColor = GoldColor
                    labelName.textColor = GoldColor
                    self.btnUpgrade.bgColor = BgColor.grey
                } else {
                    labelLevel.textColor = UIColor.colorWithHex("#B3B3B3")
                    labelName.textColor = UIColor.colorWithHex("#333333")
                    self.btnUpgrade.bgColor = BgColor.blue
                }
            } else {    // 没有拥有这个宠物
                labelLevel.text = "--"
                labelLevel.textColor = UIColor.colorWithHex("#B3B3B3")
                labelName.textColor = UIColor.colorWithHex("#333333")
                self.btnUpgrade.bgColor = BgColor.grey
            }
            labelLeft.text = "礼物：\(energy)"
            labelLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onGift)))
            
            if owned == "1" {
                imageView.setPet("http://img.nian.so/pets/\(image)!d")
            } else {
                let imageGrey = SAReplace(image, before: ".png", after: "@Grey.png")
                imageView.setPet("http://img.nian.so/pets/\(imageGrey)!d")
            }
        }
    }
    
    func getPlankton() {
        
        /* 从服务器获取浮游的数量
        ** 当数量少于本地时候，同步本地的数量到服务器
        ** 只是当前的过度方案，只后要直接走服务器
        */
        let _plankton = Cookies.get("plankton") as? String
        let plankton = _plankton == nil ? "0" : _plankton!
        labelRight.text = "浮游：\(plankton)"
        labelRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onPlankton)))
        
        Api.getPlankton() { json in
            if let j = json as? NSDictionary {
                let data = j.stringAttributeForKey("data")
                let numLocal = Int(plankton)
                let numRemote = Int(data)
                if numLocal != nil && numRemote != nil && numLocal > numRemote {
                    for _ in 0...(numLocal! - numRemote! - 1) {
                        Api.getPlanktonIncrease() { json in }
                    }
                } else {
                    Cookies.set(data as AnyObject?, forKey: "plankton")
                    self.labelRight.text = "浮游：\(data)"
                }
            }
        }
    }
    
    @objc func toUpgrade() {
        if dataArray.count > 0 {
            let data = dataArray[current] as! NSDictionary
            let id = Int(data.stringAttributeForKey("id"))!
            let level = data.stringAttributeForKey("level")
            let name = data.stringAttributeForKey("name")
            let owned = data.stringAttributeForKey("owned")
            if owned == "1" && level != "15" {
                var coin = 0
                if let _level = Int(level) {
                    if _level < 5 {
                        coin = 5
                    } else if _level < 10 {
                        coin = 10
                    } else {
                        coin = 15
                    }
                }
                upgradeView = NIAlert()
                upgradeView!.delegate = self
                upgradeView!.tag = id
                upgradeView!.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "升级", "要花费 \(coin) 念币使\n\(name)升级吗？", ["嗯！", "不要"]],
                    forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                upgradeView!.showWithAnimation(.flip)
            }
        }
    }
}
