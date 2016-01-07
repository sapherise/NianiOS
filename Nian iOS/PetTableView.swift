//
//  PetTableView.swift
//  Nian iOS
//
//  Created by Sa on 15/7/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController: UITableViewDelegate, UITableViewDataSource {
    func load() {
        let jsonCache: AnyObject? = Cookies.get("pets")
        if jsonCache != nil {
            if let err = jsonCache!.objectForKey("error") as? NSNumber {
                if err == 0 {
                    self.dataArray.removeAllObjects()
                    let data = jsonCache!.objectForKey("data") as! NSDictionary
                    let arr = data.objectForKey("pets") as! NSArray
                    self.energy = Int(data.stringAttributeForKey("energy"))!
                    for item in arr {
                        self.dataArray.addObject(item)
                    }
                    labelLeft.hidden = true
                    self.tableViewPet.reloadData()
                    self.setPetTitle()
                }
            }
        }
        
        Api.getAllPets() { json in
            if json != nil {
                self.labelLeft.hidden = false
                Cookies.set(json, forKey: "pets")
                if let err = json!.objectForKey("error") as? NSNumber {
                    if err == 0 {
                        self.dataArray.removeAllObjects()
                        let data = json!.objectForKey("data") as! NSDictionary
                        let arr = data.objectForKey("pets") as! NSArray
                        self.energy = Int(data.stringAttributeForKey("energy"))!
                        for item in arr {
                            self.dataArray.addObject(item)
                        }
                        self.tableViewPet.reloadData()
                        self.setPetTitle()
                    } else {
                        self.showTipText("加载宠物列表失败了...")
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 320
        } else {
            return NORMAL_WIDTH
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let c = UITableViewCell()
            c.addSubview(tableViewPet)
            return c
        } else {
            let c = tableViewPet.dequeueReusableCellWithIdentifier("PetCell", forIndexPath: indexPath) as! PetCell
            let data = dataArray[indexPath.row] as? NSDictionary
            c.info = data
            c._layoutSubviews()
            if indexPath.row == current {
                c.imgView.image = nil
//                c.imgView.hidden = true 
            }
            c.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            return c
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.tableViewPet {
            if abs(indexPath.row - current) <= 1 {
                showPetInfo()
            }
        }
    }
}