//
//  AccountBindViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/31/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class AccountBindViewController: UIViewController {
    
    ///
    @IBOutlet weak var tableview: UITableView!
    
    var bindDict: Dictionary<String, AnyObject> = Dictionary()
    
    var userEmail: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewBack()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "账户和绑定设置"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.tableview.registerClass(AccountBindCell.self, forCellReuseIdentifier: "AccountBindCell")
        
        SettingModel.getUserAllOauth() {
            (task, responseObject, error) in
            
            if let _error = error {
                logError("\(_error.localizedDescription)")
            } else {
                let json = JSON(responseObject!)
                
                if json["error"] != 0 {
                    
                } else {
                    self.bindDict = json["data"].dictionaryObject!
                    
                    self.tableview.reloadData()
                }
                
            }
        }
        
    }

}

extension AccountBindViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AccountBindCell") as? AccountBindCell
        
        if cell == nil {
           cell = AccountBindCell.init(style: .Value1, reuseIdentifier: "AccountBindCell")
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.userEmail == "" {
                    cell?.imageView?.image = UIImage(named: "account_mail")
                } else {
                    cell?.imageView?.image = UIImage(named: "account_mail_binding")
                    cell?.detailTextLabel?.text = self.userEmail
                }
                cell?.textLabel?.text = "邮箱"
                cell?.accessoryType = .DisclosureIndicator
                    
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if self.bindDict["wechat"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_wechat_binding")
                    cell?.detailTextLabel?.text = self.bindDict["wechat_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_wechat")
                    cell?.detailTextLabel?.text = ""
                }
                cell?.textLabel?.text = "微信"
                cell?.accessoryType = .DisclosureIndicator
                
            } else if indexPath.row == 1 {
                if self.bindDict["QQ"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_qq_binding")
                    cell?.detailTextLabel?.text = self.bindDict["QQ_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_qq")
                    cell?.detailTextLabel?.text = ""
                }
                cell?.textLabel?.text = "QQ"
                cell?.accessoryType = .DisclosureIndicator
                
            } else if indexPath.row == 2 {
                if self.bindDict["weibo"] as? String == "1" {
                    cell?.imageView?.image = UIImage(named: "account_weibo_binding")
                    cell?.detailTextLabel?.text = self.bindDict["weibo_username"] as? String
                } else {
                    cell?.imageView?.image = UIImage(named: "account_weibo")
                    cell?.detailTextLabel?.text = ""
                }
                cell?.textLabel?.text = "微博"
                cell?.accessoryType = .DisclosureIndicator
                
            }
        }
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 15))
            label.text = "    你可以通过绑定第三方账号，来登录念"
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
            
            return label
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {

            
            } else if indexPath.row == 1 {
            
            
            
            } else if indexPath.row == 2 {
            
            
            
            }
            
        }
        
        
        
        
    }
    
    
}












































