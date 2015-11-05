//
//  NewSettingViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit
import QuartzCore

@objc protocol NewSettingDelegate {
    
    optional func setting(name name: String?, cover: UIImage?, avatar: UIImage?)
}


class NewSettingViewController: SAViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var ImageContainerView: UIView!
    /// 封面
    @IBOutlet weak var coverImageView: UIImageView!
    /// 头像
    @IBOutlet weak var avatarImageView: UIImageView!
    /// 模糊背景
    @IBOutlet weak var settingCoverBlurView: FXBlurView!
    /// 模糊背景
    @IBOutlet weak var settingAvatarBlurView: FXBlurView!
    /// 是否日更模式
    @IBOutlet weak var dailyModeSwitch: UISwitch!
    /// 是否移动网络下载图片
    @IBOutlet weak var picOnCellarSwitch: UISwitch!
    /// 是否保存进展卡片
    @IBOutlet weak var saveCardSwitch: UISwitch!
    /// 是否每日提醒更新
    @IBOutlet weak var dailyRemindSwitch: UISwitch!
    /// 是否只能通过昵称找到我
    @IBOutlet weak var findViaNameSwitch: UISwitch!
    /// 清理缓存时用的 indicator
    @IBOutlet weak var cacheActivityIndicator: UIActivityIndicatorView!
    /// version label
    @IBOutlet weak var versionLabel: UILabel!
    
    weak var delegate: NewSettingDelegate?
    
    /// 一些用户信息
    var userDict: Dictionary<String, AnyObject>?
    var settingModel: SettingModel?
    
    var coverImage: UIImage?
    var avatarImage: UIImage?
    
    var coverImageModified: Bool = false
    var avatarImageModified: Bool = false
    
    var coverImagePicker: UIImagePickerController?
    var avatarImagePicker: UIImagePickerController?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("设置")
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.width, 1075)
        
        self.settingAvatarBlurView.dynamic = true
        self.settingAvatarBlurView.tintColor = UIColor.blackColor()
        
        self.settingCoverBlurView.dynamic = true
        self.settingCoverBlurView.tintColor = UIColor.blackColor()
        
        self.settingModel = SettingModel()
        
        /* 隐藏 “清理缓存” 的 spinner */
        self.cacheActivityIndicator.hidden = true
        
        //设置背景
        self.coverImageView.image = self.coverImage
        //设置头像
        self.avatarImageView.image = self.avatarImage
        
        self.avatarImageView.layer.cornerRadius = 30.0
        self.avatarImageView.layer.masksToBounds = true
        
        self.ImageContainerView.layer.cornerRadius = 8.0
        self.ImageContainerView.layer.masksToBounds = true
        
        // 移动网络下是否下载图片
        if let saveMode = userDefaults.objectForKey("saveMode") as? String {
            if saveMode == "1" {
                self.picOnCellarSwitch.setOn(true, animated: true)
            } else {
                self.picOnCellarSwitch.setOn(false, animated: true)
            }
        } else {  // userdefauts 里面没有保存用户的选择，默认是 false
            self.picOnCellarSwitch.setOn(false, animated: true)
        }
        
        // 是否只能通过昵称来找到
        if let privateMode = userDefaults.objectForKey("privateMode") as? String {
            if privateMode == "1" {
                self.findViaNameSwitch.setOn(true, animated: true)
            } else {
                self.findViaNameSwitch.setOn(false, animated: true)
            }
        } else {
            self.findViaNameSwitch.setOn(false, animated: true)
        }
        
        // 是否保存进展卡片                    /* 这里是 modeCard */
        if let cardMode = userDefaults.objectForKey("modeCard") as? String {
            if cardMode == "0" {
                self.saveCardSwitch.setOn(false, animated: true)
            } else {
                self.saveCardSwitch.setOn(true, animated: true)
            }
        } else {
            self.saveCardSwitch.setOn(true, animated: true)
        }
        
        // 是否每日更新提醒
        if let pushMode = userDefaults.objectForKey("pushMode") as? String {
            if pushMode == "1" {
                self.dailyRemindSwitch.setOn(true, animated: true)
            } else {
                self.dailyRemindSwitch.setOn(false, animated: true)
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
        } else {
            self.dailyRemindSwitch.setOn(false, animated: true)
        }
        
        // 获得并显示版本号
        let versionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        self.versionLabel.text = "\(versionString)"
        
        self.startAnimating()
        
        SettingModel.getUserInfoAndSetting {
            (task, responseObject, error) in
            
            self.stopAnimating()
            
            if let _error = error { // AFNetworking 返回的错误
                logError("\(_error.localizedDescription)")
            } else {
                let json = JSON(responseObject!)
                
                if json["error"] != 0 {   // 服务器返回的错误代码
                    
                } else {
                    self.userDict = json["data"]["user"].dictionaryObject
                    
                    if json["data"]["user"]["isMonthly"].stringValue == "1" {
                        self.settingModel?.dailyMode = "0"
                        self.dailyModeSwitch.setOn(false, animated: true)
                    } else {
                        self.settingModel?.dailyMode = "1"
                        self.dailyModeSwitch.setOn(true, animated: true)
                    }
                    
                    self.userDefaults.setObject(json["data"]["user"]["name"].stringValue, forKey: "user")
                    self.userDefaults.synchronize()
                } // if json["error"] != 0
            } // if let _error = error
        }  // SettingModel.getUserInfoAndSetting
    } // view didLoad
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let _name = self.userDict!["name"] as? String
        
        if self.coverImageModified && self.avatarImageModified {
            delegate?.setting?(name: _name, cover: self.coverImageView.image, avatar: self.avatarImageView.image)
        } else if self.coverImageModified {
            delegate?.setting?(name: _name, cover: self.coverImageView.image, avatar: nil)
        } else if self.avatarImageModified {
            delegate?.setting?(name: _name, cover: nil, avatar: self.avatarImageView.image)
        }
        
    }
    
    
    
}

