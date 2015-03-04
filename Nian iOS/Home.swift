//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController, UIApplicationDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, MaskDelegate{
    var myTabbar :UIView?
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var dot:UILabel?
    var dotCircle: UILabel?
    var GameOverView:UIView?
    var animationBool:Int = 0
    var numExplore = 0
    
    var gameoverId:String = ""
    var gameoverHead:String = ""
    var gameoverDays:String = ""
    var gameoverCoin:String = ""
    var gameoverTitle:String = ""
    
    var addView:ILTranslucentView!
    var addStepView:AddStep!
    var viewClose:UIImageView!
    
    let imageArray = ["home","explore","update","letter","bbs"]
    var cancelSheet:UIActionSheet?
    var pointNavY:CGFloat = 0
    var timer:NSTimer?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        SQLInit()
        self.setupViews()
        self.initViewControllers()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/gameover.php")
            if sa != "err" {
                if sa != "0" {      //封号
                    dispatch_async(dispatch_get_main_queue(), {
                        self.gameover(sa)
                    })
                }
            }
        })
        launchTimer()
        self.enter()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onObserveActive:", name: "AppActive", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onObserveDeactive:", name: "AppDeactive", object: nil)
        // 当前账户退出，载入其他账户时使用
        if globalWillReEnter == 1 {
            globalWillReEnter = 0
            self.enter()
            self.loadCircle()
            self.loadLetter()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AppActive", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AppDeactive", object: nil)
    }
    
    func onObserveActive(sender: NSNotification) {
        launchTimer()
    }
    
    func onObserveDeactive(sender: NSNotification) {
        stopTimer()
    }
    
    func launchTimer() {
        if timer != nil {
            return
        }
        noticeDot()
        timer = NSTimer(timeInterval: 15, target: self, selector: "noticeDot", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func noticeDot() {
        if self.dot != nil {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as? String
            var safeshell = Sa.objectForKey("shell") as? String
            if safeuid != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let (resultSet, err) = SD.executeQuery("select id from letter where isread = 0 and owner = '\(safeuid!)'")
                    var a = resultSet.count
                    var b = SAPost("uid=\(safeuid!)&&shell=\(safeshell!)", "http://nian.so/api/dot.php")
                    if let number = b.toInt() {
                        globalNoticeNumber = a + number
                        dispatch_async(dispatch_get_main_queue(), {
                            if globalNoticeNumber != 0 && globalTabBarSelected != 103 {
                                self.dot!.hidden = false
                                UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                                    self.dot!.frame = CGRectMake(globalWidth*0.7+4, 8, 20, 17)
                                    }, completion: { (complete: Bool) in
                                        UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                                            self.dot!.frame = CGRectMake(globalWidth*0.7+4, 10, 20, 15)
                                            }, completion: { (complete: Bool) in
                                                self.dot!.text = "\(globalNoticeNumber)"
                                        })
                                })
                            }else{
                                self.dot!.hidden = true
                            }
                        })
                    }
                })
            }
        }
    }
    
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        
        //总的
        self.view.backgroundColor = BGColor
        self.tabBar.hidden = true
        
        //底部
        self.myTabbar = UIView(frame: CGRectMake(0,globalHeight-49,globalWidth,49)) //x，y，宽度，高度
        self.myTabbar!.backgroundColor = BarColor  //底部的背景色
        self.view.addSubview(self.myTabbar!)
        
        //底部按钮
        var count = 5
        for var index = 0; index < count; index++ {
            var btnWidth = CGFloat(index) * globalWidth * 0.2
            var button  = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            button.frame = CGRectMake(btnWidth, 1, globalWidth * 0.2 ,49)
            button.tag = index+100
            var image = self.imageArray[index]
            let myImage = UIImage(named:"\(image)")
            let myImage2 = UIImage(named:"\(image)_s")
            
            button.setImage(myImage, forState: UIControlState.Normal)
            button.setImage(myImage2, forState: UIControlState.Selected)
            
            button.clipsToBounds = true
            button.addTarget(self, action: "tabBarButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            self.myTabbar?.addSubview(button)
            if index == 0 {
                button.selected = true
            }
        }
        self.dot = UILabel(frame: CGRectMake(globalWidth*0.7+4, 10, 20, 15))
        self.dot!.textColor = UIColor.whiteColor()
        self.dot!.font = UIFont.systemFontOfSize(10)
        self.dot!.textAlignment = NSTextAlignment.Center
        self.dot!.backgroundColor = SeaColor
        self.dot!.layer.cornerRadius = 5
        self.dot!.layer.masksToBounds = true
        self.dot!.hidden = true
        self.dot!.text = "0"
        self.myTabbar!.addSubview(dot!)
        
        self.dotCircle = UILabel(frame: CGRectMake(globalWidth*0.9+4, 10, 20, 15))
        self.dotCircle!.textColor = UIColor.whiteColor()
        self.dotCircle!.font = UIFont.systemFontOfSize(10)
        self.dotCircle!.textAlignment = NSTextAlignment.Center
        self.dotCircle!.backgroundColor = SeaColor
        self.dotCircle!.layer.cornerRadius = 5
        self.dotCircle!.layer.masksToBounds = true
        self.dotCircle!.text = "0"
        self.dotCircle!.hidden = true
        self.myTabbar!.addSubview(dotCircle!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onURL:", name: "AppURL", object: nil)
    }
    
    func gameover(word:String){
        var jsondata = word.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(jsondata!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var gameoverdata: NSDictionary! = json.objectForKey("dream") as NSDictionary
        self.gameoverId = gameoverdata.objectForKey("id") as String
        self.gameoverTitle = gameoverdata.objectForKey("title") as String
        self.gameoverDays = gameoverdata.objectForKey("days") as String
        self.gameoverCoin = gameoverdata.objectForKey("coin") as String
        self.gameoverHead = gameoverdata.objectForKey("image") as String
        
        self.GameOverView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        self.GameOverView!.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        
        var holder = UIView(frame: CGRectMake(globalWidth/2-120, globalHeight / 2 - 130, 240, 260))
        var gameoverHead = UIImageView(frame: CGRectMake(95, 0, 50, 50))
        gameoverHead.setImage("http://img.nian.so/dream/\(self.gameoverHead)!dream", placeHolder: IconColor)
        gameoverHead.layer.cornerRadius = 25
        gameoverHead.layer.masksToBounds = true
        var gameoverLabel = UILabel(frame: CGRectMake(30, 80, 180, 210))
        var gameoverWord = "梦想「\(self.gameoverTitle)」有 \(self.gameoverDays) 天没有更新，已经阵亡。你有 \(self.gameoverCoin) 枚念币，支付念币来继续玩念。"
        gameoverLabel.text = gameoverWord
        gameoverLabel.numberOfLines = 0
        gameoverLabel.font = UIFont.systemFontOfSize(14)
        gameoverLabel.textColor = UIColor.blackColor()
        gameoverLabel.setHeight(gameoverWord.stringHeightWith(14, width: 180))
        //透支
        var textGameover = ""
        if self.gameoverCoin.toInt()! >= 5 {
            textGameover = "支付 5 念币"
        }else{
            textGameover = "预支 5 念币"
        }
        var button1 = gameoverButton(textGameover)
        button1.tag = 1
        button1.addTarget(self, action: "GameOverHide:", forControlEvents: UIControlEvents.TouchUpInside)
        button1.setY(gameoverLabel.bottom()+20)
        var button2 = gameoverButton("切换为每月更新模式")
        button2.addTarget(self, action: "SAMonthly", forControlEvents: UIControlEvents.TouchUpInside)
        button2.setY(button1.bottom()+6)
        holder.addSubview(gameoverHead)
        holder.addSubview(gameoverLabel)
        holder.addSubview(button1)
        // holder.addSubview(button2)
        self.GameOverView?.addSubview(holder)
        self.view.addSubview(self.GameOverView!)
    }
    
    func SAMonthly(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        Api.postUserFrequency(1) { json in
            if json != nil {
                self.navigationItem.rightBarButtonItems = []
                self.GameOverView!.hidden = true
            }
        }
    }
    
    func GameOverHide(sender:UIButton){
        globalWillNianReload = 1
        self.navigationItem.rightBarButtonItems = buttonArray()
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&id=\(self.gameoverId)", "http://nian.so/api/gameover_coin.php")
            if(sa == "1"){
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationItem.rightBarButtonItems = []
                    self.GameOverView!.hidden = true
                })
            }
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.cancelSheet {
            if buttonIndex == 0 {
                self.onViewCloseClick()
            }
        }
    }
    
    func gameoverButton(word:String)->UIButton{
        var button = UIButton(frame: CGRectMake(20, 0, 200, 44))
        button.backgroundColor = UIColor.blackColor()
        button.setTitle(word, forState: UIControlState.Normal)
        button.titleLabel!.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.layer.cornerRadius = 4
        return button
    }
    
    //每个按钮跳转到哪个页面
    func initViewControllers() {
        var storyboardExplore = UIStoryboard(name: "Explore", bundle: nil)
        var NianStoryBoard:UIStoryboard = UIStoryboard(name: "NianViewController", bundle: nil)
        var NianViewController:UIViewController = NianStoryBoard.instantiateViewControllerWithIdentifier("NianViewController") as UIViewController
        var vc1 = NianViewController
        var vc2 = storyboardExplore.instantiateViewControllerWithIdentifier("ExploreViewController") as UIViewController
        var vc3 = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        var vc4 = MeViewController()
        var vc5 = CircleListController()
        self.viewControllers = [vc1, vc2, vc3, vc4, vc5]
        self.customizableViewControllers = nil
        self.selectedIndex = 0
    }
    
    //底部的按钮按下去
    func tabBarButtonClicked(sender:UIButton){
        var index = sender.tag
        for var i = 0;i<5;i++ {
            var button = self.view.viewWithTag(i+100) as UIButton
            if index != 102 {
                if button.tag == index{
                    button.selected = true
                }else{
                    button.selected = false
                }
            }
        }
        if index != 102 {
            self.selectedIndex = index-100
        }
        globalTabBarSelected = index
        
        let idDream = 100
        let idExplore = 101
        let idUpdate = 102
        let idMe = 103
        let idBBS = 104
        
        if index == idExplore {       // 关注
            NSNotificationCenter.defaultCenter().postNotificationName("exploreTop", object:"\(numExplore)")
            numExplore = numExplore + 1
        }else if index == idBBS {     // 梦境
            self.dotCircle!.hidden = true
            self.dotCircle!.text = "0"
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addCircleButton")
            rightButton.image = UIImage(named:"find")
            self.navigationItem.rightBarButtonItem = rightButton
        }else if index == idDream {     // 梦想
            self.navigationItem.rightBarButtonItem = nil
        }else if index == idMe {     // 消息
            self.dot!.hidden = true
            NSNotificationCenter.defaultCenter().postNotificationName("noticeShare", object:"1")
            self.navigationItem.rightBarButtonItem = nil
        }else if index == idUpdate {      // 更新
            self.addStep()
        }
        if index != idExplore {
            numExplore = 0
        }
    }
    
    func addDreamButton(){
        var adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    func addStep(){
        if globalNumberDream == 0 {
            var adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
            self.navigationController!.pushViewController(adddreamVC, animated: true)
        }else{
            self.pointNavY = self.navigationController!.navigationBar.frame.origin.y
            self.navHide(-44)
            self.addView = ILTranslucentView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
            self.addView.translucentAlpha = 1
            self.addView.translucentStyle = UIBarStyle.Default
            self.addView.translucentTintColor = UIColor.clearColor()
            self.addView.backgroundColor = UIColor.clearColor()
            self.addView.alpha = 0
            self.addView.center = CGPointMake(globalWidth/2, globalHeight/2)
            var Tap = UITapGestureRecognizer(target: self, action: "onAddViewClick")
            Tap.delegate = self
            self.addView.addGestureRecognizer(Tap)
            
            var nib = NSBundle.mainBundle().loadNibNamed("AddStep", owner: self, options: nil) as NSArray
            self.addStepView = nib.objectAtIndex(0) as AddStep
            self.addStepView.delegate = self
            self.addStepView.setX(globalWidth/2-140)
            self.addStepView.setY(globalHeight/2-106)
            self.addView.addSubview(self.addStepView)
            
            self.viewClose = UIImageView(frame: CGRectMake(10, 20, 44, 44))
            self.viewClose.image = UIImage(named: "closeBlue")
            self.viewClose.contentMode = UIViewContentMode.Center
            self.viewClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCloseConfirm"))
            self.viewClose.userInteractionEnabled = true
            self.view.window!.addSubview(self.viewClose)
            
            self.view.addSubview(self.addView)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.addView.alpha = 1
            })
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view.classForCoder) == "UITableViewCellContentView"  {
            return false
        }
        return true
    }
    
    func onViewCloseClick(){
        self.navHide(self.pointNavY)
        self.viewClose.removeFromSuperview()
        self.addStepView.textView.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var newTransform = CGAffineTransformScale(self.addView.transform, 1.2, 1.2)
            self.addView.transform = newTransform
            self.addView.alpha = 0
            }) { (Bool) -> Void in
                self.addView.removeFromSuperview()
        }
    }
    
    func onCloseConfirm(){
        if ((self.addStepView.textView.text != "进展正文") & (self.addStepView.textView.text != "")) || self.addStepView.uploadUrl != "" {
            self.addStepView.textView.resignFirstResponder()
            self.cancelSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.cancelSheet!.addButtonWithTitle("不写了")
            self.cancelSheet!.addButtonWithTitle("继续写")
            self.cancelSheet!.cancelButtonIndex = 1
            self.cancelSheet!.showInView(self.view)
        }else{
            self.onViewCloseClick()
        }
    }
    
    func onAddViewClick(){
        self.addStepView.textView.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addStepView.setY(globalHeight/2-106)
        })
        if ((self.addStepView.textView.text != "进展正文") & (self.addStepView.textView.text != "")) || self.addStepView.uploadUrl != "" {
            self.addStepView.textView.resignFirstResponder()
        }else{
            self.onViewCloseClick()
        }
    }
    
    func navHide(yPoint:CGFloat){
        var navigationFrame = self.navigationController!.navigationBar.frame
        navigationFrame.origin.y = yPoint
        self.navigationController!.navigationBar.frame = navigationFrame
    }
    
    func addCircleButton(){
        var circleexploreVC = CircleExploreController()
        self.navigationController?.pushViewController(circleexploreVC, animated: true)
    }
    
    func enter() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        client.setOnState(on_state)
        var r = client.enter(safeuid, shell: safeshell)
    }
    
    func on_state(st: ImClient.State) {
        if st == .authed {
            // 创建表格
            client.pollBegin(self.on_poll)
        } else if st == .live {
            self.loadCircle()
            self.loadLetter()
        }
    }
    
    func on_poll(obj: AnyObject?) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeuser = Sa.objectForKey("user") as String
        if obj != nil {
            shake()
            var msg: AnyObject? = obj!["msg"]
            var json = msg!["msg"] as NSArray
            var count = json.count - 1
            if count >= 0 {
                for i: Int in 0...count {
                    var data: NSDictionary = json[i] as NSDictionary
                    var id = data.stringAttributeForKey("msgid")
                    var uid = data.stringAttributeForKey("from")
                    var name = data.stringAttributeForKey("fromname")
                    var cid = data.stringAttributeForKey("cid")
                    var cname = data.stringAttributeForKey("cname")
                    var content = data.stringAttributeForKey("msg")
                    var type = data.stringAttributeForKey("msgtype")
                    var time = data.stringAttributeForKey("time")
                    var circle = data.stringAttributeForKey("to")
                    var title = data.stringAttributeForKey("title")
                    var totype = data.stringAttributeForKey("totype")
                    content = content.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                    content = SADecode(SADecode(content))
                    title = title.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                    title = SADecode(SADecode(title))
                    var isread = 0
                    // 如果是群聊
                    if totype == "1" {
                        if circle == "\(globalCurrentCircle)" || uid == safeuid {
                            isread = 1
                        }
                        SQLCircleContent(id, uid, name, cid, cname, circle, content, title, type, time, isread) {
                            if (type == "6") && ((cid == safeuid) || (cid == uid)) {
                                Api.getCircleStatus(circle) { json in
                                    if json != nil {
                                        var numStatus = json!["count"] as String
                                        var titleStatus = json!["title"] as String
                                        var imageStatus = json!["img"] as String
                                        var postdateStatus = json!["postdate"] as String
                                        if numStatus == "1" {
                                            // 添加
                                            SQLCircleListInsert(circle, titleStatus, imageStatus, postdateStatus)
                                            NSNotificationCenter.defaultCenter().postNotificationName("Poll", object: data)
                                        }
                                    }
                                }
                            }else if type == "3" {
                                Api.getSingleStep(cid) { json in
                                    if json != nil {
                                        if let item = json!["items"] as? NSArray {
                                            var dataStep = item[0] as NSDictionary
                                            var sid = dataStep.stringAttributeForKey("sid")
                                            var uid = dataStep.stringAttributeForKey("uid")
                                            var dream = dataStep.stringAttributeForKey("dream")
                                            var content = dataStep.stringAttributeForKey("content")
                                            var img = dataStep.stringAttributeForKey("img")
                                            var img0 = dataStep.stringAttributeForKey("img0")
                                            var img1 = dataStep.stringAttributeForKey("img1")
                                            SQLStepContent(sid, uid, dream, content, img, img0, img1) {
                                                NSNotificationCenter.defaultCenter().postNotificationName("Poll", object: data)
                                            }
                                        }
                                    }
                                }
                            }else{
                                NSNotificationCenter.defaultCenter().postNotificationName("Poll", object: data)
                            }
                        }
                        if safeuid != uid {     // 如果是朋友们发的
                            dispatch_async(dispatch_get_main_queue(), {
                                if globalTabBarSelected != 104 {
                                    self.dotCircle!.hidden = false
                                    if let a = self.dotCircle!.text?.toInt() {
                                        self.dotCircle!.text = "\(a + 1)"
                                    }
                                }
                            })
                        }
                    }else{
                        // 如果是私聊
                        if uid == "\(globalCurrentLetter)" || uid == safeuid {
                            isread = 1
                        }
                        SQLLetterContent(id, uid, name, uid, content, type, time, isread) {
                            NSNotificationCenter.defaultCenter().postNotificationName("Letter", object: data)
                            self.noticeDot()
                        }
                    }
                }
            }
        }
    }
    
    func loadCircle() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeuser = Sa.objectForKey("user") as String
        Api.postCircleInit() { json in
            if json != nil {
                // 成功
                var a: Int = 0
                var arr = json!["items"] as NSArray
                for i : AnyObject  in arr {
                    var data = i as NSDictionary
                    var id = data.stringAttributeForKey("id")
                    var uid = data.stringAttributeForKey("uid")
                    var name = data.stringAttributeForKey("name")
                    var cid = data.stringAttributeForKey("cid")
                    var cname = data.stringAttributeForKey("cname")
                    var circle = data.stringAttributeForKey("circle")
                    var content = data.stringAttributeForKey("content")
                    var type = data.stringAttributeForKey("type")
                    var time = data.stringAttributeForKey("lastdate")
                    var title = data.stringAttributeForKey("title")
                    var isread = 0
                    if circle == "\(globalCurrentCircle)" || uid == safeuid {
                        isread = 1
                    }
                    let (resultSet2, err2) = SD.executeQuery("SELECT * FROM circle where msgid='\(id)' and owner = '\(safeuid)' order by id desc limit  1")
                    if resultSet2.count == 0 {
                        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        var safeuid = Sa.objectForKey("uid") as String
                        var safeuser = Sa.objectForKey("user") as String
                        if (type == "6") && ((cid == safeuid) || (cid == uid)) {
                            Api.getCircleStatus(circle) { json in
                                if json != nil {
                                    var numStatus = json!["count"] as String
                                    var titleStatus = json!["title"] as String
                                    var imageStatus = json!["img"] as String
                                    var postdateStatus = json!["postdate"] as String
                                    if numStatus == "1" {
                                        // 添加
                                        SQLCircleListInsert(circle, titleStatus, imageStatus, postdateStatus)
                                    }
                                }
                            }
                        }else if type == "3" {
                            Api.getSingleStep(cid) { json in
                                if json != nil {
                                    if let item = json!["items"] as? NSArray {
                                        var data = item[0] as NSDictionary
                                        var sid = data.stringAttributeForKey("sid")
                                        var uid = data.stringAttributeForKey("uid")
                                        var dream = data.stringAttributeForKey("dream")
                                        var content = data.stringAttributeForKey("content")
                                        var img = data.stringAttributeForKey("img")
                                        var img0 = data.stringAttributeForKey("img0")
                                        var img1 = data.stringAttributeForKey("img1")
                                        SQLStepContent(sid, uid, dream, content, img, img0, img1) {
                                        }
                                    }
                                }
                            }
                        }
                        SQLCircleContent(id, uid, name, cid, cname, circle, content, title, type, time, isread) {
                            var data = NSDictionary(objects: [cid, uid, name, content, id, type, time, circle, "1"], forKeys: ["cid", "from", "fromname", "msg", "msgid", "msgtype", "time", "to", "totype"])
                            NSNotificationCenter.defaultCenter().postNotificationName("Poll", object: data)
                        }
                        a++
                    }
                }
                if a != 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        if globalTabBarSelected != 104 {
                            self.dotCircle!.hidden = false
                            if let b = self.dotCircle!.text?.toInt() {
                                self.dotCircle!.text = "\(b + a)"
                            }
                        }
                    })
                }
            }
        }
    }
    
    func loadLetter() {
        Api.postLetterInit() { json in
            if json != nil {
                // 成功
                var a: Int = 0
                var arr = json!["items"] as NSArray
                for i : AnyObject  in arr {
                    var data = i as NSDictionary
                    var id = data.stringAttributeForKey("id")
                    var uid = data.stringAttributeForKey("uid")
                    var name = data.stringAttributeForKey("name")
                    var circle = uid
                    var content = data.stringAttributeForKey("content")
                    var type = data.stringAttributeForKey("type")
                    var time = data.stringAttributeForKey("lastdate")
                    var isread = 0
                    if circle == "\(globalCurrentCircle)" {
                        isread = 1
                    }
                    var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    var safeuid = Sa.objectForKey("uid") as String
                    let (resultSet2, err2) = SD.executeQuery("SELECT * FROM letter where msgid='\(id)' and owner = '\(safeuid)' order by id desc limit  1")
                    if resultSet2.count == 0 {
                        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        var safeuid = Sa.objectForKey("uid") as String
                        var safeuser = Sa.objectForKey("user") as String
                        SQLLetterContent(id, uid, name, circle, content, type, time, isread) {
                            dispatch_async(dispatch_get_main_queue(), {
                                var data = NSDictionary(objects: ["0", uid, name, content, id, type, time, circle, "0"], forKeys: ["cid", "from", "fromname", "msg", "msgid", "msgtype", "time", "to", "totype"])
                                NSNotificationCenter.defaultCenter().postNotificationName("Letter", object: data)
                                self.noticeDot()
                            })
                        }
                    }
                }
            }
        }
    }
}
