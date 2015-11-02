//
//  NewSettingViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class NewSettingViewController: UIViewController {
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
   
    /// 一些用户信息
    var userDict: Dictionary<String, AnyObject>?
    var email: String?
    var name: String?
    var phone: String?
    var sex: String?
    var isMonthly: String?
    
    var coverImage: UIImage?
    var avatarImage: UIImage?
    
    var coverImagePicker: UIImagePickerController?
    var avatarImagePicker: UIImagePickerController?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.settingAvatarBlurView.dynamic = false
        self.settingAvatarBlurView.tintColor = UIColor.blackColor()
        
        self.settingCoverBlurView.dynamic = false
        self.settingCoverBlurView.tintColor = UIColor.blackColor()
        
        /* 隐藏 “清理缓存” 的 spinner */
        self.cacheActivityIndicator.hidden = true
        
        //设置头像
        self.avatarImageView.setHead(CurrentUser.sharedCurrentUser.uid!)
        
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
        
        SettingModel.getUserInfoAndSetting {
            (task, responseObject, error) -> Void in

            if let _error = error { // AFNetworking 返回的错误
                logError("\(_error.localizedDescription)")
            } else {
                let json = JSON(responseObject!)
                
                if json["error"] != 0 {   // 服务器返回的错误代码
                    
                } else {
                    self.userDict = json["data"]["user"].dictionaryObject
                    
                    if json["data"]["user"]["isMonthly"].stringValue == "1" {
                        self.dailyModeSwitch.setOn(false, animated: true)
                    } else {
                        self.dailyModeSwitch.setOn(true, animated: true)
                    }
                    
                    self.userDefaults.setObject(json["data"]["user"]["name"].stringValue, forKey: "user")
                    
                } // if json["error"] != 0
            } // if let _error = error
        }  // SettingModel.getUserInfoAndSetting
    } // view didLoad
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

}

// MARK: - 处理各个 Switcher
extension NewSettingViewController{
    
    /**
     <#Description#>
     */
    @IBAction func dailyModeChanged(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func downloadPictureViaCellerOrNot(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func saveStepCardOrNot(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func remindOnDailyUpdate(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func findMeOnlyViaName(sender: UISwitch) {
    }
}

// MARK: - 处理相关的 tap 手势
extension NewSettingViewController {
    
    /**
     
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
        editProfileVC.coverImageView.image = self.coverImageView.image
        editProfileVC.avatarImageView.image = self.avatarImageView.image
        
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    // 编辑个人资料有对应的 xib 文件
    // 账户绑定和设置没有对应的 xib 文件
    // 因此，初始化的方法不一样
    
    /**
     账号绑定和设置（进入下一页）
     */
    @IBAction func setAccountBind(sender: UITapGestureRecognizer) {
        
        
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
        
        self.dismissViewControllerAnimated(true, completion: {
            // TODO: 回到欢迎页
            
        
        })
        
    }
}


extension NewSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func coverImagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if picker == self.coverImagePicker {
            self.coverImageView.image = image
        } else if picker == self.avatarImagePicker {
            self.avatarImageView.image = image
        }
        
    }
    
    
    func coverImagePickerControllerDidCancel(picker: UIImagePickerController) {
        
    }
}


extension NewSettingViewController {



}
















