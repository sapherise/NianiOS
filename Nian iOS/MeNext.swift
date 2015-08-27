//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeNextViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "me"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var tag: Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView?.headerBeginRefreshing()
    }
    
    func setupViews() {
        viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        var textTitle = "消息"
        if self.tag == 1 {
            textTitle = "回应"
        }else if self.tag == 2 {
            textTitle = "按赞"
        }else if self.tag == 3 {
            textTitle = "通知"
        }
        labelNav.text = textTitle
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"MeCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView!)
    }
    
    
    func loadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                if ( data.objectForKey("total") as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
                var arr = data.objectForKey("items") as! NSArray
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.footerEndRefreshing()
                self.page++
            }
        })
    }
    func SAReloadData(){
        self.page = 0
        var url = urlString()
        self.tableView!.setFooterHidden(false)
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                if ( data.objectForKey("total") as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
                var arr = data.objectForKey("items") as! NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
                self.page++
            }
        })
    }
    
    
    func urlString()->String{
        var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        return "http://nian.so/api/me_next.php?page=\(page)&uid=\(safeuid)&shell=\(safeshell)&&tag=\(self.tag)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? MeCell
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        cell!.data = data
        cell!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
        cell!.imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamClick:"))
        if indexPath.row == self.dataArray.count - 1 {
            cell!.viewLine.hidden = true
        }else{
            cell!.viewLine.hidden = false
        }
        return cell!
    }
    
    func onDreamClick(sender:UIGestureRecognizer){
        var tag = sender.view!.tag
        var dreamVC = DreamViewController()
        dreamVC.Id = "\(tag)"
        self.navigationController!.pushViewController(dreamVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        return  MeCell.cellHeightByData(data)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        var cid = data.stringAttributeForKey("cid")
        var uid = data.stringAttributeForKey("cuid")
        var user = data.stringAttributeForKey("cname")
        var lastdate = data.stringAttributeForKey("lastdate")
        var dreamtitle = data.stringAttributeForKey("dreamtitle")
        var content = data.stringAttributeForKey("content")
        var dream = data.stringAttributeForKey("dream")
        var type = data.stringAttributeForKey("type")
        var step = data.stringAttributeForKey("step") as String
        
        var DreamVC = DreamViewController()
        var UserVC = PlayerViewController()
        var BBSVC = BBSViewController()
        var StepVC = SingleStepViewController()
        if type == "0" {    //在你的记本留言
            if step != "0" {
                StepVC.Id = step
                self.navigationController!.pushViewController(StepVC, animated: true)
            }else{
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        }else if type == "1" {  //在某个记本提及你
            if step != "0" {
                StepVC.Id = step
                self.navigationController!.pushViewController(StepVC, animated: true)
            }else{
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        }else if type == "2" {  //赞了你的记本
            DreamVC.Id = dream
            self.navigationController!.pushViewController(DreamVC, animated: true)
        }else if type == "3" {  //关注了你
            UserVC.Id = uid
            self.navigationController!.pushViewController(UserVC, animated: true)
        }else if type == "4" {  //参与了你的话题
            BBSVC.Id = dream
            BBSVC.isAsc = false
            self.navigationController!.pushViewController(BBSVC, animated: true)
        }else if type == "5" {  //在某个话题提及你
            BBSVC.Id = dream
            BBSVC.isAsc = false
            self.navigationController!.pushViewController(BBSVC, animated: true)
            //BBS要倒叙
        }else if type == "6" {  //为你更新了记本
            DreamVC.Id = dream
            self.navigationController!.pushViewController(DreamVC, animated: true)
            //头像不对哦
        }else if type == "7" {  //添加你为小伙伴
            DreamVC.Id = dream
            self.navigationController!.pushViewController(DreamVC, animated: true)
        }else if type == "8" {  //赞了你的进展
            if step != "0" {
                StepVC.Id = step
                self.navigationController!.pushViewController(StepVC, animated: true)
            }else{
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        }
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
        self.tableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.viewBackFix()
    }
    
}