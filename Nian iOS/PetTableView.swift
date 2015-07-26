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
        Api.getAllPets() { json in
            if json != nil {
                if let err = json!.objectForKey("error") as? NSNumber {
                    if err == 0 {
                        var data = json!.objectForKey("data") as! NSDictionary
                        var arr = data.objectForKey("pets") as! NSArray
                        self.energy = data.stringAttributeForKey("energy").toInt()!
                        for item in arr {
                            self.dataArray.addObject(item)
                        }
                        self.tableViewPet.reloadData()
                        self.setPetTitle()
                    } else {
                        self.view.showTipText("加载宠物列表失败了...", delay: 2)
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
            var c = UITableViewCell()
            c.addSubview(tableViewPet)
            return c
        } else {
            var c = tableViewPet.dequeueReusableCellWithIdentifier("PetCell", forIndexPath: indexPath) as! PetCell
            var data = dataArray[indexPath.row] as? NSDictionary
            c.info = data
            c._layoutSubviews()
            if indexPath.row == current {
                imageView.image = c.imgView.image
                c.imgView.image = nil
            }
            c.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            return c
        }
    }
}