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

class SettingsViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSCacheDelegate {
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
    @IBOutlet var version:UILabel!
    var actionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    var uploadUrl:String = ""
    var uploadWidth:Int = 0
    var uploadHeight:Int = 0
    
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
            var req = NSURLRequest(URL: NSURL.URLWithString(userImageURL))
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
        var string = NSString.stringWithString("/\(title)/\(safeuid).jpg")
        return string
    }
    
    
    func setupViews(){
        self.scrollView.contentSize = CGSizeMake(320, 900)
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
        
        self.storeView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "storeClick:"))
        
        
        self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAhelp"))
        self.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAlogout"))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        self.ImageSwitch.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.ImageSwitch.layer.cornerRadius = 16
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
            if saveMode == "1" {
                self.switchSetup(true)
            }else{
                self.switchSetup(false)
            }
        var longTap = UILongPressGestureRecognizer(target: self, action: "niceTry")
        longTap.minimumPressDuration = 0.5
        self.version.addGestureRecognizer(longTap)
        
        dispatch_async(dispatch_get_main_queue(), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safename = Sa.objectForKey("user") as String
            var url = NSURL(string:"http://nian.so/api/user.php?uid=\(safeuid)&myuid=\(safeuid)")
            var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var sa: AnyObject! = json.objectForKey("user")
            var email: AnyObject! = sa.objectForKey("email") as String
            var coin: AnyObject! = sa.objectForKey("coin") as String
            self.inputName.text = safename
            self.inputEmail.text = "\(email)"
            self.coinNumber!.text = "\(coin)"
        })
    }
    
    func switchAction(sender:UISwitch){
        if sender.on {
            self.switchSetup(true)
        }else{
            self.switchSetup(false)
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
        println("彩蛋1")
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
    
}