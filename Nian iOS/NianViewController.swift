//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol AddDreamDelegate {
    func addDreamCallback(id: String, img: String, title: String)
}

protocol DeleteDreamDelegate {
    func deleteDreamCallback(id: String)
}

class NianViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, NIAlertDelegate, AddDreamDelegate, DeleteDreamDelegate, ShareDelegate {
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
    @IBOutlet var imageSettings: UIImageView!
//    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet weak var dynamicSummary: UIButton!
    
    var currentCell:Int = 0
    var lastPoint:CGPoint!
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    var navView: UIImageView!
    var viewHeader: UIView!
    var birthday: String = ""
    
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    var heightScroll:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        load()
    }
    
    func setupViews(){
        let frameSquare = CGRectMake(0, 0, globalWidth, 320)
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
        self.UserName.frame.origin.x = globalWidth/2-120
        self.UserStep.frame.origin.x = globalWidth/2-65
        self.coinButton.frame.origin.x = globalWidth/2-104
        self.levelButton.frame.origin.x = globalWidth/2-104+108
        
//        self.activity.setX(globalWidth - 32)
//        self.activity.hidden = true
        self.dynamicSummary.setX(globalWidth - 44)
        self.dynamicSummary.addTarget(self, action: "toActivitiesSummary:", forControlEvents: .TouchUpInside)
        
        self.UserHead.layer.cornerRadius = 30
        self.UserHead.layer.masksToBounds = true
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.labelTableRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addDreamButton"))
        
        self.navView = UIImageView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.navView.hidden = true
        self.navView.clipsToBounds = true
        self.navView.userInteractionEnabled = true
        self.view.addSubview(self.navView)
        
        viewHeader = UIView(frame: CGRectMake(0, 375, globalWidth, 200))
        let viewQuestionHeader = viewEmpty(globalWidth, content: "先随便写个记本吧\n比如日记、英语、画画...")
        viewQuestionHeader.setY(0)
        let btnGoHeader = UIButton()
        btnGoHeader.setButtonNice("  嗯！")
        btnGoHeader.setX(globalWidth/2-50)
        btnGoHeader.setY(viewQuestionHeader.bottom())
        btnGoHeader.addTarget(self, action: "addDreamButton", forControlEvents: UIControlEvents.TouchUpInside)
        viewHeader.addSubview(viewQuestionHeader)
        viewHeader.addSubview(btnGoHeader)
        viewHeader.hidden = true
        self.scrollView.addSubview(viewHeader)
        
        let nib = UINib(nibName: "NianCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "NianCell")
        
        let safename = Cookies.get("user") as? String
        let cacheCoverUrl = Cookies.get("coverUrl") as? String
        
        if safename != nil {
            self.UserName.text = "\(safename!)"
        }
        self.UserHead.setHead(SAUid())
        
        if cacheCoverUrl != nil && cacheCoverUrl != "http://img.nian.so/cover/!cover" && cacheCoverUrl != "http://img.nian.so/cover/background.png!cover" {
            self.imageBG.setCover(cacheCoverUrl!)
        } else {
            self.imageBG.image = UIImage(named: "bg")
            self.imageBG.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        self.setupUserTop()
        self.coinButton.addTarget(self, action: "coinClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headClick"))
        imageSettings.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headClick"))
        imageSettings.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "EggShell:"))
        self.viewHolderHead.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.imageBadge.setX(globalWidth/2 + 60/2 - 14)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "QuickActionsEgg", name: "QuickActionsEgg", object: nil)
    }
    
    func EggShell(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            showEgg()
        }
    }
    
    var i = 0
    // 3D Touch 下的调用彩蛋
    func QuickActionsEgg() {
        showEgg()
    }
    
    func showEgg() {
        let eggShell = NIAlert()
        eggShell.delegate = self
        eggShell.dict = NSMutableDictionary(objects: [UserHead, " 彩蛋！", "你在念的第一瞬间\n\(self.birthday)", ["太开心"]], forKeys: ["img", "title", "content", "buttonArray"])
        eggShell.showWithAnimation(.flip)
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            let skView = SKView(frame: CGRectMake(0, 0, 272, 108))
            if #available(iOS 8.0, *) {
                skView.allowsTransparency = true
            }
            eggShell._containerView!.addSubview(skView)
            scene.scaleMode = SKSceneScaleMode.AspectFit
            skView.presentScene(scene)
            scene.setupViews()
            eggShell._containerView?.sendSubviewToBack(skView)
        }
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        niAlert.dismissWithAnimation(.normal)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let height = scrollView.contentOffset.y
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
                }
                scrollHidden(self.viewHolderHead, scrollY: 68)
                scrollHidden(self.imageBadge, scrollY: 68)
                scrollHidden(self.UserName, scrollY: 138)
                scrollHidden(self.UserStep, scrollY: 161)
                scrollHidden(self.coinButton, scrollY: 214)
                scrollHidden(self.levelButton, scrollY: 214)
                scrollHidden(self.imageSettings, scrollY: 50)
                scrollHidden(self.dynamicSummary, scrollY: 50)
                if height >= 320 - 64 {
                    self.navView.hidden = false
                }else{
                    self.navView.hidden = true
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let visiblePaths = self.collectionView!.indexPathsForVisibleItems() as Array
        
        for item in visiblePaths {
            let indexPath = item 
            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath) as! NianCell
            if cell.imageCover.image == nil {
            
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
        let safeuid = SAUid()
        if let uid = Int(safeuid) {
            Api.getUserTop(uid){ json in
                if json != nil {
                    let error = json!.objectForKey("error") as? NSNumber
                    if error == 0 {
                        let _data = json!.objectForKey("data") as! NSDictionary
                        let data = _data.objectForKey("user") as! NSDictionary
                        //                    let data = json!.objectForKey("user") as! NSDictionary
                        let name = data.stringAttributeForKey("name")
                        let coin = data.stringAttributeForKey("coin")
                        let dream = data.stringAttributeForKey("dream")
                        let step = data.stringAttributeForKey("step")
                        let coverURL = data.stringAttributeForKey("cover")
                        self.birthday = V.relativeTime(data.stringAttributeForKey("lastdate"))
                        let petCount = data.stringAttributeForKey("pet_count")
                        let AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
                        let vip = data.stringAttributeForKey("vip")
                        let deadLine = data.stringAttributeForKey("deadline")
                        self.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
                        self.levelButton.setTitle("宠物 \(petCount)", forState: UIControlState.Normal)
                        self.UserName.text = "\(name)"
                        Cookies.set(name, forKey: "user")
                        self.UserHead.setHead(safeuid)
                        self.imageBadge.setType(vip)
                        if deadLine == "0" {
                            self.UserStep.text = "\(dream) 记本，\(step) 进展"
                        } else {
                            self.UserStep.text = "倒计时 \(deadLine)"
                        }
                        if coverURL == "" {
                            self.imageBG.image = UIImage(named: "bg")
                            self.navView.image = UIImage(named: "bg")
                            self.navView.contentMode = UIViewContentMode.ScaleAspectFill
                        }else{
                            self.navView.setCover(AllCoverURL)
                            self.imageBG.setCover(AllCoverURL)
                        }
                        Cookies.set(name, forKey: "user")
                        Cookies.set(AllCoverURL, forKey: "coverUrl")
                    } else {
                        self.SAlogout()
                    }
                }
            }
        }
    }
    
    /* 添加记本后，首页上相应地产生变化
    */
    func addDreamCallback(id: String, img: String, title: String) {
        let data = NSDictionary(objects: [id, img, title], forKeys: ["id", "image", "title"])
        dataArray.insertObject(data, atIndex: dataArray.count)
        Cookies.set(dataArray, forKey: "NianDreams")
        reloadFromDataArray()
    }
    
    /* 删除记本后，首页上相应地产生变化
    */
    func deleteDreamCallback(id: String) {
        if dataArray.count > 0 {
            for i in 0...(dataArray.count - 1) {
                let data = dataArray[i] as! NSDictionary
                let _id = data.stringAttributeForKey("id")
                if _id == id {
                    dataArray.removeObjectAtIndex(i)
                    reloadFromDataArray()
                    Cookies.set(dataArray, forKey: "NianDreams")
                    break
                }
            }
        }
    }
    
    func addDreamButton(){
        let vc = AddDreamController(nibName: "AddDreamController", bundle: nil)
        vc.delegateAddDream = self
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func onDreamLabelClick(sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        self.onDreamClick("\(tag)")
    }
    
    func stepClick(){
        let safeuid = SAUid()
        let userVC = PlayerViewController()
        userVC.Id = "\(safeuid)"
        self.navigationController!.pushViewController(userVC, animated: true)
    }
    
    func levelClick(){
        let vc = PetViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func coinClick(){
        let storyboard = UIStoryboard(name: "Coin", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("CoinViewController") 
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func NianReload(sender: UIButton) {
        sender.setTitle("加载中", forState: UIControlState())
        self.load()
        self.setupUserTop()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navShow()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navHide()
        if globalWillNianReload == 1 {
            globalWillNianReload = 0
            self.load()
            self.setupUserTop()
        }
    }
    
    /**
     进入新的设置页面
     */
    func headClick(){
        let vc = NewSettingViewController(nibName: "NewSettingView", bundle: nil)
        vc.coverImage = self.imageBG.image
        vc.avatarImage = self.UserHead.image
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     进入汇总页
     */
    func toActivitiesSummary(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "ActivitiesSummary", bundle: nil)
        let vc = storyBoard.instantiateViewControllerWithIdentifier("ActivitiesViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onDreamClick(ID:String){
        if ID != "0" && ID != "" {
            let vc = DreamViewController()
            vc.Id = ID
            vc.delegateDelete = self
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func onDreamLikeClick(sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let LikeVC = LikeViewController()
        LikeVC.Id = "\(tag)"
        LikeVC.urlIdentify = 3
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func load(){
        // 从本地加载记本数据
        let NianDreams = Cookies.get("NianDreams") as? NSMutableArray
        if NianDreams != nil {
            let mutableArrayLocal = NSMutableArray()
            for data: AnyObject in NianDreams! {
                mutableArrayLocal.addObject(data)
            }
            self.dataArray = mutableArrayLocal
            reloadFromDataArray()
        }
        // todo: 加上网络检测动画
//        activity.hidden = false
//        activity.startAnimating()
        
        // 从服务器加载记本数据
        Api.getNian() { json in
            if json != nil {
//                self.activity.hidden = true
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    let d = json!.objectForKey("data") as! NSDictionary
                    let arr = d.objectForKey("dreams") as! NSArray
                    
                    let mutableArray = NSMutableArray()
                    
                    var idArrayLocal: [Int] = []
                    var idArrayRemote: [Int] = []
                    
                    // 创建远程记本数组，以及记本的编号数组
                    for data: AnyObject  in arr {
                        mutableArray.addObject(data)
                        let d = data as! NSDictionary
                        if let id = Int(d.stringAttributeForKey("id")) {
                            idArrayRemote.append(id)
                        }
                    }
                    
                    // 创建本地记本数组，以及记本的编号数组
                    for data: AnyObject in self.dataArray {
                        let d = data as! NSDictionary
                        if let id = Int(d.stringAttributeForKey("id")) {
                            idArrayLocal.append(id)
                        }
                    }
                    
                    /* 当记本在本地和服务器两边数据不相同时
                    ** 以服务器的数据为准
                    ** 同时服务器的数据会覆盖本地的数据
                    */
                    if bubble(idArrayRemote) != bubble(idArrayLocal) {
                        let count = self.dataArray.count + 2
                        if globalhasLaunched == 0 {
                            let time = Double(count) * 0.2
                            delay(time, closure: { () -> () in
                                // 加载服务器数据
                                globalhasLaunched = 1
                                self.dataArray = mutableArray
                                Cookies.set(self.dataArray, forKey: "NianDreams")
                                self.reloadFromDataArray()
                            })
                        } else {
                            // 启动后不延时
                            self.dataArray = mutableArray
                            Cookies.set(self.dataArray, forKey: "NianDreams")
                            self.reloadFromDataArray()
                        }
                    } else {
                        /* 本地与服务器的记本完全相同
                        ** 在完成卡片动画后关闭动画选项
                        */
                        let count = self.dataArray.count + 2
                        if globalhasLaunched == 0 {
                            let time = Double(count) * 0.2
                            delay(time, closure: { () -> () in
                                globalhasLaunched = 1
                            })
                        }
                    }
                }
            }
        }
        
        Api.postDeviceToken() { string in
        }
    }
    
    func reloadFromDataArray() {
        self.collectionView.reloadData()
        let height = ceil(CGFloat(self.dataArray.count) / 3) * 125
        self.collectionView.frame = CGRectMake(globalWidth/2 - 140, 320 + 55, 280, height)
        let heightContentSize = globalHeight - 49 + 1 > 640 ? globalHeight - 49 + 1 : 640
        self.scrollView.contentSize.height = heightContentSize > height + 375 + 45 ? heightContentSize : height + 375 + 45
        self.collectionView.contentSize.height = height
        if self.dataArray.count == 0 {
            self.viewHeader.hidden = false
        }else{
            self.viewHeader.hidden = true
        }
        globalNumberDream = self.dataArray.count
    }
    
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func saegg(coin: String, totalCoin: String) {
        /* 更新后在首页上更新念币数量 */
        if coinButton.currentTitle != nil {
            if let cBefore = Int(SAReplace(coinButton.currentTitle!, before: "念币 ", after: "") as String) {
                if let coin = Int(coin) {
                    let cAfter = coin + cBefore
                    coinButton.setTitle("念币 \(cAfter)", forState: UIControlState.Normal)
                }
            }
        }
        /* 如果念币小于 3 */
        if Int(totalCoin) <  3 {
            let ni = NIAlert()
            ni.delegate = self
            ni.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "你获得了念币奖励", ["好"]], forKeys: ["img", "title", "content", "buttonArray"])
            ni.showWithAnimation(.flip)
        } else {
            /* 如果念币多于 3，就出现宠物 */
            let v = SAEgg()
            v.delegateShare = self
            v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "要以 3 念币抽一次\n宠物吗？", ["嗯！", "不要"]], forKeys: ["img", "title", "content", "buttonArray"])
            v.showWithAnimation(.flip)
        }
        
    }
}


extension NianViewController: NewSettingDelegate {
    func setting(name name: String?, cover: UIImage?, avatar: UIImage?) {
        if let _name = name {
            self.UserName.text = _name
        }
        
        if let _cover = cover {
            self.imageBG.image = _cover
        }
        
        if let _avatar = avatar {
            self.UserHead.image = _avatar
        }
        
    }
    
}







