//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

var Nian: NianViewController!
var numExplore = 0

class HomeViewController: UITabBarController, UIApplicationDelegate, UIActionSheetDelegate, ShareDelegate, RCIMClientReceiveMessageDelegate {
    /*!
     接收消息的回调方法
     
     @param message     当前接收到的消息
     @param nLeft       还剩余的未接收的消息数，left>=0
     @param object      消息监听设置的key值
     
     @discussion 如果您设置了IMlib消息监听之后，SDK在接收到消息时候会执行此方法。
     其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
     您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
     object为您在设置消息接收监听时的key值。
     */

    var myTabbar :UIView?
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var dot:UILabel?
    var GameOverView:Popup!
    var animationBool:Int = 0
    var numHot = 0
    var gameoverId:String = ""
    var gameoverMode: Int = -1
    var addView:ILTranslucentView!
    var addStepView:AddStep!
    var viewClose:UIImageView!
    let imageArray = ["home","explore","update","letter","bbs"]
    var actionSheetGameOver: UIActionSheet?
    var timer:Timer?
    var ni: NIAlert?
    var niAppStore: NIAlert?
    var niAppStoreStar: NIAlert?
    // 网络状态初始化
//    let reachability = Reachability.reachabilityForInternetConnection()
    let reachability = Reachability()!
    
    var newEditStepRow: Int = 0
    var newEditStepData: NSDictionary?
    var newEditDreamId: String = ""
    
    var firstSelected = 0
    
    /* 未读消息 */
    var unread: Int32 = 0
    
    func onReceived(_ message: RCMessage!, left nLeft: Int32, object: Any!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Letter"), object: message)
        unread += 1
        dotShow()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setupViews()
        self.initViewControllers()
        gameoverCheck()
        setupReachability()
        RCIMClient.shared().setReceiveMessageDelegate(self, object: nil)
    }

