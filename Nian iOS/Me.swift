//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let identifier = "LetterCell"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var Id:String = ""
    var numLeft: String = ""
    var numMiddel: String = ""
    var numRight: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
    }
    
    func noticeShare() {
        self.tableView.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "noticeShare", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Letter", object: nil)
        navShow()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "noticeShare", name: "noticeShare", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Letter:", name: "Letter", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
        SALoadLetter()
    }
    
    func Letter(noti: NSNotification) {
        self.SALoadLetter()
    }
    
    func setupViews() {
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        let labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "消息"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        let nib = UINib(nibName:"LetterCell", bundle: nil)
        let nib2 = UINib(nibName:"MeCellTop", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView!.registerNib(nib2, forCellReuseIdentifier: "MeCellTop")
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.view.addSubview(self.tableView!)
    }
    
    func SALoadData() {
        Api.postLetter() { json in
            self.tableView.headerEndRefreshing()
            if json != nil {
                self.numLeft = json!.objectForKey("notice_reply") as! String
                self.numMiddel = json!.objectForKey("notice_like") as! String
                self.numRight = json!.objectForKey("notice_news") as! String
                self.tableView.reloadData()
            }
        }
    }
    
    var isLoadingLetter = false
    func SALoadLetter(){
        if !isLoadingLetter {
            isLoadingLetter = true
            let safeuid = SAUid()
            let safename = Cookies.get("user") as? String
            let (resultCircle, _) = SD.executeQuery("SELECT circle FROM `letter` where owner = '\(safeuid)' GROUP BY circle ORDER BY lastdate DESC")
            self.dataArray.removeAllObjects()
            for row in resultCircle {
                let id = (row["circle"]?.asString())!
                var title = "玩家 #\(id)"
                let (resultDes, _) = SD.executeQuery("select * from letter where circle = '\(id)' and owner = '\(safeuid)' order by id desc limit 1")
                if resultDes.count > 0 {
                    for row in resultDes {
                        title = (row["name"]?.asString())!
                    }
                }else if safeuid == id {
                    title = safename!
                }
                let data = NSDictionary(objects: [id, title], forKeys: ["id", "title"])
                self.dataArray.addObject(data)
            }
            back {
                self.tableView.reloadData()
                if self.dataArray.count == 0 {
                    let viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                    let viewQuestion = viewEmpty(globalWidth, content: "这里是空的\n要去给好友写信吗")
                    viewQuestion.setY(70)
                    let btnGo = UIButton()
                    btnGo.setButtonNice("  嗯！")
                    btnGo.setX(globalWidth/2-50)
                    btnGo.setY(viewQuestion.bottom())
                    btnGo.addTarget(self, action: "onBtnGoClick", forControlEvents: UIControlEvents.TouchUpInside)
                    viewHeader.addSubview(viewQuestion)
                    viewHeader.addSubview(btnGo)
                    self.tableView.tableFooterView = viewHeader
                }else{
                    self.tableView.tableFooterView = UIView()
                }
                self.isLoadingLetter = false
            }
        }
    }
    
    func onBtnGoClick() {
        let LikeVC = LikeViewController()
        LikeVC.Id = SAUid()
        LikeVC.urlIdentify = 1
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let data = self.dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        SQLLetterDelete(id)
        SALoadLetter()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MeCellTop", forIndexPath: indexPath) as? MeCellTop
            cell!.numLeft.text = self.numLeft
            cell!.numMiddle.text = self.numMiddel
            cell!.numRight.text = self.numRight
            cell!.numLeft.setColorful()
            cell!.numMiddle.setColorful()
            cell!.numRight.setColorful()
            cell!.viewLeft.tag = 1
            cell!.viewMiddle.tag = 2
            cell!.viewRight.tag = 3
            cell!.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
            cell!.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
            cell!.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
            return cell!
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? LetterCell
            let index = indexPath.row
            let data = self.dataArray[index] as! NSDictionary
            cell!.data = data
            if let tag = Int(data.stringAttributeForKey("uid")) {
                cell!.imageHead.tag = tag
                cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick:"))
            }
            return cell!
        }
    }
    
    func onTopClick(sender: UIGestureRecognizer) {
        let MeNextVC = MeNextViewController()
        
        if let tag = sender.view?.tag {
            if tag == 1 {
                self.numLeft = "0"
                MeNextVC.msgType = "reply"  /* 回应 */
            }else if tag == 2 {
                self.numMiddel = "0"
                MeNextVC.msgType = "like"  /* 按赞 */
            }else if tag == 3 {
                self.numRight = "0"
                MeNextVC.msgType = "notify" /* 通知 */
            }
            MeNextVC.tag = tag
            self.navigationController?.pushViewController(MeNextVC, animated: true)
        }
        if let v = sender.view {
            let views:NSArray = v.subviews
            for view:AnyObject in views {
                if NSStringFromClass(view.classForCoder) == "UILabel"  {
                    let l = view as! UILabel
                    if l.frame.origin.y == 25 {
                        l.text = "0"
                        l.textColor = UIColor.blackColor()
                    }
                }
            }
        }
    }
    
    func onUserClick(sender:UIGestureRecognizer) {
        let tag = sender.view!.tag
        let UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
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
        if indexPath.section == 0 {
            return 75
        }else{
            return 81
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let index = indexPath.row
            let data = self.dataArray[index] as! NSDictionary
            let letterVC = CircleController()
            if let id = Int(data.stringAttributeForKey("id")) {
                let title = data.stringAttributeForKey("title")
                letterVC.ID = id
                letterVC.circleTitle = title
                self.navigationController?.pushViewController(letterVC, animated: true)
                
                let safeuid = SAUid()
                SD.executeChange("update letter set isread = 1 where circle = \(id) and isread = 0 and owner = '\(safeuid)'")
                SALoadLetter()
            }
        }
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback {
            self.SALoadData()
        }
    }
}

extension UILabel {
    func setColorful(){
        if let content = Int(self.text!) {
            if content == 0 {
                self.textColor = UIColor.blackColor()
            }else{
                self.textColor = SeaColor
            }
        }else{
            self.textColor = UIColor.blackColor()
        }
    }
}