// MARK: - 处理各个 Switcher
extension NewSettingViewController{
    
    /**
     是否日更模式
     */
    @IBAction func dailyModeChanged(sender: UISwitch) {
        if sender.on {
            Api.postUserFrequency(0, callback: { _ in
                self.userDefaults.setObject("0", forKey: "dailyMode")
                self.userDefaults.synchronize()
            })
            
        } else {
            Api.postUserFrequency(1, callback: { _ in
                self.userDefaults.setObject("1", forKey: "dailyMode")
                self.userDefaults.synchronize()
            })
        }
    }
    
    /**
     移动网络是否下载图片
     */
    @IBAction func downloadPictureViaCellerOrNot(sender: UISwitch) {
        if sender.on {
            self.userDefaults.setObject(true, forKey: "saveMode")
            self.userDefaults.synchronize()
        } else {
            self.userDefaults.setObject(false, forKey: "saveMode")
            self.userDefaults.synchronize()
        }
    }
    
    /**
     是否保存进展卡片
     */
    @IBAction func saveStepCardOrNot(sender: UISwitch) {
        if sender.on {
            self.userDefaults.setObject(true, forKey: "modeCard")
            self.userDefaults.synchronize()
        } else {
            self.userDefaults.setObject(false, forKey: "modeCard")
            self.userDefaults.synchronize()
        }
        
    }
    
    /**
     是否每日更新提醒
     */
    @IBAction func remindOnDailyUpdate(sender: UISwitch) {
        if sender.on {
            self.userDefaults.setObject("1", forKey: "pushMode")
        } else {
            self.userDefaults.setObject("0", forKey: "pushMode")
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        self.userDefaults.synchronize()
    }
    
    /**
     是否只能通过昵称找到
     */
    @IBAction func findMeOnlyViaName(sender: UISwitch) {
        if sender.on {
            Api.postUserPrivate("1", callback: { _ in
                self.userDefaults.setObject(true, forKey: "privateMode")
                self.userDefaults.synchronize()
            })
        } else {
            Api.postUserPrivate("0", callback: { _ in
                self.userDefaults.setObject(false, forKey: "privateMode")
                self.userDefaults.synchronize()
            })
        }
    }
}

// MARK: - 处理相关的 tap 手势
extension NewSettingViewController {
    
