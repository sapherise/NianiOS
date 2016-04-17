//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeNextViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let identifier = "me"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page: Int = 1
    var Id: String = ""
    var tag: Int = 0
    
    /* 更换新的网络接口后新添加的 "reply" or "like" or "notify" */
    var msgType: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView?.headerBeginRefreshing()
    }
    
    func setupViews() {
        viewBack()
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = UIColor.NavColor()
        let labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
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
        let nib = UINib(nibName:"MeCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView!)
    }
    
    
//    func loadData(){
//        let url = urlString()
//        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
//            if data as! NSObject != NSNull(){
//                if ( data.objectForKey("total") as! Int ) < 30 {
//                    self.tableView!.setFooterHidden(true)
//                }
//                let arr = data.objectForKey("items") as! NSArray
//                for data : AnyObject  in arr{
//                    if let _type = (data as! NSDictionary)["type"] as? String {
//                        if Int(_type) < 11 {
//                            self.dataArray.addObject(data)
//                        }
//                    }
//                }
//                self.tableView!.reloadData()
//                self.tableView!.footerEndRefreshing()
//                self.page++
//            }
//        })
//    }
    
    func load(clear: Bool = true) {
        if clear {
            page = 1
        }
        
        Api.getNotify(self.msgType, page: page) { json in
            if json != nil {
                print(json)
                if clear {
                    self.dataArray.removeAllObjects()
                }
                let items = (json!.objectForKey("data") as! NSDictionary).objectForKey("items") as! NSArray
                for item in items {
                    self.dataArray.addObject(item)
                }
                self.tableView?.reloadData()
                self.tableView?.headerEndRefreshing()
                self.tableView?.footerEndRefreshing()
                self.page += 1
            }
        }
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? MeCell
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        cell!.data = data
        cell!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeNextViewController.userclick(_:))))
        if indexPath.row == self.dataArray.count - 1 {
            cell!.viewLine.hidden = true
        }else{
            cell!.viewLine.hidden = false
        }
        cell!._layoutSubviews()
        
        return cell!
    }
    
    func onDreamClick(sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let dreamVC = DreamViewController()
        dreamVC.Id = "\(tag)"
        self.navigationController!.pushViewController(dreamVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        let UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  MeCell.cellHeightByData(data)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let uid = data.stringAttributeForKey("cuid")
        let dream = data.stringAttributeForKey("dream")
        let type = data.stringAttributeForKey("type")
        let step = data.stringAttributeForKey("step")
        let name = data.stringAttributeForKey("cname")
        
        let DreamVC = DreamViewController()
        let UserVC = PlayerViewController()
        let StepVC = SingleStepViewController()
        if type == "0" {    //在你的记本留言
            if step != "0" {
                StepVC.Id = step
                StepVC.name = name
                self.navigationController!.pushViewController(StepVC, animated: true)
            }else{
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        }else if type == "1" {  //在某个记本提及你
            if step != "0" {
                StepVC.Id = step
                StepVC.name = name
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
            self.showTipText("广场下线了 :(")
        }else if type == "5" {  //在某个话题提及你
            self.showTipText("广场下线了 :(")
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
                StepVC.name = name
                self.navigationController!.pushViewController(StepVC, animated: true)
            }else{
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        } else if type == "9" {
        } else if type == "10" {
        } else if type == "11" {    // 回应了话题
            self.showTipText("广场下线了 :(")
        } else if type == "12" {    // 回应了话题回应
            self.showTipText("广场下线了 :(")
        } else if type == "13" {    // 赞了话题
            self.showTipText("广场下线了 :(")
        } else if type == "14" {    // 赞了话题回应
            self.showTipText("广场下线了 :(")
        } else if type == "16" {    // 在回应的回应中提及你
            self.showTipText("广场下线了 :(")
        } else if type == "17" {    // 在回应中提及你
            self.showTipText("广场下线了 :(")
        } else if type == "18" {    // 邀请你加入记本
            DreamVC.Id = dream
            self.navigationController?.pushViewController(DreamVC, animated: true)
        } else if type == "19" {    // 更新了你们的共同记本
            DreamVC.Id = dream
            self.navigationController?.pushViewController(DreamVC, animated: true)
        } else if type == "20" {    // 关注了你的记本
            DreamVC.Id = dream
            self.navigationController?.pushViewController(DreamVC, animated: true)
        } else if type == "21" {    // 奖励了你
            StepVC.Id = step
            StepVC.name = name
            self.navigationController!.pushViewController(StepVC, animated: true)
        }
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.load()
        })
        self.tableView!.addFooterWithCallback({
            self.load(false)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.viewBackFix()
    }
    
}