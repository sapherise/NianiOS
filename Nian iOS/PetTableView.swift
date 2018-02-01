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
            if let j = jsonCache as? NSDictionary {
                let err = j.stringAttributeForKey("error")
                if err == "0" {
                    self.dataArray.removeAllObjects()
                    let data = jsonCache!.object(forKey: "data") as! NSDictionary
                    let arr = data.object(forKey: "pets") as! NSArray
                    self.energy = Int(data.stringAttributeForKey("energy"))!
                    for item in arr {
                        self.dataArray.add(item)
                    }
                    labelLeft.isHidden = true
                    self.tableViewPet.reloadData()
                    self.setPetTitle()
                }
            }
        }
        
        Api.getAllPets() { json in
            if json != nil {
                self.labelLeft.isHidden = false
                Cookies.set(json, forKey: "pets")
                if let j = json as? NSDictionary {
                    let err = j.stringAttributeForKey("error")
                    if err == "0" {
                        self.dataArray.removeAllObjects()
                        let data = json!.object(forKey: "data") as! NSDictionary
                        let arr = data.object(forKey: "pets") as! NSArray
                        self.energy = Int(data.stringAttributeForKey("energy"))!
                        for item in arr {
                            self.dataArray.add(item)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 320
        } else {
            return NORMAL_WIDTH
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let c = UITableViewCell()
            c.addSubview(tableViewPet)
            return c
        } else {
            let c = tableViewPet.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath) as! PetCell
            let data = dataArray[(indexPath as NSIndexPath).row] as? NSDictionary
            c.info = data
            c._layoutSubviews()
            if (indexPath as NSIndexPath).row == current {
                c.imgView.image = nil
//                c.imgView.hidden = true 
            }
            c.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2))
            return c
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewPet {
            if abs((indexPath as NSIndexPath).row - current) <= 1 {
                showPetInfo()
            }
        }
    }
}
