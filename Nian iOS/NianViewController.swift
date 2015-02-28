//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class NianViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate{
    @IBOutlet var coinButton:UIButton!
    @IBOutlet var levelButton:UIButton!
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var UserStep:UILabel!
    @IBOutlet var imageBG:UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var labelTableRight: UILabel!
    @IBOutlet var viewMenu: UIView!
    var currentCell:Int = 0
    var lastPoint:CGPoint!
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    var heightScroll:CGFloat = 0
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
    }
    
    
    func setupViews(){
        var frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
        var frameSquare = CGRectMake(0, 0, globalWidth, 320)
        self.view.frame = frame
        self.scrollView.frame = frame
        self.extendedLayoutIncludesOpaqueBars = true
        self.scrollView.contentSize.height = globalHeight - 49 + 1
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
        self.viewHolder.frame = frameSquare
        self.imageBG.frame = frameSquare
        self.viewMenu.frame = CGRectMake(0, 320, globalWidth, 45)
        self.labelTableRight.setX(globalWidth - 20 - 80)
        self.UserHead.frame.origin.x = globalWidth/2-30
        self.UserName.frame.origin.x = globalWidth/2-75
        self.UserStep.frame.origin.x = globalWidth/2-65
        self.coinButton.frame.origin.x = globalWidth/2-104
        self.levelButton.frame.origin.x = globalWidth/2-104+108
        
        var pan = UIPanGestureRecognizer(target: self, action: "pan:")
        pan.delegate = self
        self.scrollView.addGestureRecognizer(pan)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.transform = CGAffineTransformMakeRotation( CGFloat(-M_PI/2) )
        self.tableView.frame = CGRectMake(0, 320 + 45, globalWidth, 160)
        self.tableView.contentSize.height = CGFloat(self.dataArray.count * 100)
        self.labelTableRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addDreamButton"))
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        // 加载中时
        var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
        var viewQuestion = viewEmpty(globalWidth, content: "正在连接念的服务器")
        viewQuestion.setY(0)
        var btnGo = UIButton()
        btnGo.setButtonNice("再试一试")
        btnGo.setX(globalWidth/2-50)
        btnGo.setY(viewQuestion.bottom())
        btnGo.addTarget(self, action: "NianReload:", forControlEvents: UIControlEvents.TouchUpInside)
        viewHeader.addSubview(viewQuestion)
        viewHeader.addSubview(btnGo)
        viewHeader.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        self.tableView.tableHeaderView = viewHeader
        self.tableView.tableFooterView = UIView()
        
        var nib = UINib(nibName: "NianCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "NianCell")
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        var cacheCoverUrl = Sa.objectForKey("coverUrl") as? String
        self.UserName.text = "\(safename)"
        self.UserHead.setImage("http://img.nian.so/head/\(safeuid).jpg!dream", placeHolder: UIColor(red: 0, green: 0, blue: 0, alpha: 0.55))
        if (cacheCoverUrl != nil) && (cacheCoverUrl! != "http://img.nian.so/cover/!cover") {
            self.imageBG.setImage(cacheCoverUrl!, placeHolder: UIColor.blackColor(), bool: false)
        }else{
            self.imageBG.image = UIImage(named: "bg")
            self.imageBG.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        
        self.setupUserTop()
        self.coinButton.addTarget(self, action: "coinClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headClick"))
        
        if globaliPhone == 4 {
            self.viewHolder.setHeight(232)
            self.imageBG.setHeight(232)
            self.tableView.setY(276)
            self.viewMenu.setY(232)
            self.UserHead.setY(64)
            self.UserName.setY(132)
            self.UserStep.hidden = true
            self.coinButton.setY(170)
            self.levelButton.setY(170)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var height = scrollView.contentOffset.y
            self.heightScroll = height
            if self.viewHolder != nil {
                if height > 0 {
                    if height > globalWidth {
                        self.imageBG.hidden = true
                    }else{
                        self.imageBG.frame = CGRectMake(0, height, globalWidth, globalWidth - height)
                        self.imageBG.hidden = false
                    }
                }else{
                    self.viewHolder!.setY(height)
                    self.imageBG.frame = CGRectMake(height/10, height, globalWidth-height/5, globalWidth)
                    self.imageBG.backgroundColor = UIColor.redColor()
                }
                scrollHidden(self.UserHead, scrollY: 70)
                scrollHidden(self.UserName, scrollY: 138)
                scrollHidden(self.UserStep, scrollY: 161)
            }
        }
    }
    
    func scrollHidden(theView:UIView, scrollY:CGFloat){
        if ( self.heightScroll > scrollY - 50 && self.heightScroll <= scrollY ) {
            theView.alpha = ( scrollY - self.heightScroll ) / 50
        }else if self.heightScroll > scrollY {
            theView.alpha = 0
        }else{
            theView.alpha = 1
        }
    }
    
    func pan(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            var h: CGFloat = globaliPhone == 4 ? 232 : globalWidth
            // 当向上滑动时
            if self.heightScroll > 60 {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    self.scrollView.contentSize.height = globalHeight - 49 + h - 64 + 1
                    self.scrollView.frame = CGRectMake(0, -h + 64, globalWidth, globalHeight - 49 - 64 + h)
                    self.coinButton.alpha = 0
                    self.levelButton.alpha = 0
                    }, completion: { (Bool) -> Void in
                })
            // 当向下滑动时
            }else if self.heightScroll < 0 {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    self.scrollView.contentSize.height = globalHeight - 49 + 1
                    self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
                    self.coinButton.alpha = 1
                    self.levelButton.alpha = 1
                    }, completion: { (Bool) -> Void in
                })
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setupUserTop(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        var cacheCoverUrl = Sa.objectForKey("coverUrl") as? String
        Api.getUserTop(safeuid.toInt()!){ json in
            if json != nil {
                var sa: AnyObject! = json!.objectForKey("user")
                var name: AnyObject! = sa.objectForKey("name") as String
                var email: AnyObject! = sa.objectForKey("email") as String
                var coin: AnyObject! = sa.objectForKey("coin") as String
                var dream: AnyObject! = sa.objectForKey("dream") as String
                var step: AnyObject! = sa.objectForKey("step") as String
                var level: String! = sa.objectForKey("level") as String
                var coverURL: String! = sa.objectForKey("cover") as String
                var imgURL = "http://img.nian.so/head/\(safeuid).jpg!dream" as NSString
                var AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
                Sa.setObject(AllCoverURL, forKey: "coverUrl")
                Sa.synchronize()
                var deadLine = sa.objectForKey("deadline") as String
                var (l, e) = levelCount( (level.toInt()!)*7 )
                self.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
                self.levelButton.setTitle("等级 \(l)", forState: UIControlState.Normal)
                self.UserName.text = "\(name)"
                self.UserHead.setImage(imgURL, placeHolder: UIColor(red: 0, green: 0, blue: 0, alpha: 0.55))
                if deadLine == "0" {
                    self.UserStep.text = "\(dream) 梦想，\(step) 进展"
                }else{
                    self.UserStep.text = "倒计时 \(deadLine)"
                }
                if coverURL == "" {
                    self.imageBG.image = UIImage(named: "bg")
                }else{
                    self.imageBG.setImage(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                }
            }
        }
    }
    
    func addDreamButton(){
        var adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    func onDreamLabelClick(sender:UIGestureRecognizer){
        var tag = sender.view!.tag
        self.onDreamClick("\(tag)")
    }
    
    func stepClick(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var userVC = PlayerViewController()
        userVC.Id = "\(safeuid)"
        self.navigationController!.pushViewController(userVC, animated: true)
    }
    
    func levelClick(){
        var levelVC = LevelViewController(nibName: "Level", bundle: nil)
        self.navigationController!.pushViewController(levelVC, animated: true)
    }
    
    func coinClick(){
        var storyboard = UIStoryboard(name: "Coin", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("CoinViewController") as UIViewController
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if globalWillNianReload == 1 {
            globalWillNianReload = 0
            self.SAReloadData()
            self.setupUserTop()
        }
    }
    
    func NianReload(sender: UIButton){
        sender.setTitle("加载中", forState: UIControlState.allZeros)
        self.SAReloadData()
        self.setupUserTop()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navHide(20)
    }
    
    func navHide(yPoint:CGFloat){
        if self.navigationController != nil {
            var navigationFrame = self.navigationController!.navigationBar.frame
            navigationFrame.origin.y = yPoint
            self.navigationController!.navigationBar.frame = navigationFrame
        }
    }
    
    func headClick(){
        var PlayerVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.navigationController!.pushViewController(PlayerVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var index = indexPath.row
        var c = tableView.dequeueReusableCellWithIdentifier("NianCell", forIndexPath: indexPath) as NianCell
        c.data = self.dataArray[index] as? NSDictionary
        c.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        cell = c
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var id = data.stringAttributeForKey("id")
        self.onDreamClick(id)
    }
    
    func onDreamClick(ID:String){
        if ID != "0" && ID != "" {
            var DreamVC = DreamViewController()
            DreamVC.Id = ID
            self.navigationController!.pushViewController(DreamVC, animated: true)
        }
    }
    
    func onDreamLikeClick(sender:UIGestureRecognizer){
        var tag = sender.view!.tag
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(tag)"
        LikeVC.urlIdentify = 3
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func SAReloadData(){
        Api.getNian() { json in
            if json != nil {
                var arr = json!["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                if self.dataArray.count == 0 {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                    var viewQuestion = viewEmpty(globalWidth, content: "先随便写个梦想吧\n比如日记、英语、画画...")
                    viewQuestion.setY(0)
                    var btnGo = UIButton()
                    btnGo.setButtonNice("  嗯！")
                    btnGo.setX(globalWidth/2-50)
                    btnGo.setY(viewQuestion.bottom())
                    btnGo.addTarget(self, action: "addDreamButton", forControlEvents: UIControlEvents.TouchUpInside)
                    viewHeader.addSubview(viewQuestion)
                    viewHeader.addSubview(btnGo)
                    viewHeader.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
                    self.tableView.tableHeaderView = viewHeader
                    self.tableView.tableFooterView = UIView()
                }else{
                    self.tableView.tableHeaderView = UIView()
                    self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 1, 20))
                }
                globalNumberDream = self.dataArray.count
            }
        }
    }
}