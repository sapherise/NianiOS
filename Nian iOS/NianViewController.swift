//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class MediaCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var thumbIcon: UIView!
    @IBOutlet var thumbImg: UILabel!
}

class NianViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cover:fakeView!
    @IBOutlet var coinButton:UIButton!
    @IBOutlet var levelButton:UIButton!
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var UserStep:UILabel!
    @IBOutlet var BGImage:UIImageView!
    @IBOutlet var BGImageCover:UIView!
    var lastPoint:CGPoint!
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
    }
    
    func setupViews(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset.bottom = 50
        self.extendedLayoutIncludesOpaqueBars = true
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        var url = NSURL(string:"http://nian.so/api/user.php?uid=\(safeuid)&myuid=\(safeuid)")
        var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var sa: AnyObject! = json.objectForKey("user")
        var name: AnyObject! = sa.objectForKey("name") as String
        var email: AnyObject! = sa.objectForKey("email") as String
        var coin: AnyObject! = sa.objectForKey("coin") as String
        var dream: AnyObject! = sa.objectForKey("dream") as String
        var step: AnyObject! = sa.objectForKey("step") as String
        var level: AnyObject! = sa.objectForKey("level") as String
        var coverURL: String! = sa.objectForKey("cover") as String
        var imgURL = "http://img.nian.so/head/\(safeuid).jpg!dream" as NSString
        var AllCoverURL = "http://img.nian.so/cover/\(coverURL)!cover"
        
        self.BGImage.setImage(AllCoverURL, placeHolder: UIColor.blackColor())
        
        self.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
        self.levelButton.setTitle("等级 \(level)", forState: UIControlState.Normal)
        
        self.UserName.text = "\(name)"
        self.UserHead.setImage(imgURL, placeHolder: LessBlueColor)
        
        self.UserStep.text = "\(dream)个梦想, \(step)个进展"
        self.coinButton.addTarget(self, action: "coinClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        self.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headClick"))
        
        if coverURL == "" {
            showBorder(true)
        }else{
            showBorder(false)
        }
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
            for data2 : AnyObject  in arr {
                self.dataArray.addObject(data2)
            }
            self.collectionView.reloadData()
            self.collectionView.headerEndRefreshing()
            })
    }
    func urlString()->String{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/nian.php?uid=\(safeuid)&shell=\(safeshell)"
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func stepClick(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var userVC = UserViewController()
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var title = data.stringAttributeForKey("title")
        var img = data.stringAttributeForKey("img")
        var dreamPrivate = data.stringAttributeForKey("private")
        var imgURL = "http://img.nian.so/dream/\(img)!step" as NSString
        var percent = data.stringAttributeForKey("percent")
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCell", forIndexPath: indexPath) as MediaCell
        mediaCell.label.text = "\(title)"
        mediaCell.imageView.setImage(imgURL, placeHolder: LessBlueColor)
        mediaCell.thumbImg.text = "\(dreamPrivate)"
        if dreamPrivate == "1" {
            mediaCell.thumbImg.text = "私密"
            mediaCell.thumbIcon.hidden = true
        }else{
            if percent == "1" {
                mediaCell.thumbImg.text = "完成"
                mediaCell.thumbIcon.hidden = true
            }else{
                mediaCell.thumbImg.text = "\(percent)"
                mediaCell.thumbIcon.hidden = true
            }
        }
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!){
        var DreamVC = DreamViewController()
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        DreamVC.Id = data.stringAttributeForKey("id")
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var height = scrollView.contentOffset.y
        self.scrollLayout(height)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if globalWillNianReload == 1 {
            self.SAReloadData()
            globalWillNianReload = 0
        }
        self.collectionView.contentOffset.y = 0
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navHide(20)
    }
    
    func navHide(yPoint:CGFloat){
        var navigationFrame = self.navigationController!.navigationBar.frame
        navigationFrame.origin.y = yPoint
        self.navigationController!.navigationBar.frame = navigationFrame
    }
    
    func scrollLayout(height:CGFloat){
        if height > 0 {
            self.cover.setY(-height)
            self.BGImage.setY(-height*0.6)
            self.BGImageCover.setY(320 - height)
        }else{
            self.cover.setY(0)
            self.BGImage.setY(0)
            self.BGImageCover.setY(320)
        }
        scrollHidden(self.UserHead, height: height, scrollY: 70)
        scrollHidden(self.UserName, height: height, scrollY: 138)
        scrollHidden(self.UserStep, height: height, scrollY: 161)
        scrollHidden(self.coinButton, height: height, scrollY: 204)
        scrollHidden(self.levelButton, height: height, scrollY: 204)
        if height > 44 {
            self.navHide(-44)
        }else{
            self.navHide(20)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header : UICollectionReusableView? = nil
        if (kind == UICollectionElementKindSectionHeader) {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "NianHeader", forIndexPath: indexPath)
                as? UICollectionReusableView
        }
        header?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "collectionHeadClick"))
        return header!
    }
    
    func headClick(){
        self.uploadWay = 1
        self.actionShow()
    }
    
    func collectionHeadClick(){
        self.uploadWay = 0
        self.actionShow()
    }
    
    func actionShow(){
        var actionTitle:String = ""
        if self.uploadWay == 0 {
            actionTitle = "希望从哪里\n换一张好看的封面？"
        }else{
            actionTitle = "希望从哪里\n换一张好看的头像？"
        }
        self.actionSheet = UIActionSheet(title: actionTitle, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker!.delegate = self
        self.imagePicker!.allowsEditing = true
        if buttonIndex == 0 {
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var uy = UpYun()
        if self.uploadWay == 1 {
            uy.successBlocker = ({(data:AnyObject!) in
                self.uploadUrl = data.objectForKey("url") as String
                self.uploadUrl = SAReplace(self.uploadUrl, "/headtmp/", "") as String
                var userImageURL = "http://img.nian.so/headtmp/\(self.uploadUrl)!dream"
                var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
                var cachePath: NSString = searchPath.objectAtIndex(0) as NSString
                var req = NSURLRequest(URL: NSURL(string: userImageURL)!)
                var queue = NSOperationQueue();
                NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                    dispatch_async(dispatch_get_main_queue(),{
                        var image:UIImage? = UIImage(data: data)
                        if image != nil{
                            var filePath = cachePath.stringByAppendingPathComponent("\(safeuid).jpg!dream")
                            FileUtility.imageCacheToPath(filePath,image:data)
                            self.UserHead.image = image
                        }
                    })
                })
            })
            uy.uploadImage(resizedImage(img, 250), savekey: getSaveKey("headtmp", "jpg"))
            
            var uy2 = UpYun()
            uy2.successBlocker = ({(data2:AnyObject!) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)", "http://nian.so/api/upyun_cache.php")
                    if sa != "" && sa != "err" {
                    }
                })
            })
            uy2.uploadImage(resizedImage(img, 250), savekey: self.getSaveKeyPrivate("head"))
        }else{
            uy.successBlocker = ({(data:AnyObject!) in
                self.uploadUrl = data.objectForKey("url") as String
                self.uploadUrl = SAReplace(self.uploadUrl, "/cover/", "") as String
                var userImageURL = "http://img.nian.so/cover/\(self.uploadUrl)!cover"
                var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
                var cachePath: NSString = searchPath.objectAtIndex(0) as NSString
                var req = NSURLRequest(URL: NSURL(string: userImageURL)!)
                var queue = NSOperationQueue();
                NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                    dispatch_async(dispatch_get_main_queue(),{
                        var image:UIImage? = UIImage(data: data)
                        if image != nil{
                            var filePath = cachePath.stringByAppendingPathComponent("\(self.uploadUrl).jpg!cover")
                            FileUtility.imageCacheToPath(filePath,image:data)
                            self.BGImage.image = image
                            self.showBorder(false)
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&cover=\(self.uploadUrl)", "http://nian.so/api/change_cover.php")
                            })
                        }
                    })
                })
            })
            uy.uploadImage(resizedImage(img, 320), savekey: getSaveKey("cover", "jpg"))
            
        }
    }
    
    func getSaveKeyPrivate(title:NSString) -> NSString{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var string = NSString(string: "/\(title)/\(safeuid).jpg")
        return string
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
    
    func showBorder(bool:Bool){
        if bool == true {
            self.coinButton.layer.borderColor = SeaColor.CGColor
            self.coinButton.layer.borderWidth = 1
            self.coinButton.setTitleColor(SeaColor, forState: UIControlState.Normal)
            self.levelButton.layer.borderColor = SeaColor.CGColor
            self.levelButton.layer.borderWidth = 1
            self.levelButton.setTitleColor(SeaColor, forState: UIControlState.Normal)
            self.UserName.textColor = SeaColor
        }else{
            self.coinButton.layer.borderColor = nil
            self.coinButton.layer.borderWidth = 0
            self.coinButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.levelButton.layer.borderColor = nil
            self.levelButton.layer.borderWidth = 0
            self.levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.UserName.textColor = UIColor.whiteColor()
        }
    }
}