    func gameoverCheck() {
        Api.getGameover() { json in
            if json != nil {
                if SAValue(json, "error") != "0" {
                   self.SAlogout()
                } else {
                    if let j = json as? NSDictionary {
                        if let data = j.object(forKey: "data") as? NSDictionary {
                            let willLogout = data.stringAttributeForKey("gameover")
                            // 如果被封号了
                            if willLogout == "1" {
                                if let dream = data.object(forKey: "dream") as? NSDictionary {
                                    self.gameoverId = dream.stringAttributeForKey("id")
                                    let gameoverDays = dream.stringAttributeForKey("days")
                                    self.GameOverView = Bundle.main.loadNibNamed("Popup", owner: self, options: nil)?.first as! Popup
                                    self.GameOverView.textTitle = "游戏结束"
                                    self.GameOverView.textContent = "因为 \(gameoverDays) 天没更新\n你损失了 5 念币"
                                    self.GameOverView.heightImage = 130
                                    self.GameOverView.textBtnMain = "继续日更模式"
                                    self.GameOverView.textBtnSub = " 关闭日更模式"
                                    self.GameOverView.btnMain.tag = 1
                                    self.GameOverView.btnSub.tag = 2
                                    self.GameOverView.btnMain.addTarget(self, action: #selector(HomeViewController.onBtnGameOverClick(_:)), for: UIControlEvents.touchUpInside)
                                    self.GameOverView.btnSub.addTarget(self, action: #selector(HomeViewController.onBtnGameOverClick(_:)), for: UIControlEvents.touchUpInside)
                                    let gameoverHead = UIImageView(frame: CGRect(x: 70, y: 60, width: 75, height: 60))
                                    gameoverHead.image = UIImage(named: "pet_ghost")
                                    let gameoverSpark = UIImageView(frame: CGRect(x: 35, y: 38, width: 40, height: 60))
                                    gameoverSpark.image = UIImage(named: "pet_ghost_spark")
                                    self.GameOverView.viewHolder.addSubview(gameoverHead)
                                    self.GameOverView.viewHolder.addSubview(gameoverSpark)
                                    self.view.addSubview(self.GameOverView)
                                    gameoverHead.setAnimationWanderX(70, leftEndX: 125, rightStartX: 125, rightEndX: 70)
                                    gameoverHead.setAnimationWanderY(60, endY: 64)
                                    gameoverSpark.setAnimationWanderX(70-25, leftEndX: 125-25, rightStartX: 125+60, rightEndX: 70+60)
                                    gameoverSpark.setAnimationWanderY(35, endY: 38, animated: false)
                                }
                            } else {
                                self.SANews()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onBtnGameOverClick(_ sender: UIButton) {
        let tag = sender.tag
        self.gameoverMode = tag
        if tag == 1 {
            self.actionSheetGameOver = UIActionSheet(title: "勇敢的你\n确定继续玩日更模式吗？", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheetGameOver!.addButton(withTitle: "嗯")
            self.actionSheetGameOver!.addButton(withTitle: "等一下")
            self.actionSheetGameOver!.cancelButtonIndex = 1
            self.actionSheetGameOver!.show(in: self.view)
        }else{
            self.actionSheetGameOver = UIActionSheet(title: "要关闭日更模式吗？\n关闭后永不停号，但更新奖励减少\n你随时可在设置里开启日更模式", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheetGameOver!.addButton(withTitle: "嗯")
            self.actionSheetGameOver!.addButton(withTitle: "等一下")
            self.actionSheetGameOver!.cancelButtonIndex = 1
            self.actionSheetGameOver!.show(in: self.view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        // 当前账户退出，载入其他账户时使用
    }
    
    func onAppActive() {
        onAppEnterForeground()
    }
    
    /**
    主要是为了处理通知，跳转到 tab[3] 去
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
            self.dot?.isHidden = true
            Api.postLetter() { json in
                if json != nil {
                    if let data = json as? NSDictionary {
                        let noticeReply = Int(data.stringAttributeForKey("notice_reply"))
                        let noticeLike = Int(data.stringAttributeForKey("notice_like"))
                        let noticeNews = Int(data.stringAttributeForKey("notice_news"))
                        if noticeReply != nil && noticeLike != nil && noticeNews != nil {
                            let a = noticeReply!
                            let b = noticeLike!
                            let c = noticeNews!
                            let num = a + b + c
                            let notice = Int32(num)
                            let _letter = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
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
                self.dot!.isHidden = false
                UIView.animate(withDuration: 0.1, delay:0, options: UIViewAnimationOptions(), animations: {
                    self.dot!.frame = CGRect(x: globalWidth * 0.7+4, y: 8, width: 20, height: 17)
                    }, completion: { (complete: Bool) in
                        self.dot!.text = "\(self.unread)"
                })
            }
        }
    }
    
    
    func setupViews(){
        
        if let selected = Cookies.get("selected") as? Int {
            firstSelected = selected
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //总的
        self.view.backgroundColor = BGColor
        self.tabBar.isHidden = true
        
        //底部
        self.myTabbar = UIView(frame: CGRect(x: 0,y: globalHeight-49,width: globalWidth,height: 49)) //x，y，宽度，高度
        self.myTabbar!.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.myTabbar!)
        
        //底部按钮
        let count = 5
        for index in 0 ..< count {
            let btnWidth = CGFloat(index) * globalWidth * 0.2
            let button  = UIButton(type: UIButtonType.custom)
            button.frame = CGRect(x: btnWidth, y: 1, width: globalWidth * 0.2 ,height: 49)
            button.tag = index+100
            let image = self.imageArray[index]
            let myImage = UIImage(named:"\(image)")
            let myImage2 = UIImage(named:"\(image)_s")
            
            button.setImage(myImage, for: UIControlState())
            button.setImage(myImage2, for: UIControlState.selected)
            
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(HomeViewController.tabBarButtonClicked(_:)), for: UIControlEvents.touchUpInside)
            self.myTabbar?.addSubview(button)
            if index == firstSelected {
                button.isSelected = true
            }
        }
        self.dot = UILabel(frame: CGRect(x: globalWidth*0.7+4, y: 10, width: 20, height: 15))
        self.dot!.textColor = UIColor.white
        self.dot!.font = UIFont.systemFont(ofSize: 10)
        self.dot!.textAlignment = NSTextAlignment.center
        self.dot!.backgroundColor = UIColor.HighlightColor()
        self.dot!.layer.cornerRadius = 5
        self.dot!.layer.masksToBounds = true
        self.dot!.isHidden = true
        self.dot!.text = "0"
        self.myTabbar!.addSubview(dot!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onURL(_:)), name: NSNotification.Name(rawValue: "AppURL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.QuickActions(_:)), name: NSNotification.Name(rawValue: "QuickActions"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onAppEnterForeground), name: NSNotification.Name(rawValue: "AppEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onAppActive), name: NSNotification.Name(rawValue: "AppActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onObserveDeactive), name: NSNotification.Name(rawValue: "AppDeactive"), object: nil)
        
        /* 当收到远程推送时 */
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.noticeDot), name: NSNotification.Name(rawValue: "Notice"), object: nil)
    }
    
    // 3D Touch 下的更新进展
    func QuickActions(_ sender: Notification) {
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
                self.GameOverView!.isHidden = true
            }
        }else{
            Api.postUserFrequency(1) { json in
                Api.postGameoverCoin(self.gameoverId) { json in
                    self.navigationItem.rightBarButtonItems = []
                    self.GameOverView!.isHidden = true
                }
            }
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == self.actionSheetGameOver {
            if buttonIndex == 0 {
                GameOverHide()
            }
        }
    }
    
    func gameoverButton(_ word:String) -> UIButton {
        let button = UIButton(frame: CGRect(x: 60, y: 0, width: 150, height: 36))
        button.backgroundColor = UIColor.black
        button.setTitle(word, for: UIControlState())
        button.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(HomeViewController.onBtnGameOverClick(_:)), for: UIControlEvents.touchUpInside)
        return button
    }
    
    //每个按钮跳转到哪个页面
    func initViewControllers() {
        let storyboardExplore = UIStoryboard(name: "Explore", bundle: nil)
        let NianStoryBoard: UIStoryboard = UIStoryboard(name: "NianViewController", bundle: nil)
        Nian = NianStoryBoard.instantiateViewController(withIdentifier: "NianViewController") as! NianViewController
        let vc1 = Nian
        let vc2 = storyboardExplore.instantiateViewController(withIdentifier: "ExploreViewController")
        let vc3 = AddStep(nibName: "AddStep", bundle: nil)
        let vc4 = MeViewController()
        let vc5 = RedditViewController()
        self.viewControllers = [vc1!, vc2, vc3, vc4, vc5]
        self.customizableViewControllers = nil
        self.selectedIndex = firstSelected
    }
    
    //底部的按钮按下去
    func tabBarButtonClicked(_ sender:UIButton){
        let index = sender.tag
        for i in 0 ..< 5 {
            let button = self.view.viewWithTag(i+100) as? UIButton
            if button != nil {
                if index != 102 {
                    if button!.tag == index{
                        button!.isSelected = true
                    }else{
                        button!.isSelected = false
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
            NotificationCenter.default.post(name: Notification.Name(rawValue: "exploreTop"), object:"\(numExplore)")
            numExplore = numExplore + 1
        }else if index == idBBS {     // 热门
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reddit"), object:"\(numHot)")
            numHot = numHot + 1
        }else if index == idDream {     // 记本
        }else if index == idMe {     // 消息
            self.dot!.isHidden = true
            unread = 0
            NotificationCenter.default.post(name: Notification.Name(rawValue: "noticeShare"), object:"1")
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView"  {
            return false
        }
        return true
    }
    
    func onShare(_ avc: UIActivityViewController) {
        self.present(avc, animated: true, completion: nil)
    }
}



