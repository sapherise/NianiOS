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
    @IBOutlet var viewLogout:UIView!
    @IBOutlet var inputName:UITextField!
    @IBOutlet var inputEmail:UITextField!
    @IBOutlet var inputPhone: UITextField!
    @IBOutlet var viewHelp:UIView!
    @IBOutlet var viewCache:UIView!
    @IBOutlet var cacheActivity:UIActivityIndicatorView!
    @IBOutlet var ImageSwitch:UISwitch!
    @IBOutlet var CareSwitch:UISwitch!
    @IBOutlet var PrivateSwitch: UISwitch!
    @IBOutlet var switchMode: UISwitch!
    @IBOutlet var switchCard: UISwitch!
    @IBOutlet var version:UILabel!
    @IBOutlet var btnCover: UIButton!
    @IBOutlet var viewStar: UIView!
    @IBOutlet var viewFind: UIView!
    @IBOutlet var viewSex: UIView!
    @IBOutlet var labelSex: UILabel!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var viewName: UIView!
    @IBOutlet var viewEmail: UIView!
    @IBOutlet var viewPhone: UIView!
    @IBOutlet var viewImage: UIView!
    @IBOutlet var viewAlert: UIView!
    @IBOutlet var viewMode: UIView!
    @IBOutlet var viewCard: UIView!
    @IBOutlet var line1: UIView!
    @IBOutlet var line2: UIView!
    @IBOutlet var line3: UIView!
    @IBOutlet var line4: UIView!
    @IBOutlet var line5: UIView!
    @IBOutlet var line6: UIView!
    @IBOutlet var line7: UIView!
    @IBOutlet var line8: UIView!
    @IBOutlet var line9: UIView!
    @IBOutlet var line10: UIView!
    @IBOutlet var line11: UIView!
    @IBOutlet var line12: UIView!
    @IBOutlet var line13: UIView!
    @IBOutlet var line14: UIView!
    @IBOutlet var line15: UIView!
    @IBOutlet var line16: UIView!
    @IBOutlet var line17: UIView!
    @IBOutlet var arrowHelp: UIImageView!
    @IBOutlet var arrowStar: UIImageView!
    @IBOutlet var infoMode: UIImageView!
    var actionSheet:UIActionSheet?
    var actionSheetSex: UIActionSheet?
    var imagePicker:UIImagePickerController?
    var uploadUrl:String = ""
    var uploadWidth:Int = 0
    var uploadHeight:Int = 0
    // uploadWay，当上传封面时为 0，上传头像时为 1
    var uploadWay:Int = 0
    
    var accountName:String = ""
    var accountEmail:String = ""
    var accountPhone: String = ""
    
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
        
        self.viewHolder.setWidth(globalWidth)
        self.head.setX(globalWidth/2-30)
        self.btnCover.setX(globalWidth/2-50)
        self.viewName.setWidth(globalWidth)
        self.viewEmail.setWidth(globalWidth)
        self.viewPhone.setWidth(globalWidth)
        self.viewSex.setWidth(globalWidth)
        self.viewCache.setWidth(globalWidth)
        self.viewImage.setWidth(globalWidth)
        self.viewAlert.setWidth(globalWidth)
        self.viewFind.setWidth(globalWidth)
        self.viewHelp.setWidth(globalWidth)
        self.viewStar.setWidth(globalWidth)
        self.viewLogout.setWidth(globalWidth)
        self.viewMode.setWidth(globalWidth)
        self.viewCard.setWidth(globalWidth)
        self.line1.setGlobalWidth()
        self.line2.setGlobalWidth()
        self.line3.setGlobalWidth()
        self.line4.setGlobalWidth()
        self.line5.setGlobalWidth()
        self.line6.setGlobalWidth()
        self.line7.setGlobalWidth()
        self.line8.setGlobalWidth()
        self.line9.setGlobalWidth()
        self.line10.setGlobalWidth()
        self.line11.setGlobalWidth()
        self.line12.setGlobalWidth()
        self.line13.setGlobalWidth()
        self.line14.setGlobalWidth()
        self.line15.setGlobalWidth()
        self.line16.setGlobalWidth()
        self.line17.setGlobalWidth()
        self.inputName.setGlobalX()
        self.inputEmail.setGlobalX()
        self.inputPhone.setGlobalX()
        self.labelSex.setGlobalX()
        self.cacheActivity.setGlobalX()
        self.ImageSwitch.setGlobalX(x: 13)
        self.CareSwitch.setGlobalX(x: 13)
        self.PrivateSwitch.setGlobalX(x: 13)
        self.switchMode.setGlobalX(x: 13)
        self.switchCard.setGlobalX(x: 13)
        self.arrowHelp.setGlobalX(x: 13)
        self.arrowStar.setGlobalX(x: 13)
        
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 1300)
        self.cacheActivity.hidden = true
        self.viewCache.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clearCache:"))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        var safename = Sa.objectForKey("user") as! String
        self.view.backgroundColor = BGColor
        self.head!.setHead(safeuid)
        self.head!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHeadClick"))
        self.btnCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCoverClick"))
        self.btnCover.backgroundColor = SeaColor
        
        self.inputName!.delegate = self
        self.inputEmail!.delegate = self
        self.inputPhone!.delegate = self
        
        self.viewHelp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAhelp"))
        self.viewLogout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAlogout"))
        self.viewStar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onStarClick"))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        //节省流量模式
        self.ImageSwitch.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.ImageSwitch.layer.cornerRadius = 16
        var saveMode: String? = Sa.objectForKey("saveMode") as? String
            if saveMode == "1" {
                self.ImageSwitch.switchSetup(true, cacheName: "saveMode")
            }else{
                self.ImageSwitch.switchSetup(false, cacheName: "saveMode")
            }
        
        // 私密模式
        self.PrivateSwitch.addTarget(self, action: "privateSwitchAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.PrivateSwitch.layer.cornerRadius = 16
        var privateMode: String? = Sa.objectForKey("privateMode") as? String
        if privateMode == "1" {
            self.PrivateSwitch.switchSetup(true, cacheName: "privateMode")
        }else{
            self.PrivateSwitch.switchSetup(false, cacheName: "privateMode")
        }
        
        
        // 卡片模式
        self.switchCard.addTarget(self, action: "onCard:", forControlEvents: UIControlEvents.ValueChanged)
        self.switchCard.layer.cornerRadius = 16
        var modeCard = SACookie("modeCard")
        if modeCard == "0" {
            self.switchCard.switchSetup(false, cacheName: "modeCard")
        }else{
            self.switchCard.switchSetup(true, cacheName: "modeCard")
        }
        
        self.switchMode.addTarget(self, action: "switchModeAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.switchMode.layer.cornerRadius = 16
        
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
        self.version.setX(globalWidth/2-36)
        
        infoMode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onInfoModeClick:"))
        
        // 发现好友
        self.viewFind.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFindClick"))
        self.viewSex.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSexClick"))
        
        //labelVersion.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
        var numberVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        self.version.text = "念 \(numberVersion)"
        
        Api.getUserMe() { json in
            if json != nil {
                var data = json!.objectForKey("user") as! NSDictionary
                var email = data.stringAttributeForKey("email")
                var name = data.stringAttributeForKey("name")
                var phone = data.stringAttributeForKey("phone")
                var sex = data.stringAttributeForKey("sex")
                var isMonthly = data.stringAttributeForKey("isMonthly")
                if isMonthly == "1" {
                    self.switchMode.switchSetup(false, cacheName: "", isCache: false)
                }else{
                    self.switchMode.switchSetup(true, cacheName: "", isCache: false)
                }
                Sa.setObject(name, forKey:"user")
                Sa.synchronize()
                dispatch_async(dispatch_get_main_queue(), {
                    self.inputName.text = name
                    self.inputEmail.text = email
                    self.inputPhone.text = phone
                    self.accountName = name
                    self.accountEmail = email
                    self.accountPhone = phone
                    if sex == "1" {
                        self.labelSex.text = "男"
                    }else if sex == "2" {
                        self.labelSex.text = "女"
                    }else{
                        self.labelSex.text = "保密"
                    }
                })
            }
        }
    }
    
    func onInfoModeClick(sender: UIGestureRecognizer) {
        self.showFilm("日更模式", prompt: "打开日更模式，每天奖励更多念币\n关闭日更模式，将不再被停号", button: "好", transDirectly: false) { (FilmCell) -> Void in
            self.onFilmClose()
        }
    }
    
    func onFindClick(){
        var findVC = FindViewController()
        self.navigationController?.pushViewController(findVC, animated: true)
    }
    
    func onSexClick() {
        self.actionSheetSex = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetSex!.addButtonWithTitle("男")
        self.actionSheetSex!.addButtonWithTitle("女")
        self.actionSheetSex!.addButtonWithTitle("保密")
        self.actionSheetSex!.addButtonWithTitle("取消")
        self.actionSheetSex!.cancelButtonIndex = 3
        self.actionSheetSex!.showInView(self.view)
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
        }else if textField == self.inputPhone {
            if y < 246 {
                self.scrollView.setContentOffset(CGPointMake(0, 246), animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        if textField == self.inputName {
            if (textField.text != "") && (textField.text != self.accountName){
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
            if (textField.text != "") && (textField.text != self.accountEmail){
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
        }else if textField == self.inputPhone {
            if (textField.text != "") && (textField.text != self.accountPhone){
                self.navigationItem.rightBarButtonItems = buttonArray()
                if !self.inputPhone.text.isValidPhone() {   //正则
                    self.navigationItem.rightBarButtonItems = []
                    self.view.showTipText("不是大陆的手机号...", delay: 1)
                    textField.text = self.accountPhone
                }else{
                    // 上传手机号
                    var phone = self.inputPhone.text
                    phone = SAEncode(SAHtml(phone))
                    Api.postUserPhone(phone) { json in
                        self.navigationItem.rightBarButtonItems = []
                        self.accountPhone = self.inputPhone.text
                        self.view.showTipText("手机改好啦", delay: 1)
                    }
                }
            }else{
                textField.text = self.accountPhone
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
        if self.uploadWay == 0 {
            self.actionSheet!.addButtonWithTitle("恢复默认封面")
            self.actionSheet!.addButtonWithTitle("取消")
            self.actionSheet!.cancelButtonIndex = 3
        }else{
            self.actionSheet!.addButtonWithTitle("取消")
            self.actionSheet!.cancelButtonIndex = 2
        }
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
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
            }else if buttonIndex == 2 && self.uploadWay == 0 {
                self.btnCover.startLoading()
                Api.postUserCover() { json in
                    if json != nil {
                        globalWillNianReload = 1
                        self.btnCover.endLoading("设定封面")
                    }
                }
            }
        }else if actionSheet == self.actionSheetSex {
            if buttonIndex == 0 {
                self.labelSex.text = "男"
                Api.postUserSex(1) { json in
                }
            }else if buttonIndex == 1 {
                self.labelSex.text = "女"
                Api.postUserSex(2) { json in
                }
            }else if buttonIndex == 2 {
                self.labelSex.text = "保密"
                Api.postUserSex(0) { json in
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        var uy = UpYun()
        if self.uploadWay == 1 {
            self.navigationItem.rightBarButtonItems = buttonArray()
            var uy = UpYun()
            uy.successBlocker = ({(data2:AnyObject!) in
                globalWillNianReload = 1
                
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                self.navigationItem.rightBarButtonItems = []
                self.head.image = img
                
                setCacheImage("http://img.nian.so/head/\(safeuid).jpg!dream", img, 150)
            })
            uy.uploadImage(resizedImage(img, 250), savekey: self.getSaveKeyPrivate("head") as String)
        } else {
            self.btnCover.startLoading()
            uy.successBlocker = ({(data:AnyObject!) in
                self.uploadUrl = data.objectForKey("url") as! String
                self.uploadUrl = SAReplace(self.uploadUrl, "/cover/", "") as String
                var userImageURL = "http://img.nian.so/cover/\(self.uploadUrl)!cover"
                
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                Sa.setObject(userImageURL, forKey: "coverUrl")
                Sa.synchronize()
                
                var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
                var cachePath: NSString = searchPath.objectAtIndex(0) as! NSString
                var req = NSURLRequest(URL: NSURL(string: userImageURL)!)
                var queue = NSOperationQueue();
                
                NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                    dispatch_async(dispatch_get_main_queue(),{
                        var image:UIImage? = UIImage(data: data)
                        if image != nil{
                            globalWillNianReload = 1
                            self.btnCover.endLoading("设定封面")
                            setCacheImage(userImageURL, img, 500)
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&cover=\(self.uploadUrl)", "http://nian.so/api/change_cover.php")
                            })
                        }
                    })
                })
            })
            
            uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("cover", "jpg") as String)
            
        }
    }
    
    func getSaveKeyPrivate(title:NSString) -> NSString{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var string = NSString(string: "/\(title)/\(safeuid).jpg")
        return string
    }
    
    
    func switchAction(sender:UISwitch){
        if sender.on {
            sender.switchSetup(true, cacheName: "saveMode")
        }else{
            sender.switchSetup(false, cacheName: "saveMode")
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
    
    func privateSwitchAction(sender: UISwitch) {
        if sender.on {
            sender.switchSetup(true, cacheName: "privateMode")
            Api.postUserPrivate("1") { json in
            }
        }else{
            sender.switchSetup(false, cacheName: "privateMode")
            Api.postUserPrivate("0") { json in
            }
        }
    }
    
    func onCard(sender: UISwitch) {
        if sender.on {
            sender.switchSetup(true, cacheName: "modeCard")
        } else {
            sender.switchSetup(false, cacheName: "modeCard")
        }
    }
    
    func switchModeAction(sender: UISwitch) {
        if sender.on {
            sender.switchSetup(true, cacheName: "", isCache: false)
            Api.postUserFrequency(0) { json in
            }
        }else{
            sender.switchSetup(false, cacheName: "", isCache: false)
            Api.postUserFrequency(1) { json in
            }
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
    
//    func switchSetup(bool:Bool){
//        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        if bool {
//            self.ImageSwitch.thumbTintColor = UIColor.whiteColor()
//            self.ImageSwitch.onTintColor = SeaColor
//            self.ImageSwitch.tintColor = SeaColor
//            self.ImageSwitch.setOn(true, animated: true)
//            Sa.setObject("1", forKey:"saveMode")
//            Sa.synchronize()
//        }else{
//            self.ImageSwitch.thumbTintColor = BGColor
//            self.ImageSwitch.backgroundColor = IconColor
//            self.ImageSwitch.tintColor = IconColor
//            self.ImageSwitch.setOn(false, animated: true)
//            Sa.setObject("0", forKey:"saveMode")
//            Sa.synchronize()
//        }
//    }
    
    func clearCache(sender:UIGestureRecognizer){
        self.cacheActivity.hidden = false
        self.cacheActivity.startAnimating()
        clearingCache()
    }
    
    func clearingCache(){
        go {
            var searchPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
            var cachePath: NSString = searchPath.objectAtIndex(0) as! NSString
            var files = NSFileManager.defaultManager().subpathsAtPath(cachePath as String)
            var p = ""
            for p in files! as NSArray {
                var path = cachePath.stringByAppendingPathComponent("\(p)")
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    if "\(p)" != "\(SAUid()).jpg!dream" {
                        NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                    }
                }
            }
            back {
                self.cacheActivity.hidden = true
                self.cacheActivity.stopAnimating()
                self.view.showTipText("缓存清理好了！", delay: 1)
            }
        }
    }
    
    func niceTry(sender:UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began {
            self.view.showTipText("-  念 爱 你  -", delay: 2)
        }
    }
    
    func SAhelp(){
        var helpVC = HelpViewController()
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        inputName.resignFirstResponder()
        inputEmail.resignFirstResponder()
        inputPhone.resignFirstResponder()
    }
    
    func onStarClick(){
        var storeProductVC = SKStoreProductViewController()
        storeProductVC.delegate = self
        var dict = NSDictionary(object: "929448912", forKey: SKStoreProductParameterITunesItemIdentifier)
        self.navigationController?.presentViewController(storeProductVC, animated: true, completion: nil)
        storeProductVC.loadProductWithParameters(dict as [NSObject : AnyObject], completionBlock: nil)
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: {
            if let v = self.navigationController {
                v.view.showTipText("蟹蟹你！<3", delay: 2)
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var pushMode: String? = Sa.objectForKey("pushMode") as? String
        if pushMode != "1" {
            self.pushSwitchSetup(false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        globalViewFilmExist = false
    }
}

extension UISwitch {
    func switchSetup(bool: Bool, cacheName: String, isCache: Bool = true){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if bool {
            self.thumbTintColor = UIColor.whiteColor()
            self.onTintColor = SeaColor
            self.tintColor = SeaColor
            self.setOn(true, animated: true)
            if isCache {
                Sa.setObject("1", forKey: cacheName)
                Sa.synchronize()
            }
        }else{
            self.thumbTintColor = BGColor
            self.backgroundColor = IconColor
            self.tintColor = IconColor
            self.setOn(false, animated: true)
            if isCache {
                Sa.setObject("0", forKey: cacheName)
                Sa.synchronize()
            }
        }
    }
}

extension UIView {
    func setGlobalWidth() {
        self.setWidth(globalWidth)
    }
    
    func setGlobalX(x:CGFloat = 20) {
        self.setX(globalWidth - x - self.width())
    }
}