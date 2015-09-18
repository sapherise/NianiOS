//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController, UIApplicationDelegate, UIActionSheetDelegate, MaskDelegate{
    var myTabbar :UIView?
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var dot:UILabel?
    var GameOverView:Popup!
    var animationBool:Int = 0
    var numExplore = 0
    var gameoverId:String = ""
    var gameoverMode: Int = -1
    var addView:ILTranslucentView!
    var addStepView:AddStep!
    var viewClose:UIImageView!
    let imageArray = ["home","explore","update","letter","bbs"]
    var cancelSheet:UIActionSheet?
    var actionSheetGameOver: UIActionSheet?
    var timer:NSTimer?
    var ni: NIAlert?
    
    /// 是否 nav 到私信界面，对应的是启动时是否是从 NSNotification 启动的。
    var shouldNavToMe: Bool = false
    var tabButtonArray = NSMutableArray()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        SQLInit()
        self.setupViews()
        self.initViewControllers()
        gameoverCheck()
        launchTimer()
        onCircleEnter()
        
        let notiCenter = NSNotificationCenter.defaultCenter()
        notiCenter.addObserver(self, selector: "handleNetworkReceiveMsg:", name: kJPFNetworkDidReceiveMessageNotification, object: nil)
    }
    
    func gameoverCheck() {
        Api.postGameover() { json in
            if json != nil {
                let isgameover = json!.objectForKey("isgameover") as? String
                let willLogout = json!.objectForKey("willlogout") as? String
                // 账户验证不通过
                if willLogout == "1" {
                    delay(1, closure: { () -> () in
                        self.SAlogout()
                    })
                }else{
                    // 如果被封号
                    if isgameover != "0" {
                        let data = json!.objectForKey("dream") as! NSDictionary
                        self.gameoverId = data.stringAttributeForKey("id")
                        let gameoverDays = data.stringAttributeForKey("days")
                        
                        self.GameOverView = (NSBundle.mainBundle().loadNibNamed("Popup", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Popup
                        self.GameOverView.textTitle = "游戏结束"
                        self.GameOverView.textContent = "因为 \(gameoverDays) 天没更新\n你损失了 5 念币"
                        self.GameOverView.heightImage = 130
                        self.GameOverView.textBtnMain = "继续日更模式"
                        self.GameOverView.textBtnSub = " 关闭日更模式"
                        self.GameOverView.btnMain.tag = 1
                        self.GameOverView.btnSub.tag = 2
                        self.GameOverView.btnMain.addTarget(self, action: "onBtnGameOverClick:", forControlEvents: UIControlEvents.TouchUpInside)
                        self.GameOverView.btnSub.addTarget(self, action: "onBtnGameOverClick:", forControlEvents: UIControlEvents.TouchUpInside)
                        let gameoverHead = UIImageView(frame: CGRectMake(70, 60, 75, 60))
                        gameoverHead.image = UIImage(named: "pet_ghost")
                        let gameoverSpark = UIImageView(frame: CGRectMake(35, 38, 40, 60))
                        gameoverSpark.image = UIImage(named: "pet_ghost_spark")
                        self.GameOverView.viewHolder.addSubview(gameoverHead)
                        self.GameOverView.viewHolder.addSubview(gameoverSpark)
                        self.view.addSubview(self.GameOverView)
                        gameoverHead.setAnimationWanderX(70, leftEndX: 125, rightStartX: 125, rightEndX: 70)
                        gameoverHead.setAnimationWanderY(60, endY: 64)
                        gameoverSpark.setAnimationWanderX(70-25, leftEndX: 125-25, rightStartX: 125+60, rightEndX: 70+60)
                        gameoverSpark.setAnimationWanderY(35, endY: 38, animated: false)
                    } else {
                        self.SANews()
                    }
                }
            }
        }
    }
    
    func onBtnGameOverClick(sender: UIButton) {
        let tag = sender.tag
        self.gameoverMode = tag
        if tag == 1 {
            self.actionSheetGameOver = UIActionSheet(title: "勇敢的你\n确定继续玩日更模式吗？", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheetGameOver!.addButtonWithTitle("嗯")
            self.actionSheetGameOver!.addButtonWithTitle("等一下")
            self.actionSheetGameOver!.cancelButtonIndex = 1
            self.actionSheetGameOver!.showInView(self.view)
        }else{
            self.actionSheetGameOver = UIActionSheet(title: "要关闭日更模式吗？\n关闭后永不停号，但更新奖励减少\n你随时可在设置里开启日更模式", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheetGameOver!.addButtonWithTitle("嗯")
            self.actionSheetGameOver!.addButtonWithTitle("等一下")
            self.actionSheetGameOver!.cancelButtonIndex = 1
            self.actionSheetGameOver!.showInView(self.view)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navHide()
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onObserveActive", name: "AppActive", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onObserveDeactive:", name: "AppDeactive", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCircleLeave", name: "CircleLeave", object: nil)
        // 当前账户退出，载入其他账户时使用
        if globalWillReEnter == 1 {
            globalWillReEnter = 0
            onCircleEnter()
        }
    }
    
    /**
    主要是为了处理通知，跳转到 tab[3] 去
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldNavToMe {
            if let _ = self.viewControllers  {
                self.selectedIndex = 3
                
                (self.tabButtonArray[0] as! UIButton).selected = false
                (self.tabButtonArray[3] as! UIButton).selected = true
                
                self.dot!.hidden = true
                NSNotificationCenter.defaultCenter().postNotificationName("noticeShare", object:"1")
            }
            shouldNavToMe = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navShow()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AppActive", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AppDeactive", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CircleLeave", object: nil)
    }
    
    /**
    处理在 app 打开的情况下，通过极光 TCP 推送来的消息
    
    :param: noti <#noti description#>
    */
    func handleNetworkReceiveMsg(noti: NSNotification) {
        // 设置 [String: AnyObject] 的别名 Dict, 下面代码会略简洁
        typealias Dict = [String: AnyObject]
        
        /* 只能用很差的方式来实现 */
        if let _string = ((noti.userInfo as? Dict) ?? Dict())["content"] as? String {
            let _char = _string[_string.startIndex.advancedBy(_string.characters.count - 2)]
            
            switch _char {
            case "了":
                
                /* 获得私信、按赞和通知 */
                self.noticeDot()
                
            case "你":
                self.loadLetter()
                
            default:
                break
            }
        }
        
    }
    
    func onObserveActive() {
        launchTimer()
        onCircleEnter()
    }
    
    // 连接数据库
    var isLoadFinish = 0
    func onCircleEnter() {
        isLoadFinish = 0
        self.loadLetter()
    }
    
    // 断开数据库
    func onCircleLeave() {
        client.leave()
    }
    
    func onObserveDeactive(sender: NSNotification) {
        stopTimer()
    }
    
    func launchTimer() {
        if timer != nil {
            return
        }
        noticeDot()
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func noticeDot() {
        if self.dot != nil {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            let safeuid = SAUid()
            let safeshell = uidKey.objectForKey(kSecValueData) as! String
            
            if safeuid != "" {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let (resultSet, _) = SD.executeQuery("select id from letter where isread = 0 and owner = '\(safeuid)'")
                    let a = resultSet.count
                    let b = SAPost("uid=\(safeuid)&&shell=\(safeshell)", urlString: "http://nian.so/api/dot.php")
                    
                    if let number = Int(b) {
                        globalNoticeNumber = a + number
                        dispatch_async(dispatch_get_main_queue(), {
                            if globalNoticeNumber != 0 && globalTabBarSelected != 103 {
                                self.dot!.hidden = false
                                UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions(), animations: {
                                    self.dot!.frame = CGRectMake(globalWidth*0.7+4, 8, 20, 17)
                                    }, completion: { (complete: Bool) in
                                        UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions(), animations: {
                                            self.dot!.frame = CGRectMake(globalWidth*0.7+4, 10, 20, 15)
                                            }, completion: { (complete: Bool) in
                                                self.dot!.text = "\(globalNoticeNumber)"
                                        })
                                })
                            } else {  // if globalNoticeNumber != 0 && globalTabBarSelected != 103
                                self.dot!.hidden = true
                                if number > 0 {
                                    NSNotificationCenter.defaultCenter().postNotificationName("noticeShare", object: nil)
                                }
                            }
                        })
                    } // if let number = Int(b)
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
        let count = 5
        for var index = 0; index < count; index++ {
            let btnWidth = CGFloat(index) * globalWidth * 0.2
            let button  = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(btnWidth, 1, globalWidth * 0.2 ,49)
            button.tag = index+100
            let image = self.imageArray[index]
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
            
            tabButtonArray.insertObject(button, atIndex: index)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onURL:", name: "AppURL", object: nil)
    }
    
    func GameOverHide(){
        globalWillNianReload = 1
        self.navigationItem.rightBarButtonItems = buttonArray()
        if self.gameoverMode == 1 {
            Api.postGameoverCoin(self.gameoverId) { json in
                self.navigationItem.rightBarButtonItems = []
                self.GameOverView!.hidden = true
            }
        }else{
            Api.postUserFrequency(1) { json in
                Api.postGameoverCoin(self.gameoverId) { json in
                    self.navigationItem.rightBarButtonItems = []
                    self.GameOverView!.hidden = true
                }
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.cancelSheet {
            if buttonIndex == 0 {
                self.onViewCloseClick()
            }
        }else if actionSheet == self.actionSheetGameOver {
            if buttonIndex == 0 {
                GameOverHide()
            }
        }
    }
    
    func gameoverButton(word:String) -> UIButton {
        let button = UIButton(frame: CGRectMake(60, 0, 150, 36))
        button.backgroundColor = UIColor.blackColor()
        button.setTitle(word, forState: UIControlState.Normal)
        button.titleLabel!.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: "onBtnGameOverClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }
    
    //每个按钮跳转到哪个页面
    func initViewControllers() {
        let storyboardExplore = UIStoryboard(name: "Explore", bundle: nil)
        let NianStoryBoard: UIStoryboard = UIStoryboard(name: "NianViewController", bundle: nil)
        let NianViewController: UIViewController = NianStoryBoard.instantiateViewControllerWithIdentifier("NianViewController") 
        let vc1 = NianViewController
        let vc2 = storyboardExplore.instantiateViewControllerWithIdentifier("ExploreViewController") 
        let vc3 = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        let vc4 = MeViewController()
//        vc5 = circleCollectionList.instantiateViewControllerWithIdentifier("CircleListCollectionController") as! CircleListCollectionController
        let vc5 = RedditViewController()
        self.viewControllers = [vc1, vc2, vc3, vc4, vc5]
        self.customizableViewControllers = nil
        self.selectedIndex = 0
    }
    
    //底部的按钮按下去
    func tabBarButtonClicked(sender:UIButton){
        let index = sender.tag
        for var i = 0; i < 5; i++ {
            let button = self.view.viewWithTag(i+100) as? UIButton
            if button != nil {
                if index != 102 {
                    if button!.tag == index{
                        button!.selected = true
                    }else{
                        button!.selected = false
                    }
                }
            }
        }
        if index != 102 {
            self.selectedIndex = index - 100
        }
        globalTabBarSelected = index
        
        let idDream = 100
        let idExplore = 101
        let idUpdate = 102
        let idMe = 103
        let idBBS = 104
        
        if index == idExplore {       // 发现
            NSNotificationCenter.defaultCenter().postNotificationName("exploreTop", object:"\(numExplore)")
            numExplore = numExplore + 1
        }else if index == idBBS {     // 梦境
            NSNotificationCenter.defaultCenter().postNotificationName("reddit", object:"1")
        }else if index == idDream {     // 记本
        }else if index == idMe {     // 消息
            self.dot!.hidden = true
            NSNotificationCenter.defaultCenter().postNotificationName("noticeShare", object:"1")
        }else if index == idUpdate {      // 更新
            self.addStep()
        }
        if index != idExplore {
            numExplore = 0
        }
    }
    
    func addDreamButton(){
        let adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    func addStep(){
        if globalNumberDream == 0 {
            let adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
            self.navigationController!.pushViewController(adddreamVC, animated: true)
        } else {
            self.addView = ILTranslucentView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
            self.addView.translucentAlpha = 1
            self.addView.translucentStyle = UIBarStyle.Default
            self.addView.translucentTintColor = UIColor.clearColor()
            self.addView.backgroundColor = UIColor.clearColor()
            self.addView.alpha = 0
            self.addView.center = CGPointMake(globalWidth/2, globalHeight/2)
            let Tap = UITapGestureRecognizer(target: self, action: "onAddViewClick")
            Tap.delegate = self
            self.addView.addGestureRecognizer(Tap)
            
            let nib = NSBundle.mainBundle().loadNibNamed("AddStep", owner: self, options: nil)
            self.addStepView = nib[0] as! AddStep
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
        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView"  {
            return false
        }
        return true
    }
    
    func onViewCloseClick(){
        self.viewClose.removeFromSuperview()
        self.addStepView.textView.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let newTransform = CGAffineTransformScale(self.addView.transform, 1.2, 1.2)
            self.addView.transform = newTransform
            self.addView.alpha = 0
            }) { (Bool) -> Void in
                self.addView.removeFromSuperview()
        }
    }
    
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func onCloseConfirm(){
        if ((self.addStepView.textView.text != "进展正文") && (self.addStepView.textView.text != "")) || self.addStepView.uploadUrl != "" {
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
        if ((self.addStepView.textView.text != "进展正文") && (self.addStepView.textView.text != "")) || self.addStepView.uploadUrl != "" {
            self.addStepView.textView.resignFirstResponder()
        }else{
            self.onViewCloseClick()
        }
    }
    
    func loadLetter() {
        Api.postLetterInit() { json in
            if json != nil {
                // 成功
                self.isLoadFinish++
                let arr = json!.objectForKey("items") as! NSArray
                let lastid = json!.objectForKey("lastid") as! String
                
                for i : AnyObject  in arr {
                    let data = i as! NSDictionary
                    let id = data.stringAttributeForKey("id")
                    let uid = data.stringAttributeForKey("uid")
                    let name = data.stringAttributeForKey("name")
                    let circle = uid
                    let content = data.stringAttributeForKey("content")
                    let type = data.stringAttributeForKey("type")
                    let time = data.stringAttributeForKey("lastdate")
                    var isread = 0
                    if circle == "\(globalCurrentCircle)" {
                        isread = 1
                    }
                    
                    let safeuid = SAUid()
                    
                    let (resultSet2, _) = SD.executeQuery("SELECT * FROM letter where msgid='\(id)' and owner = '\(safeuid)' order by id desc limit  1")
                    if resultSet2.count == 0 {
                        SQLLetterContent(id, uid: uid, name: name, circle: circle, content: content, type: type, time: time, isread: isread) {
                            let data = NSDictionary(objects: ["0", uid, name, content, id, type, time, circle, "0"], forKeys: ["cid", "from", "fromname", "msg", "msgid", "msgtype", "time", "to", "totype"])
                            NSNotificationCenter.defaultCenter().postNotificationName("Letter", object: data)
                        }
                    }
                }
                
                self.noticeDot()
                Api.postUserLetterLastid(lastid) { _ in
                }
            }
        }
    }
    
    
//    func enter() {
//        if isLoadFinish == 1 {
//            go {
//                let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
//                let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//                let safeshell = uidKey.objectForKey(kSecValueData) as! String
//                client.setOnState(self.on_state)
//                client.enter(safeuid, shell: safeshell)
//            }
//        }
//    }

//    func on_state(st: ImClient.State) {
//        if st == .authed {
//            client.pollBegin(self.on_poll)
//        } else if st == .live {
//            onCircleEnter()
//        }
//    }
//
//    func on_poll(obj: AnyObject?) {
//        go {
//            logInfo("+++ \(obj) ===")
//
//            let safeuid = SAUid()
//            if obj != nil {
//                let msg: AnyObject? = obj!.objectForKey("msg")
//                if msg != nil {
//                    let json = msg!.objectForKey("msg") as? NSArray
//                    if json != nil {
//                        let count = json!.count - 1
//                        if count >= 0 {
//                            for i: Int in 0...count {
//                                let data: NSDictionary = json![i] as! NSDictionary
//                                let id = data.stringAttributeForKey("msgid")
//                                let uid = data.stringAttributeForKey("from")
//                                let name = data.stringAttributeForKey("fromname")
//                                var content = data.stringAttributeForKey("msg")
//                                let type = data.stringAttributeForKey("msgtype")
//                                let time = data.stringAttributeForKey("time")
//                                var title = data.stringAttributeForKey("title")
//                                let totype = data.stringAttributeForKey("totype")
//                                content = SADecode(SADecode(content))
//                                title = SADecode(SADecode(title))
//                                var isread = 0
//                                // 如果是群聊
//                                if totype == "1" {
//                                } else {
//                                    // 如果是私信
//                                    shake()
//                                    if uid == "\(globalCurrentLetter)" || uid == safeuid {
//                                        isread = 1
//                                    }
//                                    SQLLetterContent(id, uid: uid, name: name, circle: uid, content: content, type: type, time: time, isread: isread) {
//                                        NSNotificationCenter.defaultCenter().postNotificationName("Letter", object: data)
//                                        self.noticeDot()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
}
