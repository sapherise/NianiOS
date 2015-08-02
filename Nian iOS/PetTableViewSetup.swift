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
            tableView.tableFooterView = viewLevel
        }
        
        tableViewPet.showsVerticalScrollIndicator = false
        tableViewPet.registerNib(UINib(nibName: "PetCell", bundle: nil), forCellReuseIdentifier: "PetCell")
        
        var viewHeader = UIView(frame: CGRectMake(0, 0, 200, (globalWidth - NORMAL_WIDTH)/2))
        viewHeader.userInteractionEnabled = true
        viewHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showPetInfo"))
        var viewFooter = UIView(frame: CGRectMake(0, 0, 200, (globalWidth - NORMAL_WIDTH)/2))
        viewFooter.userInteractionEnabled = true
        viewFooter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showPetInfo"))
        tableViewPet.tableHeaderView = viewHeader
        tableViewPet.tableFooterView = viewFooter
        
        
        imageView = UIImageView(frame: CGRectMake(globalWidth/2 - 60, 96, 120, 120))
        tableView.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.btnUpgrade = NIButton(string: "升级", frame:  CGRectMake((globalWidth - 100)/2, 252, 100, 36))
        self.btnUpgrade.bgColor = BgColor.blue
        self.btnUpgrade.addTarget(self, action: "toUpgrade", forControlEvents: UIControlEvents.TouchUpInside)
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
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableViewPet {
            var _y = tableViewPet.contentOffset.y
            current = max(min(Int(floor((_y+36)/72)), dataArray.count - 1), 0)
            if pre != current {
                setPetTitle()
                tableViewPet.reloadData()
                pre = current
                //----
                
//                for cell in tableViewPet.visibleCells() {
//                    if abs((cell as! PetCell).frame.origin.y - _y - globalWidth/2) < NORMAL_WIDTH/2 {
//                        
//                    }
//                }
                
            }
        }
    }
    
    func setPetTitle() {
        if dataArray.count > 0 {
            var data = dataArray[current] as! NSDictionary
            var name = data.stringAttributeForKey("name")
            var level = data.stringAttributeForKey("level")
            var owned = data.stringAttributeForKey("owned")
            var image = data.stringAttributeForKey("image")
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
                self.btnUpgrade.bgColor = BgColor.grey
            }
            labelLeft.text = "礼物：\(energy)"
            labelLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onGift"))
            if owned == "1" {
                imageView.setImage("http://img.nian.so/pets/\(image)!d", placeHolder: UIColor.clearColor(), bool: false, ignore: true)
            } else {
                imageView.setImageGray("http://img.nian.so/pets/\(image)!d")
            }
        }
    }
    
    func toUpgrade() {
        if dataArray.count > 0 {
            var data = dataArray[current] as! NSDictionary
            var id = data.stringAttributeForKey("id").toInt()!
            var level = data.stringAttributeForKey("level")
            var name = data.stringAttributeForKey("name")
            var owned = data.stringAttributeForKey("owned")
            if owned == "1" && level != "15" {
                var coin = 0
                if let _level = level.toInt() {
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
