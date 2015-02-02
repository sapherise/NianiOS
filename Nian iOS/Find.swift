//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FindViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView:UITableView!
    var tableViewPhone: UITableView!
    var viewPromo: UIView!
    var dataArray = NSMutableArray()
    var dataArrayPhone = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var viewFindCellTop: FindCellTop!
    var imagePromo: UIImageView!
    
    var arr = ["weibo", "phone", "recommend"]
    var arrSelected = ["weibo_s", "phone_s", "recommend_s"]
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "发现好友"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(navView)
        
        // 创建三个舞台
        self.tableView = setupTable()
        self.tableViewPhone = setupTable()
        self.tableViewPhone.frame.origin.x = globalWidth
        self.viewPromo = UIView(frame: CGRectMake(globalWidth * 2, 64 + 75, globalWidth, globalHeight - 64 - 75))
        imagePromo = UIImageView(frame: CGRectMake(globalWidth/2-80, globalHeight/2-200, 160, 160))
        imagePromo.backgroundColor = IconColor
        imagePromo.layer.masksToBounds = true
        imagePromo.layer.cornerRadius = 8
        self.viewPromo.addSubview(imagePromo)
        var btnPromo = UIButton()
        btnPromo.setButtonNice("发给伙伴")
        btnPromo.frame = CGRectMake(globalWidth/2-50, imagePromo.bottom() + 16, 100, 36)
        btnPromo.addTarget(self, action: "sharePromo", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewPromo.addSubview(btnPromo)
        self.view.addSubview(self.viewPromo)
        
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        Api.getUserTop(safeuid.toInt()!){ json in
            if json != nil {
                var data  = json!["user"] as NSDictionary
                var name = data.stringAttributeForKey("name")
                var coverURL = data.stringAttributeForKey("cover")
                var urlHead = "http://img.nian.so/head/\(safeuid).jpg!dream"
                var urlCover = "http://img.nian.so/cover/\(coverURL)!cover"
                var imageHead = UIImageView(frame: CGRectMake(60, 45, 40, 40))
                imageHead.layer.cornerRadius = 20
                imageHead.layer.masksToBounds = true
                imageHead.setImage(urlHead, placeHolder: IconColor)
                self.imagePromo.contentMode = UIViewContentMode.ScaleAspectFill
                self.imagePromo.addSubview(imageHead)
                if coverURL == "" {
                    self.imagePromo.image = UIImage(named: "bg")
                }else{
                    self.imagePromo.setImage(urlCover, placeHolder: IconColor, bool: false)
                }
                var labelName = UILabel(frame: CGRectMake(0, imageHead.bottom()+10, 160, name.stringHeightWith(13, width: 160)))
                labelName.text = name
                labelName.textAlignment = NSTextAlignment.Center
                labelName.textColor = UIColor.whiteColor()
                labelName.font = UIFont.boldSystemFontOfSize(13)
                labelName.numberOfLines = 0
                self.imagePromo.addSubview(labelName)
                var textPromo = "来念找我玩"
                var label = UILabel(frame: CGRectMake(0, labelName.bottom()+5, 160, textPromo.stringHeightWith(11, width: 160)))
                label.text = textPromo
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                label.font = UIFont.systemFontOfSize(11)
                label.numberOfLines = 0
                self.imagePromo.addSubview(label)
            }
        }
        
        
        
        // 顶部
        var nib2 = NSBundle.mainBundle().loadNibNamed("FindCellTop", owner: self, options: nil) as NSArray
        self.viewFindCellTop = nib2.objectAtIndex(0) as FindCellTop
        self.viewFindCellTop.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
        self.viewFindCellTop.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
        self.viewFindCellTop.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
        self.viewFindCellTop.imageLeft.image = UIImage(named: arrSelected[0])
        self.viewFindCellTop.frame.origin.y = 64
        self.view.addSubview(self.viewFindCellTop)
        
        // 底部
        self.tableView.tableFooterView = setupFooter("连接微博", funcButton: "onWeiboClick")
        self.tableViewPhone.tableFooterView = setupFooter("开启通讯录", funcButton: "onPhoneClick:")
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.tableViewPhone)
    }
    
    func onTopClick(sender:UIGestureRecognizer){
        self.viewFindCellTop.imageLeft.image = UIImage(named: arr[0])
        self.viewFindCellTop.imageMiddle.image = UIImage(named: arr[1])
        self.viewFindCellTop.imageRight.image = UIImage(named: arr[2])
        var tag = sender.view!.tag
        if tag == 1 {
            self.tableView.hidden = false
            self.viewFindCellTop.imageLeft.image = UIImage(named: arrSelected[0])
        }else if tag == 2 {
            self.tableViewPhone.hidden = false
            self.viewFindCellTop.imageMiddle.image = UIImage(named: arrSelected[1])
        }else if tag == 3 {
            self.viewFindCellTop.imageRight.image = UIImage(named: arrSelected[2])
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.tableView.frame.origin.x = CGFloat(1 - tag) * globalWidth
            self.tableViewPhone.frame.origin.x = CGFloat(2 - tag) * globalWidth
            self.viewPromo.frame.origin.x = CGFloat(3 - tag) * globalWidth
        }) { (Bool) -> Void in
            if tag == 1 {
                self.tableView.hidden = false
            }else if tag == 2 {
                self.tableView.hidden = true
                self.tableViewPhone.hidden = false
            }else if tag == 3 {
                self.tableView.hidden = true
                self.tableViewPhone.hidden = true
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.dataArray.count
        }else{
            return self.dataArrayPhone.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FindCell", forIndexPath: indexPath) as? FindCell
        var index = indexPath.row
        if tableView == self.tableView {
            var data = self.dataArray[index] as NSDictionary
            cell!.data = data
            cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick:"))
            return cell!
        }else{
            var data = self.dataArrayPhone[index] as NSDictionary
            cell!.data = data
            cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick:"))
            return cell!
        }
    }
    
    func onUserClick(sender:UIGestureRecognizer) {
        var tag = sender.view!.tag
        var UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onWeiboClick() {
        var request: WBAuthorizeRequest! = WBAuthorizeRequest.request() as WBAuthorizeRequest
        request.redirectURI = "https://api.weibo.com/oauth2/default.html"
        request.scope = "follow_app_official_microblog"
        WeiboSDK.sendRequest(request)
    }
    
    // 获得通讯录权限
    func onPhoneClick(sender: UIButton) {
        var addressBook = ContactsHelper()
        var status = addressBook.determineStatus()
        if status {
            self.transPhone()
        }else{
            sender.setTitle("发现通讯录", forState: UIControlState.allZeros)
            sender.removeTarget(self, action: "onPhoneClick:", forControlEvents: UIControlEvents.TouchUpInside)
            sender.addTarget(self, action: "onPhoneFindClick", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    // 搜索通讯录
    func onPhoneFindClick() {
        var addressBook = ContactsHelper()
        var status = addressBook.determineStatus()
        if status {
            self.transPhone()
        }else{
            var viewEm = viewEmpty(globalWidth, content: "失败了\n念不能获得你的通讯录")
            var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
            viewEm.setY(40)
            viewHolder.addSubview(viewEm)
            self.tableViewPhone.tableFooterView = viewHolder
        }
    }
    
    // 将通讯录提交到数据库
    func transPhone() {
        self.viewLoadingShow()
        var addressBook = ContactsHelper()
        addressBook.createAddressBook()
        var list = addressBook.getContactNames()
        Api.postPhone(list) { json in
            self.viewLoadingHide()
            if json != nil {
                var arr = json!["items"] as NSArray
                self.dataArrayPhone.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArrayPhone.addObject(data)
                }
                self.tableViewPhone!.reloadData()
                if self.dataArrayPhone.count == 0 {
                    var viewEm = viewEmpty(globalWidth, content: "手机里的好友们\n还没有来玩念")
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                    viewEm.setY(40)
                    viewHolder.addSubview(viewEm)
                    self.tableViewPhone.tableFooterView = viewHolder
                }else{
                    self.tableViewPhone.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 71
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var letterVC = LetterController()
        if let id = data.stringAttributeForKey("uid").toInt() {
            letterVC.ID = id
            self.navigationController?.pushViewController(letterVC, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "weibo", object:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weibo:", name: "weibo", object: nil)
    }
    
    func weibo(sender: NSNotification) {
        self.viewLoadingShow()
        var object: NSArray? = sender.object as? NSArray
        if object != nil {
            var uid = "\(object![0])"
            var token = "\(object![1])"
            Api.getWeibo(uid, Token: token) { json in
                self.viewLoadingHide()
                if json != nil {
                    var arr = json!["items"] as NSArray
                    self.dataArray.removeAllObjects()
                    for data : AnyObject  in arr{
                        self.dataArray.addObject(data)
                    }
                    self.tableView!.reloadData()
                    if self.dataArray.count == 0 {
                        var viewEm = viewEmpty(globalWidth, content: "微博上的好友们\n还没有来玩念")
                        var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                        viewEm.setY(40)
                        viewHolder.addSubview(viewEm)
                        self.tableView.tableFooterView = viewHolder
                    }else{
                        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 50))
                    }
                }
            }
        }
    }
    
    func setupTable() -> UITableView {
        var theTableView = UITableView(frame:CGRectMake(0, 64 + 75, globalWidth, globalHeight - 64 - 75))
        theTableView.delegate = self
        theTableView.dataSource = self
        theTableView.backgroundColor = BGColor
        theTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"FindCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "FindCell")
        return theTableView
    }
    
    func setupFooter(textButton: String, funcButton: Selector) -> UIView {
        var viewFooter = UIView(frame: CGRectMake(0, 0, globalWidth, 120))
        var btnConnect = UIButton()
        btnConnect.setButtonNice(textButton)
        viewFooter.addSubview(btnConnect)
        btnConnect.center = viewFooter.center
        btnConnect.addTarget(self, action: funcButton, forControlEvents: UIControlEvents.TouchUpInside)
        return viewFooter
    }
    
    func getImageFromView(view: UIView)->UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 8);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func sharePromo() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var url:NSURL = NSURL(string: "http://m.nian.so/user/\(safeuid)")!
        var image = self.getImageFromView(self.imagePromo)
        let activityView = UIActivityViewController(
            activityItems: [image, "来念上找我玩", url],
            applicationActivities: [WeChatSessionActivity(), WeChatMomentsActivity()])
        self.presentViewController(activityView, animated: true, completion: nil)
    }
    
}