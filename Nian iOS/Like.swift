//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let identifier = "like"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var urlIdentify:Int = 0
    var navView:UIView!
    var circleID:String = "0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView?.headerBeginRefreshing()
    }
    
    func setupViews() {
        self.navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.navView)
        
        self.tableView = UITableView(frame:CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = UIColor.BackgroundColor()
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        let nib = UINib(nibName:"LikeCell", bundle: nil)
        
        self.tableView!.register(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView!)
        
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        if self.urlIdentify == 0 {
            titleLabel.text = "赞过"
        }else if self.urlIdentify == 1 {
            titleLabel.text = "关注"
        }else if self.urlIdentify == 2 {
            titleLabel.text = "听众"
        }else if self.urlIdentify == 3 {
            titleLabel.text = "赞过记本"
        }
        titleLabel.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
    }
    
    
    func loadData(){
        let url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                let arr = data.object(forKey: "items") as! NSArray
                for data in arr{
                    self.dataArray.add(data)
                }
                self.tableView!.reloadData()
                self.tableView!.footerEndRefreshing()
                self.page += 1
                if ( data.object(forKey: "total") as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
            }
        })
    }
    func SAReloadData(){
        self.tableView!.setFooterHidden(false)
        self.page = 0
        let url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                if ( data.object(forKey: "total") as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
                let arr = data.object(forKey: "items") as! NSArray
                self.dataArray.removeAllObjects()
                for data in arr{
                    self.dataArray.add(data)
                }
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
                self.page += 1
            }
        })
    }
    
    
    func urlString()->String{
        let safeuid = SAUid()
        if self.urlIdentify == 0 {
            return "http://nian.so/api/like2.php?page=\(page)&id=\(Id)&myuid=\(safeuid)"
        }else if self.urlIdentify == 1 {
            return "http://nian.so/api/user_fo_list2.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }else if self.urlIdentify == 2 {
            return "http://nian.so/api/user_foed_list2.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }else if self.urlIdentify == 3{
            return "http://nian.so/api/like_dream.php?page=\(page)&id=\(Id)&myuid=\(safeuid)"
        }else{
            return "http://nian.so/api/user_fo_list2.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? LikeCell
        let index = (indexPath as NSIndexPath).row
        let data = self.dataArray[index] as! NSDictionary
        cell!.data = data
        cell!.urlIdentify = self.urlIdentify
        cell!.circleID = self.circleID
        cell!.ownerID = self.Id
        cell!._layoutSubviews()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  71
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
        self.tableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    
}