    /**
    设置封面图片， --- @warning: 应该叫做 setCoverImage 的，但是和之前不知道哪里有冲突
     */
    @IBAction func setCover(sender: UITapGestureRecognizer) {
        let alertController = PSTAlertController.actionSheetWithTitle("设定封面")
        
        alertController.addAction(PSTAlertAction(title: "相册", style: .Destructive, handler: { (action) in
            self.coverImagePicker = UIImagePickerController()
            self.coverImagePicker!.delegate = self
            self.coverImagePicker!.allowsEditing = true
            self.coverImagePicker!.sourceType = .PhotoLibrary
            
            self.presentViewController(self.coverImagePicker!, animated: true, completion: nil)
        }))
        
        alertController.addAction(PSTAlertAction(title: "拍照", style: .Destructive, handler: { (action) in
            self.coverImagePicker = UIImagePickerController()
            self.coverImagePicker!.delegate = self
            self.coverImagePicker!.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                self.coverImagePicker!.sourceType = .Camera
                self.presentViewController(self.coverImagePicker!, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(PSTAlertAction(title: "恢复默认封面", style: .Destructive, handler: { (action) in
            
        }))
        
        alertController.addCancelActionWithHandler(nil)
        
        alertController.showWithSender(sender, arrowDirection: .Any, controller: self, animated: true, completion: nil)
        
    }
    
    /*=========================================================================================================================================*/
    /*
        为什么使用了第三方的 PSTAlertController， 因为 UIAlertView 在 iOS 9 上会被键盘挡住， UIAlertController 不支持 iOS 7；
    @brief 这是一个过渡方案
    */
    /*=========================================================================================================================================*/
    
    
    
    @IBAction func setAvatar(sender: UITapGestureRecognizer) {
        let alertController = PSTAlertController.actionSheetWithTitle("设定头像")
        
        alertController.addAction(PSTAlertAction(title: "相册", style: .Destructive, handler: { (action) in
            self.coverImagePicker = UIImagePickerController()
            self.coverImagePicker!.delegate = self
            self.coverImagePicker!.allowsEditing = true
            self.coverImagePicker!.sourceType = .PhotoLibrary
            
            self.presentViewController(self.coverImagePicker!, animated: true, completion: nil)
        }))
        
        alertController.addAction(PSTAlertAction(title: "拍照", style: .Destructive, handler: { (action) in
            self.coverImagePicker = UIImagePickerController()
            self.coverImagePicker!.delegate = self
            self.coverImagePicker!.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                self.coverImagePicker!.sourceType = .Camera
                self.presentViewController(self.coverImagePicker!, animated: true, completion: nil)
            }
        }))

        alertController.addCancelActionWithHandler(nil)
        
        alertController.showWithSender(sender, arrowDirection: .Any, controller: self, animated: true, completion: nil)

    }
    
    
    /**
     编辑个人资料(进入下一页)
     */
    @IBAction func editMyProfile(sender: UITapGestureRecognizer) {
        let editProfileVC = EditProfileViewController(nibName: "EditProfileView", bundle: nil)
        editProfileVC.coverImage = self.coverImageView.image
        editProfileVC.avatarImage = self.avatarImageView.image
        editProfileVC.profileDict = ["name": self.userDict?["name"] as! String,
                                     "phone": self.userDict?["phone"] as! String,
                                     "gender": self.userDict?["gender"] as! String]
        
        
        editProfileVC.delegate = self
        
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    /**
     账号绑定和设置（进入下一页）
     */
    @IBAction func setAccountBind(sender: UITapGestureRecognizer) {
        let accountBindVC = AccountBindViewController(nibName: "AccountBindView", bundle: nil)
        
        accountBindVC.userName = self.userDefaults.objectForKey("user") as! String
        
        if let _email = self.userDict!["email"] as? String {
            if _email != "0" {
                accountBindVC.userEmail = _email
            }
        }
        
        self.navigationController?.pushViewController(accountBindVC, animated: true)
    }
    
    /**
     清理缓存
     */
    @IBAction func cleanCache(sender: UITapGestureRecognizer) {
        self.cacheActivityIndicator.hidden = false
        self.cacheActivityIndicator.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let searchPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            let cachePath = searchPath[0] as String
            
            if let files = NSFileManager.defaultManager().subpathsAtPath(cachePath) {
                for p in files {
                    let path = cachePath + "\(p)"
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        if "\(p)" != "\(SAUid()).jpg!dream" {
                            do {
                                try NSFileManager.defaultManager().removeItemAtPath(path)
                            } catch _ {}
                        }
                    }
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.cacheActivityIndicator.stopAnimating()
                self.cacheActivityIndicator.hidden = true
                self.view.showTipText("缓存清理好了", delay: 1)
            })
        
        })
        
        
    }
    
    @IBAction func introduceNian(sender: UITapGestureRecognizer) {
        let helpViewController = HelpViewController()
        self.navigationController?.pushViewController(helpViewController, animated: true)
    }
    
    /**
     引导用户去 app store 给予好评
     */
    @IBAction func fiveStarOnAppStore(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/cn/app/id929448912")!)
    }
    
    
    @IBAction func logout(sender: UITapGestureRecognizer) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        uidKey.resetKeychainItem()
        
        Api.postDeviceTokenClear() {
            string in
            
            userDefaults.removeObjectForKey("uid")
            userDefaults.removeObjectForKey("shell")
            userDefaults.removeObjectForKey("followData")
            userDefaults.removeObjectForKey("user")
            
            userDefaults.synchronize()
        }
        
        globalTabhasLoaded = [false, false, false]
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}


extension NewSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if picker == self.coverImagePicker {
            self.uploadImage(image, type: "cover")
            
        } else if picker == self.avatarImagePicker {
            self.uploadImage(image, type: "avatar")
            
        }
    }
    
