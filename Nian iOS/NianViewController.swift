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
    @IBOutlet var labelTableLeft: UILabel!
    @IBOutlet var labelTableMiddle: UILabel!
    @IBOutlet var labelTableRight: UILabel!
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
        self.scrollView.contentSize.height = 524
        self.scrollView.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.transform = CGAffineTransformMakeRotation( CGFloat(-M_PI/2) )
        self.tableView.frame = CGRectMake(0, 364, globalWidth, 160)
        self.tableView.contentSize.height = CGFloat(self.dataArray.count * 100)
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 1, 100))
        
        var footerView = UIView()
        footerView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        footerView.frame = CGRectMake(0, 0, 120, 160)
        var footerViewImage = UIImageView(frame: CGRectMake(20, 30, 80, 80))
        footerViewImage.layer.borderColor = UIColor.whiteColor().CGColor
        footerViewImage.layer.borderWidth = 1
        footerViewImage.image = UIImage(named: "plus")
        footerViewImage.tintColor = UIColor.redColor()
        footerViewImage.contentMode = UIViewContentMode.Center
        footerViewImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addDreamButton"))
        footerViewImage.userInteractionEnabled = true
        footerView.addSubview(footerViewImage)
        var footerViewLabel = UILabel(frame: CGRectMake(20, 118, 80, 21))
        footerViewLabel.text = "添加梦想"
        footerViewLabel.font = UIFont.boldSystemFontOfSize(13)
        footerViewLabel.textAlignment = NSTextAlignment.Center
        footerViewLabel.textColor = UIColor.whiteColor()
        footerView.addSubview(footerViewLabel)
        footerView.alpha = 0.3

        self.tableView.tableFooterView = footerView
        
        self.tableView.backgroundColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
        
        var nib = UINib(nibName: "NianCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "NianCell")
        self.tableView.showsVerticalScrollIndicator = false
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        
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
                var (l, e) = levelCount( (level.toInt()!)*7 )
                self.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
                self.levelButton.setTitle("等级 \(l)", forState: UIControlState.Normal)
                self.UserName.text = "\(name)"
                self.UserHead.setImage(imgURL, placeHolder: LessBlueColor)
                self.UserStep.text = "\(dream) 梦想，\(step) 进展"
                if coverURL == "" {
                    self.BGImage.image = UIImage(named: "bg")
                }else{
                    self.BGImage.setImage(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                }
            }
        }
        self.coinButton.addTarget(self, action: "coinClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headClick"))
    }
    
    func addDreamButton(){
        var adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController!.pushViewController(adddreamVC, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var height = scrollView.contentOffset.y
            self.scrollLayout(height)
            self.heightScroll = height
        }
        if scrollView == self.tableView {
            var height = scrollView.contentOffset.y
            self.currentCell = Int(floor(( height - 50 ) / 100 ) + 1)
            if height > 0 {
                labelTableChange(self.currentCell)
            }
        }
    }
    
    func scrollLayout(height:CGFloat){
        if height > 0 {
            self.BGImage.setY(height*0.6)
        }else{
            self.viewHolder.setY(height)
            self.BGImage.frame = CGRectMake(height/10, height, 320-height/5, 320)
            self.BGImage.layer.masksToBounds = true
        }
        scrollHidden(self.UserHead, height: height, scrollY: 70)
        scrollHidden(self.UserName, height: height, scrollY: 138)
        scrollHidden(self.UserStep, height: height, scrollY: 161)
        scrollHidden(self.coinButton, height: height, scrollY: 204)
        scrollHidden(self.levelButton, height: height, scrollY: 204)
        self.navHide(-44)
        if height > 320 {
            self.BGImage.hidden = true
        }else{
            self.BGImage.hidden = false
        }
    }
    
    func labelTableChange(number:Int){
        if self.dataArray.count > 0 && number < self.dataArray.count {
            var data: AnyObject = self.dataArray[number]
            var like = data.objectForKey("like") as String
            var step = data.objectForKey("step") as String
            var date = data.objectForKey("lastdate") as NSString
            var formatter = NSDateFormatter()
            formatter.dateFormat = "MM / dd"
            formatter.timeZone = NSTimeZone.systemTimeZone()
            var lastdate = (formatter.stringFromDate(NSDate(timeIntervalSince1970: date.doubleValue)))
            self.labelTableLeft.text = "\(like) 赞"
            self.labelTableMiddle.text = "\(step) 进展"
            self.labelTableRight.text = "\(lastdate)"
        }
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
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            Api.getUserTop(safeuid.toInt()!){ json in
                if json != nil {
                    var sa: AnyObject! = json!.objectForKey("user")
                    var coverURL: String! = sa.objectForKey("cover") as String
                    var imgURL = "http://img.nian.so/head/\(safeuid).jpg!dream" as NSString
                    var AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
                    self.UserHead.setImage(imgURL, placeHolder: LessBlueColor)
                    if coverURL == "" {
                        self.BGImage.image = UIImage(named: "bg")
                    }else{
                        self.BGImage.setImage(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navHide(20)
    }
    
    func navHide(yPoint:CGFloat){
        var navigationFrame = self.navigationController!.navigationBar.frame
        navigationFrame.origin.y = yPoint
        self.navigationController!.navigationBar.frame = navigationFrame
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
        var DreamVC = DreamViewController()
        DreamVC.Id = data.stringAttributeForKey("id")
        self.navigationController!.pushViewController(DreamVC, animated: true)
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
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr {
                self.dataArray.addObject(data)
            }
            self.tableView.reloadData()
            self.tableView.contentOffset.y = 100
            self.labelTableChange(0)
        })
    }
}