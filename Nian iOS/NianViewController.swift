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

class NianViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NIAlertDelegate {
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
    @IBOutlet var activity: UIActivityIndicatorView!
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
        SAReloadData()
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
        self.UserName.frame.origin.x = globalWidth/2-75
        self.UserStep.frame.origin.x = globalWidth/2-65
        self.coinButton.frame.origin.x = globalWidth/2-104
        self.levelButton.frame.origin.x = globalWidth/2-104+108
        
        self.activity.setX(globalWidth - 32)
        self.activity.hidden = true
        
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
        
        /* 这里本来是从 NSUserDefaults 里面读出来的 */
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let safename = Sa.objectForKey("user") as! String
        let cacheCoverUrl = Sa.objectForKey("coverUrl") as? String
        
        self.UserName.text = "\(safename)"
        self.UserHead.setHead(safeuid)
        
        if (cacheCoverUrl != nil) && (cacheCoverUrl! != "http://img.nian.so/cover/!cover") {
            self.imageBG.setCover(cacheCoverUrl!, placeHolder: UIColor.blackColor(), bool: false)
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
    }
    
    func EggShell(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let eggShell = NIAlert()
            eggShell.delegate = self
            eggShell.dict = NSMutableDictionary(objects: [UserHead, " 彩蛋！", "你在念上的第一秒\n\(self.birthday)", ["太开心"]], forKeys: ["img", "title", "content", "buttonArray"])
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
             //       self.imageBG.backgroundColor = UIColor.redColor()
                }
                scrollHidden(self.viewHolderHead, scrollY: 68)
                scrollHidden(self.imageBadge, scrollY: 68)
                scrollHidden(self.UserName, scrollY: 138)
                scrollHidden(self.UserStep, scrollY: 161)
                scrollHidden(self.coinButton, scrollY: 214)
                scrollHidden(self.levelButton, scrollY: 214)
                scrollHidden(self.imageSettings, scrollY: 50)
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
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let safeuid = SAUid()
        Api.getUserTop(Int(safeuid)!){ json in
            if json != nil {
                let data = json!.objectForKey("user") as! NSDictionary
                let name = data.stringAttributeForKey("name")
                let coin = data.stringAttributeForKey("coin")
                let dream = data.stringAttributeForKey("dream")
                let step = data.stringAttributeForKey("step")
                let coverURL = data.stringAttributeForKey("cover")
                self.birthday = data.stringAttributeForKey("lastdate")
                let petCount = data.stringAttributeForKey("pet_count")
                let AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
                let vip = data.stringAttributeForKey("vip")
                Sa.setObject(AllCoverURL, forKey: "coverUrl")
                Sa.synchronize()
                let deadLine = data.stringAttributeForKey("deadline")
                self.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
                self.levelButton.setTitle("宠物 \(petCount)", forState: UIControlState.Normal)
                self.UserName.text = "\(name)"
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
                    self.imageBG.setCover(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                    self.navView.setCover(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                }
            }
        }
    }
    
    func addDreamButton(){
        let adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    func onDreamLabelClick(sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        self.onDreamClick("\(tag)")
    }
    
    func stepClick(){
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//        var safeshell = uidKey.objectForKey(kSecValueData) as! String
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
        self.SAReloadData()
        self.setupUserTop()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navShow()
    }
    
    override func viewDidAppear(animated: Bool) {
        navHide()
        if globalWillNianReload == 1 {
            globalWillNianReload = 0
            self.SAReloadData()
            self.setupUserTop()
        }
    }
    
    func headClick(){
        let PlayerVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.navigationController!.pushViewController(PlayerVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        let index = indexPath.row
        let c = collectionView.dequeueReusableCellWithReuseIdentifier("NianCell", forIndexPath: indexPath) as! NianCell
        let data = self.dataArray[index] as! NSDictionary
        c.data = data
        c.total = self.dataArray.count
        
        c.labelTitle.text = (data.stringAttributeForKey("title") as NSString).stringByDecodingHTMLEntities().stringByDecodingHTMLEntities()
        c.imageCover.setHolder()

        var img = data.stringAttributeForKey("img")
        if img != "" {
            img = "http://img.nian.so/dream/\(img)!dream"
            c.imageCover.setCover(img, placeHolder: IconColor, bool: false)
        }

        cell = c
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        self.onDreamClick(id)
    }
    
    func onDreamClick(ID:String){
        if ID != "0" && ID != "" {
            let DreamVC = DreamViewController()
            DreamVC.Id = ID
            self.navigationController!.pushViewController(DreamVC, animated: true)
        }
    }
    
    func onDreamLikeClick(sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let LikeVC = LikeViewController()
        LikeVC.Id = "\(tag)"
        LikeVC.urlIdentify = 3
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func SAReloadData(){
        if let NianDream = Cookies.get("NianDream") as? NSMutableArray {
            self.dataArray = NianDream
            reloadFromDataArray()
        }
        
        activity.hidden = false
        activity.startAnimating()
            Api.getNian() { json in
                if json != nil {
                    self.activity.hidden = true
                    let arr = json!.objectForKey("items") as! NSArray
//                    self.dataArray.removeAllObjects()
                    let mutableArray = NSMutableArray()
                    for data : AnyObject  in arr {
                        mutableArray.addObject(data)
                    }
                    self.dataArray = mutableArray
                    Cookies.set(self.dataArray, forKey: "NianDream")
                    self.reloadFromDataArray()
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
}