//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

protocol NiceDelegate {      //😍       我拥有一个代理公司
    func niceShow(text:String)
}

class SettingsViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSCacheDelegate, UITextFieldDelegate {
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var head:UIImageView!
    @IBOutlet var logout:UIView!
    var niceDeletgate: NiceDelegate?
    @IBOutlet var inputName:UITextField!
    @IBOutlet var inputEmail:UITextField!
    @IBOutlet var coinNumber:UILabel?
    @IBOutlet var helpView:UIView?
    @IBOutlet var storeView:UIView?
    @IBOutlet var cacheView:UIView?
    @IBOutlet var cacheActivity:UIActivityIndicatorView!
    @IBOutlet var ImageSwitch:UISwitch!
    @IBOutlet var CareSwitch:UISwitch!
    @IBOutlet var version:UILabel!
    var actionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    var uploadUrl:String = ""
    var uploadWidth:Int = 0
    var uploadHeight:Int = 0
    
    var accountName:String = ""
    var accountEmail:String = ""
    
    override func viewDidLoad(){
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
    }
    
    func uploadClick(sender: AnyObject) {
        self.inputName!.resignFirstResponder()
        self.inputEmail!.resignFirstResponder()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
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
            self.imagePicker!.allowsEditing = false
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            self.imagePicker = UIImagePickerController()
            self.imagePicker!.delegate = self
            self.imagePicker!.allowsEditing = false
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
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            self.uploadUrl = data.objectForKey("url") as String
            self.uploadUrl = SAReplace(self.uploadUrl, "/headtmp/", "") as String
            var userImageURL = "http://img.nian.so/headtmp/\(self.uploadUrl)!head"
            var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
            var cachePath: NSString = searchPath.objectAtIndex(0) as NSString
            var req = NSURLRequest(URL: NSURL(string: userImageURL)!)
            var queue = NSOperationQueue();
            NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                dispatch_async(dispatch_get_main_queue(),{
                    var image:UIImage? = UIImage(data: data)
                    if image != nil{
                        var filePath = cachePath.stringByAppendingPathComponent("\(safeuid).jpg!head")
                        FileUtility.imageCacheToPath(filePath,image:data)
                        self.head!.image = image
                    }
                })
            })
        })
        uy.failBlocker = ({(error:NSError!) in
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
    }
    
    func getSaveKeyPrivate(title:NSString) -> NSString{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var string = NSString(string: "/\(title)/\(safeuid).jpg")
        return string
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = NavColor
        self.view.addSubview(navView)
        
        self.scrollView.frame = CGRectMake(0, 64, globalWidth, globalHeight - 49 - 64)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 820)
        self.cacheActivity.hidden = true
        self.cacheView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clearCache:"))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var safename = Sa.objectForKey("user") as String
        self.view.backgroundColor = BGColor
        var userImageURL = "http://img.nian.so/head/\(safeuid).jpg!head"
        self.head!.setImage(userImageURL,placeHolder: IconColor)
        self.head!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "uploadClick:"))
        
        self.inputName!.delegate = self
        self.inputEmail!.delegate = self
        
        self.storeView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "storeClick:"))
        
        self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAhelp"))
        self.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAlogout"))
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
        
        var longTap = UILongPressGestureRecognizer(target: self, action: "niceTry")
        longTap.minimumPressDuration = 0.5
        self.version.addGestureRecognizer(longTap)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safename = Sa.objectForKey("user") as String
            var url = NSURL(string:"http://nian.so/api/user.php?uid=\(safeuid)&myuid=\(safeuid)")
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var sa: AnyObject! = json.objectForKey("user")
            var email: AnyObject! = sa.objectForKey("email") as String
            var coin: AnyObject! = sa.objectForKey("coin") as String
            dispatch_async(dispatch_get_main_queue(), {
                self.inputName.text = safename
                self.inputEmail.text = "\(email)"
                self.coinNumber!.text = "\(coin)"
                self.accountName = safename
                self.accountEmail = "\(email)"
            })
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if textField == self.inputName {
            if (textField.text != "") & (textField.text != self.accountName){
                self.navigationItem.rightBarButtonItems = buttonArray()
                if SAstrlen(self.inputName.text)>30 {
                    self.niceDeletgate?.niceShow("昵称太长了...")
                    textField.text = self.accountName
                }else if !self.inputName.text.isValidName() {
                    self.niceDeletgate?.niceShow("名字里有奇怪的字符...")
                    textField.text = self.accountName
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var name = self.inputName.text
                        name = SAEncode(SAHtml(name))
                        var sa = SAPost("newname=\(name)&&uid=\(safeuid)&&shell=\(safeshell)&&type=2", "http://nian.so/api/user_update.php")
                        if sa != "" && sa != "err" {
                            if sa == "NO" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.niceDeletgate?.niceShow("有人取这个名字了...")
                                    textField.text = self.accountName
                                })
                            }else if sa == "1" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.navigationItem.rightBarButtonItems = []
                                    self.accountName = self.inputName.text
                                    self.niceDeletgate?.niceShow("昵称改好啦")
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
                    self.niceDeletgate?.niceShow("邮箱太长了")
                    textField.text = self.accountEmail
                }else if !self.inputEmail.text.isValidEmail() {
                    self.niceDeletgate?.niceShow("不是地球上的邮箱")
                    textField.text = self.accountEmail
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var email = self.inputEmail.text
                        email = SAEncode(SAHtml(email))
                        var sa = SAPost("newemail=\(email)&&uid=\(safeuid)&&shell=\(safeshell)&&type=3", "http://nian.so/api/user_update.php")
                        if sa != "" && sa != "err" {
                            if sa == "NO" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.niceDeletgate?.niceShow("有人用这个邮箱了...")
                                    textField.text = self.accountEmail
                                })
                            }else if sa == "1" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.navigationItem.rightBarButtonItems = []
                                    self.accountEmail = self.inputEmail.text
                                    self.niceDeletgate?.niceShow("邮箱改好啦")
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
            self.CareSwitch.onTintColor = BlueColor
            self.CareSwitch.tintColor = BlueColor
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
            self.ImageSwitch.onTintColor = BlueColor
            self.ImageSwitch.tintColor = BlueColor
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
                    if p as NSString != "\(safeuid).jpg!head" {
                        NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                    }
                }
            }
            dispatch_sync(dispatch_get_main_queue(), {
                self.cacheActivity.hidden = true
                self.cacheActivity.stopAnimating()
                self.niceDeletgate?.niceShow("缓存清理好了！")
            })
        })
    }
    
    func niceTry(){
        self.niceDeletgate?.niceShow("念 爱 你")
    }
    
    func SAhelp(){
        var helpVC = HelpViewController()
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    func storeClick(sender:UIGestureRecognizer){
        var storeVC = StoreViewController(nibName: "Store", bundle: nil)
        self.navigationController!.pushViewController(storeVC, animated: true)
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        inputName.resignFirstResponder()
        inputEmail.resignFirstResponder()
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
    
    func back(sender:UISwipeGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
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