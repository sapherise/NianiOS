//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class NianViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet var coinButton:UIButton!
    @IBOutlet var levelButton:UIButton!
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var UserStep:UILabel!
    @IBOutlet var imageBG:UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var labelTableRight: UILabel!
    @IBOutlet var labelTableLeft: UILabel!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var imageBadge: SABadgeView!
    @IBOutlet var viewHolderHead: UIView!
    var currentCell:Int = 0
    var lastPoint:CGPoint!
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    var navView: UIImageView!
    var viewErr: UIView!
    var viewHeader: UIView!
    
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    var heightScroll:CGFloat = 0
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
    }
    
    
    func setupViews(){
        var frameSquare = CGRectMake(0, 0, globalWidth, 320)
        self.view.frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
        self.scrollView.contentSize.height = globalHeight - 49 + 1 > 640 ? globalHeight - 49 + 1 : 640
        self.extendedLayoutIncludesOpaqueBars = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        
        self.viewHolder.frame = frameSquare
        self.imageBG.frame = frameSquare
        self.viewMenu.setWidth(globalWidth)
        self.labelTableLeft.setX(globalWidth/2 - 160 + 20)
        self.labelTableRight.setX(globalWidth/2 + 160 - 20 - 80)
        self.viewHolderHead.frame.origin.x = globalWidth/2-32
        self.UserName.frame.origin.x = globalWidth/2-75
        self.UserStep.frame.origin.x = globalWidth/2-65
        self.coinButton.frame.origin.x = globalWidth/2-104
        self.levelButton.frame.origin.x = globalWidth/2-104+108
        
        //        var pan = UIPanGestureRecognizer(target: self, action: "pan:")
        //        pan.delegate = self
        //        self.scrollView.addGestureRecognizer(pan)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.labelTableRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addDreamButton"))
        
        self.navView = UIImageView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.navView.hidden = true
        self.navView.clipsToBounds = true
        self.navView.userInteractionEnabled = true
        self.view.addSubview(self.navView)
        
        // 加载中时
        viewErr = UIView(frame: CGRectMake(0, 375, globalWidth, 200))
        var viewQuestion = viewEmpty(globalWidth, content: "正在连接念的服务器")
        viewQuestion.setY(0)
        var btnGo = UIButton()
        btnGo.setButtonNice("再试一试")
        btnGo.setX(globalWidth/2-50)
        btnGo.setY(viewQuestion.bottom())
        btnGo.addTarget(self, action: "NianReload:", forControlEvents: UIControlEvents.TouchUpInside)
        viewErr.addSubview(viewQuestion)
        viewErr.addSubview(btnGo)
        self.scrollView.addSubview(viewErr)
        
        viewHeader = UIView(frame: CGRectMake(0, 375, globalWidth, 200))
        var viewQuestionHeader = viewEmpty(globalWidth, content: "先随便写个梦想吧\n比如日记、英语、画画...")
        viewQuestionHeader.setY(0)
        var btnGoHeader = UIButton()
        btnGoHeader.setButtonNice("  嗯！")
        btnGoHeader.setX(globalWidth/2-50)
        btnGoHeader.setY(viewQuestionHeader.bottom())
        btnGoHeader.addTarget(self, action: "addDreamButton", forControlEvents: UIControlEvents.TouchUpInside)
        viewHeader.addSubview(viewQuestionHeader)
        viewHeader.addSubview(btnGoHeader)
        viewHeader.hidden = true
        self.scrollView.addSubview(viewHeader)
        
        var nib = UINib(nibName: "NianCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "NianCell")
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safename = Sa.objectForKey("user") as! String
        var cacheCoverUrl = Sa.objectForKey("coverUrl") as? String
        self.UserName.text = "\(safename)"
        self.UserHead.setHead(safeuid)
        if (cacheCoverUrl != nil) && (cacheCoverUrl! != "http://img.nian.so/cover/!cover") {
            self.imageBG.setCover(cacheCoverUrl!, placeHolder: UIColor.blackColor(), bool: false)
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
        self.viewHolderHead.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.imageBadge.setX(globalWidth/2 + 60/2 - 14)
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
                        self.imageBG.frame = CGRectMake(0, height, globalWidth, 320 - height)
                        self.imageBG.hidden = false
                    }
                }else{
                    self.viewHolder!.setY(height)
                    self.viewMenu.setY(height + 320)
                    self.imageBG.frame = CGRectMake(height/10, height, globalWidth-height/5, 320)
             //       self.imageBG.backgroundColor = UIColor.redColor()
                }
                scrollHidden(self.viewHolderHead, scrollY: 68)
                scrollHidden(self.imageBadge, scrollY: 68)
                scrollHidden(self.UserName, scrollY: 138)
                scrollHidden(self.UserStep, scrollY: 161)
                scrollHidden(self.coinButton, scrollY: 214)
                scrollHidden(self.levelButton, scrollY: 214)
                if height >= 320 - 64 {
                    self.navView.hidden = false
                }else{
                    self.navView.hidden = true
                }
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setupUserTop(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safename = Sa.objectForKey("user") as! String
        var cacheCoverUrl = Sa.objectForKey("coverUrl") as? String
        Api.getUserTop(safeuid.toInt()!){ json in
            if json != nil {
                var data = json!.objectForKey("user") as! NSDictionary
                var name = data.stringAttributeForKey("name")
                var email = data.stringAttributeForKey("email")
                var coin = data.stringAttributeForKey("coin")
                var dream = data.stringAttributeForKey("dream")
                var step = data.stringAttributeForKey("step")
                var level = data.stringAttributeForKey("level")
                var coverURL = data.stringAttributeForKey("cover")
                var AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
                var vip = data.stringAttributeForKey("vip")
                Sa.setObject(AllCoverURL, forKey: "coverUrl")
                Sa.synchronize()
                var deadLine = data.stringAttributeForKey("deadline")
                var (l, e) = levelCount( (level.toInt()!)*7 )
                self.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
                self.levelButton.setTitle("等级 \(l)", forState: UIControlState.Normal)
                self.UserName.text = "\(name)"
                self.UserHead.setHead(safeuid)
                self.imageBadge.setType(vip)
                if deadLine == "0" {
                    self.UserStep.text = "\(dream) 梦想，\(step) 进展"
                }else{
                    self.UserStep.text = "倒计时 \(deadLine)"
                }
                if coverURL == "" {
                    self.imageBG.image = UIImage(named: "bg")
                    self.navView.image = UIImage(named: "bg")
                    self.navView.contentMode = UIViewContentMode.ScaleAspectFill
                }else{
                    self.imageBG.setCover(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                    self.navView.setCover(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
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
        var safeuid = Sa.objectForKey("uid") as! String
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
        var viewController = storyboard.instantiateViewControllerWithIdentifier("CoinViewController") as! UIViewController
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if globalWillNianReload == 1 {
            globalWillNianReload = 0
            self.SAReloadData()
            self.setupUserTop()
        }
    }
    
    func NianReload(sender: UIButton) {
        sender.setTitle("加载中", forState: UIControlState.allZeros)
        self.SAReloadData()
        self.setupUserTop()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navShow()
    }
    
    override func viewDidAppear(animated: Bool) {
        navHide()
    }
    
    func headClick(){
        var PlayerVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.navigationController!.pushViewController(PlayerVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        var index = indexPath.row
        var c = collectionView.dequeueReusableCellWithReuseIdentifier("NianCell", forIndexPath: indexPath) as! NianCell
        var data = self.dataArray[index] as! NSDictionary
        c.data = data
        c.total = self.dataArray.count
        
        c.labelTitle.text = data.stringAttributeForKey("title")
        c.imageCover.setHolder()
        
        //使用这个方法让 table 响应更顺畅
        if !self.collectionView.decelerating && !self.collectionView.dragging {
            var img = data.stringAttributeForKey("img")
            if img != "" {
                img = "http://img.nian.so/dream/\(img)!dream"
                c.imageCover.setCover(img, placeHolder: IconColor, bool: false)
            }
        }

        cell = c
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
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
                self.viewErr.hidden = true
                var arr = json!["items"] as! NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.collectionView.reloadData()
                var height = ceil(CGFloat(self.dataArray.count) / 3) * 125
                self.collectionView.frame = CGRectMake(globalWidth/2 - 140, 320 + 55, 280, height)
                var heightContentSize = globalHeight - 49 + 1 > 640 ? globalHeight - 49 + 1 : 640
                self.scrollView.contentSize.height = heightContentSize > height + 375 + 45 ? heightContentSize : height + 375 + 45
                self.collectionView.contentSize.height = height
                if self.dataArray.count == 0 {
                    self.viewHeader.hidden = false
                }else{
                    self.viewHeader.hidden = true
                }
                globalNumberDream = self.dataArray.count
            }
        }
    }
}