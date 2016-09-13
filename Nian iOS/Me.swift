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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "noticeShare"), object:nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Letter"), object: nil)
        navShow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.noticeShare), name: NSNotification.Name(rawValue: "noticeShare"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.Letter(_:)), name: NSNotification.Name(rawValue: "Letter"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        load()
    }
    
    func Letter(_ noti: Notification) {
        self.load()
    }
    
    func setupViews() {
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        labelNav.frame = CGRect(x: 0, y: 20, width: globalWidth, height: 44)
        labelNav.textColor = UIColor.white
        labelNav.font = UIFont.systemFont(ofSize: 17)
        labelNav.text = "消息"
        labelNav.textAlignment = NSTextAlignment.center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64 - 49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        let nib = UINib(nibName:"LetterCell", bundle: nil)
        let nib2 = UINib(nibName:"MeCellTop", bundle: nil)
        
        self.tableView!.register(nib, forCellReuseIdentifier: "LetterCell")
        self.tableView!.register(nib2, forCellReuseIdentifier: "MeCellTop")
        self.tableView!.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 20))
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
        let arr = RCIMClient.shared().getConversationList([RCConversationType.ConversationType_PRIVATE.rawValue])
        for item in arr! {
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
                        
                        /* 传值为 他人昵称 : 自己昵称 */
                        var arr = extra.components(separatedBy: ":")
                        var name = ""
                        if arr.count > 1 {
                            let a1 = arr[0]
                            let a2 = arr[1]
                            name = a1
                            if a1 == nameSelf {
                                name = a2
                            }
                        }
                        let id = conversation.targetId
                        let unread = conversation.unreadMessageCount
                        let time = ("\(conversation.sentTime / Int64(1000))" as NSString).doubleValue
                        let lastdate = V.absoluteTime(time)
                        let e = ["id": id, "title": name, "content": content, "unread": "\(unread)", "lastdate": lastdate]
                        self.dataArray.add(e)
                    }
                }
            }
        }
        back {
            self.tableView.reloadData()
            if self.dataArray.count == 0 {
                let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 200))
                let viewQuestion = viewEmpty(globalWidth, content: "这里是空的\n要去给好友写信吗")
                viewQuestion.setY(70)
                let btnGo = UIButton()
                btnGo.setButtonNice("  嗯！")
                btnGo.setX(globalWidth/2-50)
                btnGo.setY(viewQuestion.bottom())
                btnGo.addTarget(self, action: #selector(MeViewController.onBtnGoClick), for: UIControlEvents.touchUpInside)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).section == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        RCIMClient.shared().clearMessages(RCConversationType.ConversationType_PRIVATE, targetId: id)
        RCIMClient.shared().remove(RCConversationType.ConversationType_PRIVATE, targetId: id)
        load()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeCellTop", for: indexPath) as? MeCellTop
            cell!.numLeft.text = self.numLeft
            cell!.numMiddle.text = self.numMiddel
            cell!.numRight.text = self.numRight
            cell!.numLeft.setColorful()
            cell!.numMiddle.setColorful()
            cell!.numRight.setColorful()
            cell!.viewLeft.tag = 1
            cell!.viewMiddle.tag = 2
            cell!.viewRight.tag = 3
            cell!.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeViewController.onTopClick(_:))))
            cell!.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeViewController.onTopClick(_:))))
            cell!.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeViewController.onTopClick(_:))))
            return cell!
        }else{
            let c: LetterCell! = tableView.dequeueReusableCell(withIdentifier: "LetterCell", for: indexPath) as? LetterCell
            if dataArray.count > (indexPath as NSIndexPath).row {
                c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
                c.setup()
            }
            return c
        }
    }
    
    func onTopClick(_ sender: UIGestureRecognizer) {
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
            let views:NSArray = v.subviews as NSArray
            for view in views {
                if NSStringFromClass((view as AnyObject).classForCoder) == "UILabel"  {
                    let l = view as! UILabel
                    if l.frame.origin.y == 25 {
                        l.text = "0"
                        l.textColor = UIColor.black
                    }
                }
            }
        }
    }
    
    func onUserClick(_ sender:UIGestureRecognizer) {
        let tag = sender.view!.tag
        let UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onDreamClick(_ sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let dreamVC = DreamViewController()
        dreamVC.Id = "\(tag)"
        self.navigationController!.pushViewController(dreamVC, animated: true)
    }
    
    func userclick(_ sender:UITapGestureRecognizer){
        let UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 75
        }else{
            return 81
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            let data = self.dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
            let mutableData = NSMutableDictionary(dictionary: data)
            mutableData.setValue("0", forKey: "unread")
            dataArray.replaceObject(at: (indexPath as NSIndexPath).row, with: mutableData)
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
                self.textColor = UIColor.black
            }else{
                self.textColor = UIColor.HighlightColor()
            }
        }else{
            self.textColor = UIColor.black
        }
    }
}
