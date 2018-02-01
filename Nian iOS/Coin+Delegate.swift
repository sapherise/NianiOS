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
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let c: CoinProductTop! = tableView.dequeueReusableCell(withIdentifier: "CoinProductTop", for: indexPath) as? CoinProductTop
            c.setup()
            return c
        } else {
            let c: CoinProductCell! = tableView.dequeueReusableCell(withIdentifier: "CoinProductCell", for: indexPath) as? CoinProductCell
            c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
            c.num = (indexPath as NSIndexPath).row
            c.numMax = dataArray.count
            c.setup()
            return c
        }
    }
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 16))
            v.backgroundColor = UIColor.GreyBackgroundColor()
            return v
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 16
        }
        return 0
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            if SAUid() == "171264" {
                return 220
            }
            return 261
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            if let data = dataArray[(indexPath as NSIndexPath).row] as? NSDictionary {
                let title = data.stringAttributeForKey("title")
                if title == "表情" {
                    let vc = ProductList()
                    vc.name = title
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if title == "插件" {
                    let vc = ProductList()
                    vc.name = title
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if title == "会员" {
                    let vc = Product()
                    vc.type = Product.ProductType.pro
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
