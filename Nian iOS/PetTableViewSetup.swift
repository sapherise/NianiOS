//
//  PetTableViewFooter.swift
//  Nian iOS
//
//  Created by Sa on 15/7/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController: NIAlertDelegate {
    func setupTable() {
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        tableViewPet = UITableView()
        tableViewPet.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tableViewPet.frame = CGRectMake(0, 0, globalWidth, 320)
        tableViewPet.separatorStyle = .None
        tableViewPet.delegate = self
        tableViewPet.dataSource = self
        
        if let viewLevel = (NSBundle.mainBundle().loadNibNamed("Level", owner: self, options: nil) as NSArray).objectAtIndex(0) as? LevelView {
            viewLevel.setup()
            tableView.tableFooterView = viewLevel
        }
        
        tableViewPet.showsVerticalScrollIndicator = false
        tableViewPet.registerNib(UINib(nibName: "PetCell", bundle: nil), forCellReuseIdentifier: "PetCell")
        
        let viewHeader = UIView(frame: CGRectMake(0, 0, 200, (globalWidth - NORMAL_WIDTH)/2))
        viewHeader.userInteractionEnabled = true
        viewHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PetViewController.showPetInfo)))
        
        let viewFooter = UIView(frame: CGRectMake(0, 0, 200, (globalWidth - NORMAL_WIDTH)/2))
        viewFooter.userInteractionEnabled = true
        viewFooter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PetViewController.showPetInfo)))
        tableViewPet.tableHeaderView = viewHeader
        tableViewPet.tableFooterView = viewFooter
        
        
        imageView = UIImageView(frame: CGRectMake(globalWidth/2 - 60, 96, 120, 120))
        tableView.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.btnUpgrade = NIButton(string: "升级", frame:  CGRectMake((globalWidth - 100)/2, 252, 100, 36))
        self.btnUpgrade.bgColor = BgColor.blue
        self.btnUpgrade.addTarget(self, action: #selector(PetViewController.toUpgrade), forControlEvents: UIControlEvents.TouchUpInside)
        tableView.addSubview(self.btnUpgrade)
        
        labelName = UILabel(frame: CGRectMake(globalWidth/2 - 160, 32, 320, 24))
        labelName.textAlignment = NSTextAlignment.Center
        labelName.textColor = UIColor.colorWithHex("#333333")
        labelName.font = UIFont.boldSystemFontOfSize(18)
        tableView.addSubview(labelName)
        
        labelLevel = UILabel(frame: CGRectMake(globalWidth/2 - 160, 56, 320, 24))
        labelLevel.textAlignment = NSTextAlignment.Center
        labelLevel.textColor = UIColor.colorWithHex("#B3B3B3")
        labelLevel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        tableView.addSubview(labelLevel)
        
        
        labelLeft = UILabel(frame: CGRectMake(20, 258, 100, 36))
        labelLeft.textAlignment = NSTextAlignment.Left
        labelLeft.textColor = UIColor.colorWithHex("#B3B3B3")
        labelLeft.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        labelLeft.userInteractionEnabled = true
        tableView.addSubview(labelLeft)
        
        labelRight = UILabel(frame: CGRectMake(globalWidth - 100 - 20, 258, 100, 36))
        labelRight.textAlignment = NSTextAlignment.Right
        labelRight.textColor = UIColor.colorWithHex("#B3B3B3")
        labelRight.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        labelRight.userInteractionEnabled = true
        tableView.addSubview(labelRight)
        
        getPlankton()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
                    Cookies.set(data, forKey: "plankton")
                    self.labelRight.text = "浮游：\(data)"
                }
            }
        }
    }
    
    func toUpgrade() {
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
                    forKeys: ["img", "title", "content", "buttonArray"])
                upgradeView!.showWithAnimation(.flip)
            }
        }
    }
}
