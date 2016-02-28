//
//  Coin+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 16/2/24.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension Coin {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c: CoinProductTop! = tableView.dequeueReusableCellWithIdentifier("CoinProductTop", forIndexPath: indexPath) as? CoinProductTop
            c.setup()
            return c
        } else {
            let c: CoinProductCell! = tableView.dequeueReusableCellWithIdentifier("CoinProductCell", forIndexPath: indexPath) as? CoinProductCell
            c.data = dataArray[indexPath.row] as! NSDictionary
            c.num = indexPath.row
            c.numMax = dataArray.count
            c.setup()
            return c
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let v = UIView(frame: CGRectMake(0, 0, globalWidth, 16))
            v.backgroundColor = UIColor.GreyBackgroundColor()
            return v
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 16
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 261
        } else {
            return 72
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if let data = dataArray[indexPath.row] as? NSDictionary {
                let title = data.stringAttributeForKey("title")
                if title == "表情" {
                    let vc = ProductList()
                    vc.name = title
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if title == "插件" {
                    print("插件")
                } else {
                    let vc = Product()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}