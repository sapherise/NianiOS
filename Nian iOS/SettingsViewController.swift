//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSCacheDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, SKStoreProductViewControllerDelegate {
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var head:UIImageView!
    @IBOutlet var logout:UIView!
    @IBOutlet var inputName:UITextField!
    @IBOutlet var inputEmail:UITextField!
    @IBOutlet var helpView:UIView?
    @IBOutlet var cacheView:UIView?
    @IBOutlet var cacheActivity:UIActivityIndicatorView!
    @IBOutlet var ImageSwitch:UISwitch!
    @IBOutlet var CareSwitch:UISwitch!
    @IBOutlet var version:UILabel!
    @IBOutlet var btnCover: UIButton!
    @IBOutlet var viewStar: UIView!
    var actionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    var uploadUrl:String = ""
    var uploadWidth:Int = 0
    var uploadHeight:Int = 0
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    
    var accountName:String = ""
    var accountEmail:String = ""
    
    override func viewDidLoad(){
        setupViews()
    }
    
    func setupViews(){
        
        self.viewBack()
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "设置"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 1100)
        self.cacheActivity.hidden = true
        self.cacheView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clearCache:"))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var safename = Sa.objectForKey("user") as String
        self.view.backgroundColor = BGColor
        var userImageURL = "http://img.nian.so/head/\(safeuid).jpg!dream"
        self.head!.setImage(userImageURL,placeHolder: IconColor)
        self.head!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHeadClick"))
        self.btnCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCoverClick"))
        
        self.inputName!.delegate = self
        self.inputEmail!.delegate = self
        
        self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAhelp"))
        self.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAlogout"))
        self.viewStar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onStarClick"))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        //节省流量模式
        self.ImageSwitch.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.ImageSwitch.layer.cornerRadius = 16
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
            if saveMode == "1" {
                self.switchSetup(true)
            }else{
                self.switchSetup(false)
            }
        
        //每日推送模式
        self.CareSwitch.addTarget(self, action: "pushSwitchAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.CareSwitch.layer.cornerRadius = 16
        var pushMode: String? = Sa.objectForKey("pushMode") as? String
        if pushMode == "1" {
            self.pushSwitchSetup(true)
        }else{
            self.pushSwitchSetup(false)
        }
        
        var longTap = UILongPressGestureRecognizer(target: self, action: "niceTry:")
        longTap.minimumPressDuration = 0.5
        self.version.addGestureRecognizer(longTap)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safename = Sa.objectForKey("user") as String
            var url = NSURL(string:"http://nian.so/api/user.php?uid=\(safeuid)&myuid=\(safeuid)")
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            if data != nil {
                var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                var data: AnyObject! = json.objectForKey("user")
                var email: AnyObject! = data.objectForKey("email") as String
                var name: String = data.objectForKey("name") as String
                Sa.setObject(name, forKey:"user")
                Sa.synchronize()
                dispatch_async(dispatch_get_main_queue(), {
                    self.inputName.text = name
                    self.inputEmail.text = "\(email)"
                    self.accountName = name
                    self.accountEmail = "\(email)"
                })
            }
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var y = self.scrollView.contentOffset.y
        if textField == self.inputName {
            if y < 150 {
                self.scrollView.setContentOffset(CGPointMake(0, 150), animated: true)
            }
        }else if textField == self.inputEmail {
            if y < 198 {
                self.scrollView.setContentOffset(CGPointMake(0, 198), animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if textField == self.inputName {
            if (textField.text != "") & (textField.text != self.accountName){
                self.navigationItem.rightBarButtonItems = buttonArray()
                if SAstrlen(self.inputName.text)>30 {
                    self.navigationItem.rightBarButtonItems = []
                    self.view.showTipText("昵称太长了...", delay: 1)
                    textField.text = self.accountName
                }else if SAstrlen(self.inputName.text)<4 {
                    self.navigationItem.rightBarButtonItems = []
                    self.view.showTipText("昵称太短了...", delay: 1)
                    textField.text = self.accountName
                }else if !self.inputName.text.isValidName() {
                    self.navigationItem.rightBarButtonItems = []
                    self.view.showTipText("名字里有奇怪的字符...", delay: 1)
                    textField.text = self.accountName
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var name = self.inputName.text
                        name = SAEncode(SAHtml(name))
                        var sa = SAPost("newname=\(name)&&uid=\(safeuid)&&shell=\(safeshell)&&type=2", "http://nian.so/api/user_update.php")
                        if sa != "" && sa != "err" {
                            if sa == "NO" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.navigationItem.rightBarButtonItems = []
                                    self.view.showTipText("有人取这个名字了...", delay: 1)
                                    textField.text = self.accountName
                                })
                            }else if sa == "1" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.navigationItem.rightBarButtonItems = []
                                    self.accountName = self.inputName.text
                                    self.view.showTipText("昵称改好啦", delay: 1)
                                    globalWillNianReload = 1
                                })
                            }
                        }
                    })
                }
            }else{
                textField.text = self.accountName
            }
        }else if textField == self.inputEmail {
            if (textField.text != "") & (textField.text != self.accountEmail){
                self.navigationItem.rightBarButtonItems = buttonArray()
                if SAstrlen(self.inputEmail.text)>50 {
                    self.navigationItem.rightBarButtonItems = []
                    self.view.showTipText("邮箱太长了", delay: 1)
                    textField.text = self.accountEmail
                }else if !self.inputEmail.text.isValidEmail() {
                    self.navigationItem.rightBarButtonItems = []
                    self.view.showTipText("不是地球上的邮箱", delay: 1)
                    textField.text = self.accountEmail
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var email = self.inputEmail.text
                        email = SAEncode(SAHtml(email))
                        var sa = SAPost("newemail=\(email)&&uid=\(safeuid)&&shell=\(safeshell)&&type=3", "http://nian.so/api/user_update.php")
                        if sa != "" && sa != "err" {
                            if sa == "NO" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.navigationItem.rightBarButtonItems = []
                                    self.view.showTipText("有人用这个邮箱了...", delay: 1)
                                    textField.text = self.accountEmail
                                })
                            }else if sa == "1" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.navigationItem.rightBarButtonItems = []
                                    self.accountEmail = self.inputEmail.text
                                    self.view.showTipText("邮箱改好啦", delay: 1)
                                })
                            }
                        }
                    })
                }
            }else{
                textField.text = self.accountEmail
            }
        }
    }
    
    func onHeadClick(){
        self.uploadWay = 1
        self.actionShow()
    }
    
    func onCoverClick(){
        self.uploadWay = 0
        self.actionShow()
    }
    
    func actionShow(){
        var actionTitle:String = ""
        if self.uploadWay == 0 {
            actionTitle = "设定封面"
        }else{
            actionTitle = "设定头像"
        }
        self.actionSheet = UIActionSheet(title: actionTitle, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.imagePicker = UIImagePickerController()
            self.imagePicker!.delegate = self
            self.imagePicker!.allowsEditing = true
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            self.imagePicker = UIImagePickerController()
            self.imagePicker!.delegate = self
            self.imagePicker!.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.btnCover.startLoading()
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
                            globalWillNianReload = 1
                            var filePath = cachePath.stringByAppendingPathComponent("\(safeuid).jpg!dream")
                            FileUtility.imageCacheToPath(filePath,image:data)
                            self.head.image = image
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
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                Sa.setObject(userImageURL, forKey: "coverUrl")
                Sa.synchronize()
                var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
                var cachePath: NSString = searchPath.objectAtIndex(0) as NSString
                var req = NSURLRequest(URL: NSURL(string: userImageURL)!)
                var queue = NSOperationQueue();
                NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                    dispatch_async(dispatch_get_main_queue(),{
                        var image:UIImage? = UIImage(data: data)
                        if image != nil{
                            globalWillNianReload = 1
                            self.btnCover.endLoading("设定封面")
                            var filePath = cachePath.stringByAppendingPathComponent("\(self.uploadUrl).jpg!cover")
                            FileUtility.imageCacheToPath(filePath,image:data)
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&cover=\(self.uploadUrl)", "http://nian.so/api/change_cover.php")
                            })
                        }
                    })
                })
            })
            uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("cover", "jpg"))
            
        }
    }
    
    func getSaveKeyPrivate(title:NSString) -> NSString{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var string = NSString(string: "/\(title)/\(safeuid).jpg")
        return string
    }
    
    
    func switchAction(sender:UISwitch){
        if sender.on {
            self.switchSetup(true)
        }else{
            self.switchSetup(false)
        }
    }
    func pushSwitchAction(sender:UISwitch){
        if sender.on {
            self.pushSwitchSetup(true)
            delay(0.3, {
                var CareVC = CareViewController()
                self.navigationController!.pushViewController(CareVC, animated: true)
            })
        }else{
            self.pushSwitchSetup(false)
        }
    }
    
    func pushSwitchSetup(bool:Bool){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if bool {
            self.CareSwitch.thumbTintColor = UIColor.whiteColor()
            self.CareSwitch.onTintColor = SeaColor
            self.CareSwitch.tintColor = SeaColor
            self.CareSwitch.setOn(true, animated: true)
        }else{
            self.CareSwitch.thumbTintColor = BGColor
            self.CareSwitch.backgroundColor = IconColor
            self.CareSwitch.tintColor = IconColor
            self.CareSwitch.setOn(false, animated: true)
            Sa.setObject("0", forKey:"pushMode")
            Sa.synchronize()
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    func switchSetup(bool:Bool){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if bool {
            self.ImageSwitch.thumbTintColor = UIColor.whiteColor()
            self.ImageSwitch.onTintColor = SeaColor
            self.ImageSwitch.tintColor = SeaColor
            self.ImageSwitch.setOn(true, animated: true)
            Sa.setObject("1", forKey:"saveMode")
            Sa.synchronize()
        }else{
            self.ImageSwitch.thumbTintColor = BGColor
            self.ImageSwitch.backgroundColor = IconColor
            self.ImageSwitch.tintColor = IconColor
            self.ImageSwitch.setOn(false, animated: true)
            Sa.setObject("0", forKey:"saveMode")
            Sa.synchronize()
        }
    }
    
    func clearCache(sender:UIGestureRecognizer){
        self.cacheActivity.hidden = false
        self.cacheActivity.startAnimating()
        clearingCache()
    }
    
    func clearingCache(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
            var cachePath: NSString = searchPath.objectAtIndex(0) as NSString
            var files = NSFileManager.defaultManager().subpathsAtPath(cachePath)
            var p:NSString = ""
            for p in files! as NSArray {
                var path = cachePath.stringByAppendingPathComponent("\(p)")
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    var safeuid = Sa.objectForKey("uid") as String
                    if p as NSString != "\(safeuid).jpg!dream" {
                        NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                    }
                }
            }
            dispatch_sync(dispatch_get_main_queue(), {
                self.cacheActivity.hidden = true
                self.cacheActivity.stopAnimating()
                self.view.showTipText("缓存清理好了！", delay: 1)
            })
        })
    }
    
    func niceTry(sender:UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began {
            var arr = ["you can't beat death", "but you can beat death in life, sometimes.", "and the more often you learn to do it,", "the more light there will be.", "your life is your life.", "know it while you have it.", "you are marvelous", "the gods wait to delight", "in you."]
            var t: Double = 0
            var count = arr.count - 1
            for i in 0...count {
                delay(t, {
                    self.view.showTipText(arr[i], delay: 2)
                })
                t = t + 2.3
            }
        }
    }
    
    func SAhelp(){
        var helpVC = HelpViewController()
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        inputName.resignFirstResponder()
        inputEmail.resignFirstResponder()
    }
    
    func onStarClick(){
        var storeProductVC = SKStoreProductViewController()
        storeProductVC.delegate = self
        var dict = NSDictionary(object: "929448912", forKey: SKStoreProductParameterITunesItemIdentifier)
        self.navigationController?.presentViewController(storeProductVC, animated: true, completion: nil)
        storeProductVC.loadProductWithParameters(dict, completionBlock: nil)
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: {
            if let v = self.navigationController {
                v.view.showTipText("蟹蟹你！<3", delay: 2)
            }
        })
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var pushMode: String? = Sa.objectForKey("pushMode") as? String
        if pushMode != "1" {
                self.pushSwitchSetup(false)
        }
    }
}