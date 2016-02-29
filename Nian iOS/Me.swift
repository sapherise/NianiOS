//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var Id:String = ""
    var numLeft: String = ""
    var numMiddel: String = ""
    var numRight: String = ""
    var labelNav = UILabel()
    
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
        load()
    }
    
    func Letter(noti: NSNotification) {
        self.load()
    }
    
    func setupViews() {
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = UIColor.NavColor()
        labelNav.frame = CGRectMake(0, 20, globalWidth, 44)
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.text = "消息"
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
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: "LetterCell")
        self.tableView!.registerNib(nib2, forCellReuseIdentifier: "MeCellTop")
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.view.addSubview(self.tableView!)
    }
    
    func SALoadData() {
        Api.postLetter() { json in
            self.tableView.headerEndRefreshing()
            if json != nil {
                if let data = json as? NSDictionary {
                    self.numLeft = data.stringAttributeForKey("notice_reply")
                    self.numMiddel = data.stringAttributeForKey("notice_like")
                    self.numRight = data.stringAttributeForKey("notice_news")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func load(){
        self.dataArray.removeAllObjects()
        let arr = RCIMClient.sharedRCIMClient().getConversationList([RCConversationType.ConversationType_PRIVATE.rawValue])
        for item in arr {
            if let conversation = item as? RCConversation {
                if let _json = conversation.jsonDict {
                    let json = _json as NSDictionary
                    
                    /* 根据类型是图片还是文字，来决定内容是什么 */
                    var content = json.stringAttributeForKey("content")
                    if conversation.objectName == "RC:ImgMsg" {
                        content = "[图片]"
                    }
                    
                    let extra = json.stringAttributeForKey("extra")
                    if let nameSelf = Cookies.get("user") as? String {
                        var name = SAReplace(extra, before: nameSelf, after: "")
                        name = SAReplace(name as String, before: ":", after: "")
                        let id = conversation.targetId
                        let unread = conversation.unreadMessageCount
                        let time = ("\(conversation.sentTime / Int64(1000))" as NSString).doubleValue
                        let lastdate = V.absoluteTime(time)
                        let e = ["id": id, "title": name, "content": content, "unread": "\(unread)", "lastdate": lastdate]
                        self.dataArray.addObject(e)
                    }
                }
            }
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
        RCIMClient.sharedRCIMClient().clearMessages(RCConversationType.ConversationType_PRIVATE, targetId: id)
        RCIMClient.sharedRCIMClient().removeConversation(RCConversationType.ConversationType_PRIVATE, targetId: id)
        load()
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
            let c: LetterCell! = tableView.dequeueReusableCellWithIdentifier("LetterCell", forIndexPath: indexPath) as? LetterCell
            c.data = dataArray[indexPath.row] as! NSDictionary
            c.setup()
            return c
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
            let data = self.dataArray[indexPath.row] as! NSDictionary
            let mutableData = NSMutableDictionary(dictionary: data)
            mutableData.setValue("0", forKey: "unread")
            dataArray.replaceObjectAtIndex(indexPath.row, withObject: mutableData)
            tableView.reloadData()
            let vc = CircleController()
            if let id = Int(data.stringAttributeForKey("id")) {
                let title = data.stringAttributeForKey("title")
                vc.id = id
                vc.name = title
                self.navigationController?.pushViewController(vc, animated: true)
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
                self.textColor = UIColor.HighlightColor()
            }
        }else{
            self.textColor = UIColor.blackColor()
        }
    }
}