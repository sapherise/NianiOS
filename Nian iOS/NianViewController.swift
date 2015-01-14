//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class NianViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var coinButton:UIButton!
    @IBOutlet var levelButton:UIButton!
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var UserStep:UILabel!
    @IBOutlet var BGImage:UIImageView!
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
        self.extendedLayoutIncludesOpaqueBars = true
        self.scrollView.frame.size.height = globalHeight - 49
        self.scrollView.contentSize.height = globalHeight - 49
        self.scrollView.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.transform = CGAffineTransformMakeRotation( CGFloat(-M_PI/2) )
        self.tableView.frame = CGRectMake(0, 364, globalWidth, 160)
        self.tableView.contentSize.height = CGFloat(self.dataArray.count * 100)
        self.labelTableRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addDreamButton"))
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        var nib = UINib(nibName: "NianCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "NianCell")
        self.tableView.showsVerticalScrollIndicator = false
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        var cacheCoverUrl = Sa.objectForKey("coverUrl") as? String
        self.UserName.text = "\(safename)"
        self.UserHead.setImage("http://img.nian.so/head/\(safeuid).jpg!dream", placeHolder: UIColor(red: 0, green: 0, blue: 0, alpha: 0.55))
        if cacheCoverUrl != nil{
            if cacheCoverUrl! != "http://img.nian.so/cover/!cover" {
                self.BGImage.setImage(cacheCoverUrl!, placeHolder: UIColor.blackColor(), bool: false)
            }else{
                self.BGImage.image = UIImage(named: "bg")
                self.BGImage.contentMode = UIViewContentMode.ScaleAspectFill
            }
        }else{
            self.BGImage.image = UIImage(named: "bg")
            self.BGImage.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        
        self.setupUserTop()
        self.coinButton.addTarget(self, action: "coinClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headClick"))
        
        if globalHeight < 500 {
            self.viewHolder.setHeight(232)
            self.BGImage.setHeight(232)
            self.tableView.setY(276)
            self.viewMenu.setY(232)
            self.UserHead.setY(64)
            self.UserName.setY(132)
            self.UserStep.hidden = true
            self.coinButton.setY(170)
            self.levelButton.setY(170)
        }
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
                    self.BGImage.image = UIImage(named: "bg")
                }else{
                    self.BGImage.setImage(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
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
    
    
    func scrollHidden(theView:UIView, height:CGFloat, scrollY:CGFloat){
        if ( height > scrollY - 50 && height <= scrollY ) {
            theView.alpha = ( scrollY - height ) / 50
        }else if height > scrollY {
            theView.alpha = 0
        }else{
            theView.alpha = 1
        }
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
    
    func urlString()->String{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/nian.php?uid=\(safeuid)&shell=\(safeshell)"
    }
    
    func SAReloadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull(){
                var arr = data["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                if self.dataArray.count == 0 {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                    var viewQuestion = viewEmpty(globalWidth, content: "先随便写个梦想吧")
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
        })
    }
}