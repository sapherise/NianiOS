//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController, UIApplicationDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate{
    var myTabbar :UIView?
    var currentViewController: UIViewController?
    var currentIndex: Int?
    var dot:UILabel?
    var niceView:UIView?
    var niceViewLabel:UILabel?
    var GameOverView:UIView?
    var animationBool:Int = 0
    var foFreshTimes:Int = 0
    var bbsFreshTimes:Int = 0
    
    var gameoverId:String = ""
    var gameoverHead:String = ""
    var gameoverDays:String = ""
    var gameoverCoin:String = ""
    var gameoverTitle:String = ""
    
    var addView:ILTranslucentView!
    var addStepView:AddStep!
    var viewClose:UIImageView!
    
    let itemArray = ["","","","消息","小组"]
    let imageArray = ["home","explore","update","letter","bbs"]
    
    var deleteDreamSheet:UIActionSheet?
    var cancelSheet:UIActionSheet?
    var pointNavY:CGFloat = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
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
                }else{      //没封号
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setupViews()
                        self.initViewControllers()
                    })
                }
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        noticeDot()
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
    }
    
    func noticeDot() {
        if self.dot != nil {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var noticenumber = SAPost("uid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/dot.php")
                dispatch_async(dispatch_get_main_queue(), {
                self.dot!.text = ""
                if noticenumber == "0" || noticenumber == "err" {
                    self.dot!.hidden = true
                }else{
                    self.dot!.hidden = false
                    UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                        self.dot!.frame = CGRectMake(228, 8, 20, 17)
                        }, completion: { (complete: Bool) in
                            UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                                self.dot!.frame = CGRectMake(228, 10, 20, 15)
                                }, completion: { (complete: Bool) in
                                    self.dot!.text = noticenumber
                            })
                    })
                }
                })
            })
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        //self.dot.hidden = true
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
        
        //通知栏
        self.niceView = UIView(frame: CGRectMake(0, -40, 320, 40))
        self.niceView!.backgroundColor = LightBlueColor
        self.niceViewLabel = UILabel(frame: CGRectMake(0, 5, 320, 35))
        self.niceViewLabel!.textAlignment = NSTextAlignment.Center
        self.niceViewLabel!.textColor = UIColor.whiteColor()
        self.niceViewLabel!.font = UIFont.systemFontOfSize(14)
        self.niceView!.addSubview(self.niceViewLabel!)
        self.niceView!.hidden = true
        self.view.addSubview(self.niceView!)
        
        //底部按钮
        var count = self.itemArray.count
        for var index = 0; index < count; index++ {
            var btnWidth = (CGFloat)(index*64)
            var button  = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            button.frame = CGRectMake(btnWidth, 1,64,49)
            button.tag = index+100
            var image = self.imageArray[index]
            let myImage = UIImage(named:"\(image)")
            let myImage2 = UIImage(named:"\(image)S")
            
            button.setImage(myImage, forState: UIControlState.Normal)
            button.setImage(myImage2, forState: UIControlState.Selected)
            
            button.clipsToBounds = true
            button.addTarget(self, action: "tabBarButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            self.myTabbar?.addSubview(button)
            if index == 0 {
                button.selected = true
            }
        }
        
        self.dot = UILabel(frame: CGRectMake(228, 10, 20, 15))
        self.dot!.textColor = UIColor.whiteColor()
        self.dot!.font = UIFont.systemFontOfSize(10)
        self.dot!.textAlignment = NSTextAlignment.Center
        self.dot!.backgroundColor = SeaColor
        self.dot!.layer.cornerRadius = 5
        self.dot!.layer.masksToBounds = true
        self.dot!.hidden = true
        noticeDot()
        self.myTabbar!.addSubview(dot!)
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
        
        self.GameOverView = UIView(frame: CGRectMake(0, 0, 320, globalHeight))
        self.GameOverView!.backgroundColor = BGColor
        
        var holder = UIView(frame: CGRectMake(40, globalHeight / 2 - 175, 240, 350))
        holder.backgroundColor = UIColor.redColor()
        var gameoverHead = UIImageView(frame: CGRectMake(95, 0, 50, 50))
        gameoverHead.setImage("http://img.nian.so/dream/\(self.gameoverHead)!dream", placeHolder: IconColor)
        var gameoverLabel = UILabel(frame: CGRectMake(30, 70, 180, 210))
        var gameoverWord = "梦想「\(self.gameoverTitle)」有 \(self.gameoverDays) 天没有更新，已经阵亡。\n你有 \(self.gameoverCoin) 枚念币，支付念币或者删除梦想来继续玩念。"
        gameoverLabel.text = gameoverWord
        gameoverLabel.numberOfLines = 0
        gameoverLabel.font = UIFont.systemFontOfSize(14)
        gameoverLabel.textColor = IconColor
        gameoverLabel.setHeight(gameoverWord.stringHeightWith(14, width: 180))
        var button1 = gameoverButton("支付 5 念币")
        button1.tag = 1
        button1.addTarget(self, action: "GameOverHide:", forControlEvents: UIControlEvents.TouchUpInside)
        button1.setY(gameoverLabel.bottom()+20)
        var button2 = gameoverButton("删除这个梦想")
        button2.tag = 2
        button2.addTarget(self, action: "GameOverHide:", forControlEvents: UIControlEvents.TouchUpInside)
        button2.setY(button1.bottom()+6)
        var button3 = gameoverButton("退出当前账号")
        button3.addTarget(self, action: "SAlogout", forControlEvents: UIControlEvents.TouchUpInside)
        button3.setY(button2.bottom()+6)
        holder.addSubview(gameoverHead)
        holder.addSubview(gameoverLabel)
        holder.addSubview(button1)
        holder.addSubview(button2)
        holder.addSubview(button3)
        self.GameOverView?.addSubview(holder)
        
        self.view.addSubview(self.GameOverView!)
    }
    
    func SAlogout(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as? String
        var safeshell = Sa.objectForKey("shell") as? String
        if (safeuid != nil) & (safeshell != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("devicetoken=&&uid=\(safeuid!)&&shell=\(safeshell!)&&type=1", "http://nian.so/api/user_update.php")
            })
        }
        Sa.removeObjectForKey("uid")
        Sa.removeObjectForKey("shell")
        Sa.removeObjectForKey("followData")
        Sa.removeObjectForKey("user")
        Sa.synchronize()
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func GameOverHide(sender:UIButton){
        if sender.tag == 1 {
            if self.gameoverCoin.toInt() < 5 {
                UIView.showAlertView("念币不够", message: "登录 http://nian.so 来获得更多念币")
            }else{
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
                        self.setupViews()
                        self.initViewControllers()
                        })
                    }
                })
            }
        }else if sender.tag == 2 {
            self.deleteDreamSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.deleteDreamSheet!.addButtonWithTitle("确定删除梦想")
            self.deleteDreamSheet!.addButtonWithTitle("取消")
            self.deleteDreamSheet!.cancelButtonIndex = 1
            self.deleteDreamSheet!.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {
                self.navigationItem.rightBarButtonItems = buttonArray()
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as String
                var safeshell = Sa.objectForKey("shell") as String
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&id=\(self.gameoverId)", "http://nian.so/api/delete_dream.php")
                    if(sa == "1"){
                        dispatch_async(dispatch_get_main_queue(), {
                            self.navigationItem.rightBarButtonItems = []
                            self.GameOverView!.hidden = true
                            self.setupViews()
                            self.initViewControllers()
                        })
                    }
                })
            }
        }else if actionSheet == self.cancelSheet {
            if buttonIndex == 0 {
                self.onViewCloseClick()
            }
        }
    }
    
    func gameoverButton(word:String)->UIButton{
        var button = UIButton(frame: CGRectMake(0, 0, 240, 40))
        button.backgroundColor = BarColor
        button.setTitle(word, forState: UIControlState.Normal)
        button.titleLabel!.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.layer.cornerRadius = 3
        return button
    }
    
    //每个按钮跳转到哪个页面
    func initViewControllers()
    {
        var storyboardExplore = UIStoryboard(name: "Explore", bundle: nil)
        var NianStoryBoard:UIStoryboard = UIStoryboard(name: "NianViewController", bundle: nil)
        var NianViewController:UIViewController = NianStoryBoard.instantiateViewControllerWithIdentifier("NianViewController") as UIViewController
        var vc2 = storyboardExplore.instantiateViewControllerWithIdentifier("ExploreViewController") as UIViewController
        var vc3 = ExploreController()
        var vc1 = NianViewController
        var vc4 = MeViewController()
        var vc5 = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.viewControllers = [vc1, vc2, vc5, vc4, vc3]
        self.customizableViewControllers = nil
        self.selectedIndex = 0
    }
    
    //底部的按钮按下去
    func tabBarButtonClicked(sender:UIButton){
        var index = sender.tag
        for var i = 0;i<5;i++ {
            var button = self.view.viewWithTag(i+100) as UIButton
            if button.tag == index{
                button.selected = true
            }else{
                button.selected = false
            }
        }
        if index != 102 {
            self.selectedIndex = index-100
        }
        
        //标题
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = itemArray[index-100] as String
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        let idDream = 100
        let idExplore = 101
        let idUpdate = 102
        let idMe = 103
        let idBBS = 104
        
        if index == idExplore {       //关注
            NSNotificationCenter.defaultCenter().postNotificationName("foRefresh", object: self.foFreshTimes)
            self.foFreshTimes = self.foFreshTimes + 1
            self.bbsFreshTimes = 0
            noticeDot()
        }else if index == idBBS {     //广场
            NSNotificationCenter.defaultCenter().postNotificationName("bbsRefresh", object: self.bbsFreshTimes)
            self.bbsFreshTimes = self.bbsFreshTimes + 1
            self.foFreshTimes = 0
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addBBSButton")
            rightButton.image = UIImage(named:"plus")
            self.navigationItem.rightBarButtonItem = rightButton
            noticeDot()
        }else if index == idDream {     //梦想
            self.foFreshTimes = 0
            self.bbsFreshTimes = 0
            self.navigationItem.rightBarButtonItem = nil
            noticeDot()
        }else if index == idMe {     //消息
            self.dot!.hidden = true
            NSNotificationCenter.defaultCenter().postNotificationName("noticeShare", object:"1")
            self.foFreshTimes = 0
            self.bbsFreshTimes = 0
            self.navigationItem.rightBarButtonItem = nil
        }else if index == idUpdate {      //设置
            self.addStep()
        }
    }
    
    func addDreamButton(){
        var adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    func addBBSButton(){
        var adddreamVC = AddBBSController(nibName: "AddBBSController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func niceShow(text:String){
        self.niceView!.hidden = false
        self.niceViewLabel!.text = text
        if self.animationBool == 0 {
            self.animationBool = 1
        UIView.animateWithDuration(0.3, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
            self.niceView!.setY(0)
            }, completion: { (complete: Bool) in
                UIView.animateWithDuration(0.1, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                    self.niceView!.setY(-5)
                    }, completion: { (complete: Bool) in
                        UIView.animateWithDuration(0.1, delay:2, options: UIViewAnimationOptions.allZeros, animations: {
                            self.niceView!.setY(0)
                            }, completion: { (complete: Bool) in
                                UIView.animateWithDuration(0.3, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                                    self.niceView!.setY(-40)
                                    }, completion: { (complete: Bool) in
                                        self.animationBool = 0
                                })
                        })
                })
            })
        }
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
            self.addStepView.setX(globalWidth/2-140)
            self.addStepView.setY(globalHeight/2-106)
            self.addView.addSubview(self.addStepView)
            
            self.viewClose = UIImageView(frame: CGRectMake(10, 20, 44, 44))
            self.viewClose.image = UIImage(named: "closeBlue")
            self.viewClose.contentMode = UIViewContentMode.Center
            self.viewClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCloseConfirm"))
            self.viewClose.userInteractionEnabled = true
            self.addView.addSubview(self.viewClose)
            
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
        if (self.addStepView.textView.text != "进展正文") & (self.addStepView.textView.text != "") {
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
        if (self.addStepView.textView.text != "进展正文") & (self.addStepView.textView.text != "") {
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
    
}
