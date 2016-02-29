//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

var Nian: NianViewController!
class HomeViewController: UITabBarController, UIApplicationDelegate, UIActionSheetDelegate, ShareDelegate, RCIMClientReceiveMessageDelegate {
    var myTabbar :UIView?
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var dot:UILabel?
    var GameOverView:Popup!
    var animationBool:Int = 0
    var numExplore = 0
    var numHot = 0
    var gameoverId:String = ""
    var gameoverMode: Int = -1
    var addView:ILTranslucentView!
    var addStepView:AddStep!
    var viewClose:UIImageView!
    let imageArray = ["home","explore","update","letter","bbs"]
    var actionSheetGameOver: UIActionSheet?
    var timer:NSTimer?
    var ni: NIAlert?
    var niAppStore: NIAlert?
    var niAppStoreStar: NIAlert?
    // 网络状态初始化
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var newEditStepRow: Int = 0
    var newEditStepData: NSDictionary?
    var newEditDreamId: String = ""
    
    /* 未读消息 */
    var unread: Int32 = 0
    
    func onReceived(message: RCMessage!, left nLeft: Int32, object: AnyObject!) {
        NSNotificationCenter.defaultCenter().postNotificationName("Letter", object: message)
        unread += 1
        dotShow()
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setupViews()
        self.initViewControllers()
        gameoverCheck()
        setupReachability()
        RCIMClient.sharedRCIMClient().setReceiveMessageDelegate(self, object: nil)
    }

    func gameoverCheck() {
        Api.getGameover() { json in
            if json != nil {
                let error = json!.objectForKey("error") as? NSNumber
                let json = JSON(json!)
                if error == 0 {
                    let willLogout = json["data"]["gameover"].stringValue
                    
                    // 如果被封号
                    if willLogout == "1" {
                        let data = json["data"].dictionaryValue
                        self.gameoverId = data["dream"]!["id"].stringValue
                        let gameoverDays = data["dream"]!["days"].stringValue
                        
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
                } else {
                    // 校验失败
                    self.SAlogout()
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
        // 当前账户退出，载入其他账户时使用
    }
    
    func onAppActive() {
        onAppEnterForeground()
    }
    
    /**
    主要是为了处理通知，跳转到 tab[3] 去
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    /* App 从后台进入前台，或者在登录状态下启动 */
    func onAppEnterForeground() {
        launchTimer()
        onLock(lockType.verify)
    }
    
    func onObserveDeactive() {
        stopTimer()
    }
    
    func launchTimer() {
        if timer != nil {
            return
        }
        noticeDot()
//        timer = NSTimer(timeInterval: 15, target: self, selector: "noticeDot", userInfo: nil, repeats: true)
//        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func noticeDot() {
        if dot != nil {
            self.dot?.hidden = true
            Api.postLetter() { json in
                if json != nil {
                    if let data = json as? NSDictionary {
                        let noticeReply = Int(data.stringAttributeForKey("notice_reply"))
                        let noticeLike = Int(data.stringAttributeForKey("notice_like"))
                        let noticeNews = Int(data.stringAttributeForKey("notice_news"))
                        if noticeReply != nil && noticeLike != nil && noticeNews != nil {
                            let notice = Int32(noticeReply! + noticeLike! + noticeNews!)
                            let _letter = RCIMClient.sharedRCIMClient().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
                            let letter = max(0, _letter)
                            self.unread = letter + notice
                            self.dotShow()
                        }
                    }
                }
            }
        }
    }
    
    /* 出现小蓝点 */
    func dotShow() {
        back {
            /* 当不在消息按钮上 */
            if self.unread > 0 && globalTabBarSelected != 103 {
                self.dot!.hidden = false
                UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions(), animations: {
                    self.dot!.frame = CGRectMake(globalWidth * 0.7+4, 8, 20, 17)
                    }, completion: { (complete: Bool) in
                        self.dot!.text = "\(self.unread)"
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
        self.myTabbar!.backgroundColor = UIColor.NavColor()
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
        }
        self.dot = UILabel(frame: CGRectMake(globalWidth*0.7+4, 10, 20, 15))
        self.dot!.textColor = UIColor.whiteColor()
        self.dot!.font = UIFont.systemFontOfSize(10)
        self.dot!.textAlignment = NSTextAlignment.Center
        self.dot!.backgroundColor = UIColor.HighlightColor()
        self.dot!.layer.cornerRadius = 5
        self.dot!.layer.masksToBounds = true
        self.dot!.hidden = true
        self.dot!.text = "0"
        self.myTabbar!.addSubview(dot!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onURL:", name: "AppURL", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "QuickActions:", name: "QuickActions", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAppEnterForeground", name: "AppEnterForeground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAppActive", name: "AppActive", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onObserveDeactive", name: "AppDeactive", object: nil)
        
        /* 当收到远程推送时 */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "noticeDot", name: "Notice", object: nil)
    }
    
    // 3D Touch 下的更新进展
    func QuickActions(sender: NSNotification) {
        let type = sender.object as! String
        if type == "1" {
            let vc = AddStep(nibName: "AddStep", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func GameOverHide(){
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
        if actionSheet == self.actionSheetGameOver {
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
        Nian = NianStoryBoard.instantiateViewControllerWithIdentifier("NianViewController") as! NianViewController
        let vc1 = Nian
        let vc2 = storyboardExplore.instantiateViewControllerWithIdentifier("ExploreViewController")
        let vc3 = AddStep(nibName: "AddStep", bundle: nil)
        let vc4 = MeViewController()
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
        }else if index == idBBS {     // 热门
            NSNotificationCenter.defaultCenter().postNotificationName("reddit", object:"\(numHot)")
            numHot = numHot + 1
        }else if index == idDream {     // 记本
        }else if index == idMe {     // 消息
            self.dot!.hidden = true
            unread = 0
            NSNotificationCenter.defaultCenter().postNotificationName("noticeShare", object:"1")
        }else if index == idUpdate {      // 更新
            /* 当缓存中没有记本时，点击第三栏跳转到添加记本 */
            if let NianDreams = Cookies.get("NianDreams") as? NSMutableArray {
                if NianDreams.count == 0 {
                    Nian.addDreamButton()
                } else {
                    let vc = AddStep(nibName: "AddStep", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                Nian.addDreamButton()
            }
        }
        if index != idExplore {
            numExplore = 0
        }
        if index != idBBS {
            numHot = 0
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView"  {
            return false
        }
        return true
    }
    
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
}