    func uploadImage(image: UIImage, type: String) {
        
        if type == "cover" {
            
            self.startAnimating()
            
            let uy = UpYun()
            uy.successBlocker = ({ (data: AnyObject!) in
                var uploadURL = data.objectForKey("url") as! String
                uploadURL = SAReplace(uploadURL, before: "/cover/", after: "") as String
                
                let coverImageURL = "http://img.nian.so/cover/\(uploadURL)!cover"
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(coverImageURL, forKey: "coverUrl")
                userDefaults.synchronize()
                
                SettingModel.changeCoverImage(coverURL: coverImageURL, callback: {
                    (task, responseObject, error) in
                    
                    self.stopAnimating()
                    
                    if let _ = error {
                        self.view.showTipText("上传不成功...", delay: 2)
                    } else {
                        setCacheImage(coverImageURL, img: image, width: 500)
                        // 上传成功后，本地显示新的封面
                        self.coverImageView.image = image
                        self.coverImageModified = true
                    }
                })
            })
            
            
            uy.failBlocker = ({ (error: NSError!) in
                self.stopAnimating()
                self.view.showTipText("上传不成功...", delay: 2)
            })
            
            uy.uploadImage(resizedImage(image, newWidth: 500), savekey: getSaveKey("cover", png: "jpg") as String)
            
        } else if type == "avatar" {
            
            self.startAnimating()
            
            let uy = UpYun()
            uy.successBlocker = ({ (data: AnyObject!) in
                self.stopAnimating()
                
                self.avatarImageView.image = image
                self.avatarImageModified = true
                
                setCacheImage("http://img.nian.so/head/\(CurrentUser.sharedCurrentUser.uid!).jpg!dream",
                    img: image, width: 150)
            })
            uy.failBlocker = ({ (error: NSError!) in
                self.stopAnimating()
                self.view.showTipText("上传不成功...", delay: 2)
            })
            
            let _tmpString = "/head/" + "\(CurrentUser.sharedCurrentUser.uid!)" + ".jpg"
            
            uy.uploadImage(resizedImage(image, newWidth: 250), savekey: _tmpString)
        }
    }

}

extension NewSettingViewController: EditProfileDelegate {
    /**
     更新界面和用户信息
     */
    func editProfile(profileDict profileDict: Dictionary<String, String>, coverImage: UIImage, avatarImage: UIImage) {
        self.coverImageView.image = coverImage
        self.coverImageModified = true
        
        self.avatarImageView.image = avatarImage
        self.avatarImageModified = true
        
        for (key, value) in profileDict {
            self.userDict?.updateValue(value, forKey: key)
        }
    }
    
}








