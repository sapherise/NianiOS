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
    
    @objc optional func setting(name: String?, cover: UIImage?, avatar: UIImage?)
}

protocol LockDelegate {
    func setLockState(_ isOn: Bool)
}


class NewSettingViewController: SAViewController, UpdateUserDictDelegate, LockDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var ImageContainerView: UIView!
    /// 封面
    @IBOutlet weak var coverImageView: UIImageView!
    /// 头像
    @IBOutlet weak var avatarImageView: UIImageView!
    /// 模糊背景
    @IBOutlet weak var settingCoverBlurView: ILTranslucentView!
    /// 模糊背景
    @IBOutlet weak var settingAvatarBlurView: ILTranslucentView!
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
    /// 是否开启密码保护
    @IBOutlet weak var lockSwitch: UISwitch!
    /// 清理缓存时用的 indicator
    @IBOutlet weak var cacheActivityIndicator: UIActivityIndicatorView!
    /// version label
    @IBOutlet weak var versionLabel: UILabel!
    // 念
    @IBOutlet var logo: UIImageView!
    
    var actionSheet: UIActionSheet?
    var actionSheetHead: UIActionSheet?
//    var actionSheetBye: UIActionSheet!
    var actionSheetLogout: UIActionSheet?
    
    weak var delegate: NewSettingDelegate?
    
    /// 根据界面上下顺序，每个 “分割线 View” 的高度
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp4HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp5HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp6HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp7HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp8HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp9HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp10HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp11HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp12HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp13HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp14HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp15HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp16HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp17HeightConstraint: NSLayoutConstraint!
    
    /// 一些用户信息
    var userDict: Dictionary<String, AnyObject>?
    var settingModel: SettingModel?
    
    var coverImage: UIImage?
    var avatarImage: UIImage?
    
    var coverImageModified: Bool = false
    var avatarImageModified: Bool = false
    
    var coverImagePicker: UIImagePickerController?
    var avatarImagePicker: UIImagePickerController?
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("设置")
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1075)
        
        self.settingSeperateHeight()
        
        self.settingCoverBlurView.backgroundColor = UIColor.clear
        self.settingAvatarBlurView.backgroundColor = UIColor.clear
        self.settingAvatarBlurView.translucentTintColor = UIColor.clear
        self.settingCoverBlurView.translucentTintColor = UIColor.clear
        self.settingCoverBlurView.translucentStyle = .black
        self.settingAvatarBlurView.translucentStyle = .black
        
        /* 隐藏 “清理缓存” 的 spinner */
        self.cacheActivityIndicator.isHidden = true
        
        //设置背景
        self.coverImageView.image = self.coverImage
        //设置头像
        self.avatarImageView.image = self.avatarImage
        
        self.avatarImageView.layer.cornerRadius = 30.0
        self.avatarImageView.layer.masksToBounds = true
        
        self.ImageContainerView.layer.cornerRadius = 8.0
        self.ImageContainerView.layer.masksToBounds = true
        
        // 移动网络下是否下载图片
        if let saveMode = userDefaults.object(forKey: "saveMode") as? String {
            if saveMode == "on" {
                self.picOnCellarSwitch.setOn(true, animated: true)
            } else {
                self.picOnCellarSwitch.setOn(false, animated: true)
            }
        } else {  // userdefauts 里面没有保存用户的选择，默认是 false
            self.picOnCellarSwitch.setOn(false, animated: true)
        }
        
        // 是否只能通过昵称来找到
        if let privateMode = userDefaults.object(forKey: "privateMode") as? String {
            if privateMode == "1" {
                self.findViaNameSwitch.setOn(true, animated: true)
            } else {
                self.findViaNameSwitch.setOn(false, animated: true)
            }
        } else {
            self.findViaNameSwitch.setOn(false, animated: true)
        }
        
        // 是否保存进展卡片                    /* 这里是 modeCard */
        if let cardMode = userDefaults.object(forKey: "modeCard") as? String {
            if cardMode == "on" {
                self.saveCardSwitch.setOn(true, animated: true)
            } else {
                self.saveCardSwitch.setOn(false, animated: true)
            }
        } else {
            self.saveCardSwitch.setOn(true, animated: true)
        }
        
        // 是否每日更新提醒
        if let pushMode = userDefaults.object(forKey: "pushMode") as? String {
            if pushMode == "on" {
                self.dailyRemindSwitch.setOn(true, animated: true)
            } else {
                self.dailyRemindSwitch.setOn(false, animated: true)
                UIApplication.shared.cancelAllLocalNotifications()
            }
        } else {
            self.dailyRemindSwitch.setOn(false, animated: true)
        }
        
        // 是否开启了应用密码
        let lock = Cookies.get("Lock") as? String
        let lockState = lock == nil ? false : true
        setLockState(lockState)
        
        // 获得并显示版本号
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        self.versionLabel.text = "\(versionString)"
        
        beginLoading()
        
        dailyModeSwitch.isHidden = true
        Api.getUserInfoAndSetting() { json in
            self.endLoading()
            if json != nil {
                if SAValue(json, "error") != "0" {
                    self.showTipText("网络有些问题，只加载了本地设置")
                } else {
                    if let a = json?.object(forKey: "data") as? NSDictionary {
                        if let user = a.object(forKey: "user") as? Dictionary<String, AnyObject> {
                            self.userDict = user
                            let _user = user as NSDictionary
                            if _user.stringAttributeForKey("isMonthly") == "1" {
                                self.settingModel?.dailyMode = "0"
                                self.dailyModeSwitch.setOn(false, animated: false)
                            } else {
                                self.settingModel?.dailyMode = "1"
                                self.dailyModeSwitch.setOn(true, animated: false)
                            }
                            self.dailyModeSwitch.isHidden = false
                            let name = _user.stringAttributeForKey("name")
                            self.userDefaults.set(name, forKey: "user")
                            self.userDefaults.synchronize()
                        }
                    }
                }
            }
        }
        
        // 设定彩蛋
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(NewSettingViewController.onEgg(_:))))
    } // view didLoad
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Cookies.get("pushMode") as? String != "on" {
            self.dailyRemindSwitch.setOn(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let _name = self.userDict?["name"] as? String
        
        if self.coverImageModified && self.avatarImageModified {
            delegate?.setting?(name: _name, cover: self.coverImageView.image, avatar: self.avatarImageView.image)
        } else if self.coverImageModified {
            delegate?.setting?(name: _name, cover: self.coverImageView.image, avatar: nil)
        } else if self.avatarImageModified {
            delegate?.setting?(name: _name, cover: nil, avatar: self.avatarImageView.image)
        } else {
            delegate?.setting?(name: _name, cover: nil, avatar: nil)
        }
        
    }
    
    func onEgg(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            self.showTipText("你是永恒\n09.26.16", delayTime: 5)
        }
    }
    
    func beginLoading() {
        self.navigationItem.rightBarButtonItems = buttonArray()
    }
    
    func endLoading() {
        self.navigationItem.rightBarButtonItems = nil
    }
    
}

// MARK: - 处理各个 Switcher
extension NewSettingViewController{
    
    /**
     是否日更模式
     */
    @IBAction func dailyModeChanged(_ sender: UISwitch) {
        let _daily: String = sender.isOn ? "1" : "0"
        Api.updateUserInfo(["daily": "\(_daily)"]) { json in
            if json != nil {
                self.userDefaults.set(_daily, forKey: "dailyMode")
                self.userDefaults.synchronize()
            }
        }
    }
    
    /**
     移动网络是否下载图片
     */
    @IBAction func downloadPictureViaCellerOrNot(_ sender: UISwitch) {
        if sender.isOn {
            self.userDefaults.set("on", forKey: "saveMode")
            self.userDefaults.synchronize()
        } else {
            self.userDefaults.set("off", forKey: "saveMode")
            self.userDefaults.synchronize()
        }
    }
    
    /**
     是否保存进展卡片
     */
    @IBAction func saveStepCardOrNot(_ sender: UISwitch) {
        if sender.isOn {
            self.userDefaults.set("on", forKey: "modeCard")
            self.userDefaults.synchronize()
        } else {
            self.userDefaults.set("off", forKey: "modeCard")
            self.userDefaults.synchronize()
        }
        
    }
    
    /**
     是否每日更新提醒
     */
    @IBAction func remindOnDailyUpdate(_ sender: UISwitch) {
        if sender.isOn {
            delay(0.3, closure: {
                let CareVC = CareViewController()
                self.navigationController!.pushViewController(CareVC, animated: true)
            })
        } else {
            self.userDefaults.set("off", forKey: "pushMode")
            UIApplication.shared.cancelAllLocalNotifications()
        }
        
        self.userDefaults.synchronize()
    }
    
    /**
     是否只能通过昵称找到
     */
    @IBAction func findMeOnlyViaName(_ sender: UISwitch) {
        let _private = sender.isOn ? "1" : "0"
        Api.updateUserInfo(["private": "\(_private)"]) { json in
            if json != nil {
                self.userDefaults.set(_private, forKey: "privateMode")
                self.userDefaults.synchronize()
            }
        }
    }
    
    @IBAction func lockNian(_ sender: UISwitch) {
        if sender.isOn {
            let vc = Lock()
            vc.type = lockType.on
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            setLockState(false)
        } else {
            let vc = Lock()
            vc.type = lockType.off
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            setLockState(true)
        }
    }
    
    func setLockState(_ isOn: Bool) {
        lockSwitch.setOn(isOn, animated: true)
    }
}

// MARK: - 处理相关的 tap 手势
extension NewSettingViewController {
    @IBAction func setCover(_ sender: UITapGestureRecognizer) {
        actionSheet = UIActionSheet(title: "设定封面", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet!.addButton(withTitle: "相册")
        actionSheet!.addButton(withTitle: "拍照")
        actionSheet!.addButton(withTitle: "恢复默认封面")
        actionSheet!.addButton(withTitle: "取消")
        actionSheet!.cancelButtonIndex = 3
        actionSheet!.show(in: self.view)
    }
    
    @objc(actionSheet:clickedButtonAtIndex:) func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.coverImagePicker = UIImagePickerController()
                self.coverImagePicker!.delegate = self
                self.coverImagePicker!.allowsEditing = true
                self.coverImagePicker!.sourceType = .photoLibrary
                self.present(self.coverImagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                self.coverImagePicker = UIImagePickerController()
                self.coverImagePicker!.delegate = self
                self.coverImagePicker!.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    self.coverImagePicker!.sourceType = .camera
                    self.present(self.coverImagePicker!, animated: true, completion: nil)
                }
            } else if buttonIndex == 2 {
                Api.changeCoverImage("background.png") { json in
                    if json != nil {
                        self.coverImageView.image = UIImage(named: "bg")
                        self.coverImageModified = true
                    }
                }
            }
        } else if actionSheet == self.actionSheetHead {
            if buttonIndex == 0 {
                
                self.avatarImagePicker = UIImagePickerController()
                self.avatarImagePicker!.delegate = self
                self.avatarImagePicker!.allowsEditing = true
                self.avatarImagePicker!.sourceType = .photoLibrary
                
                self.present(self.avatarImagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                
                self.avatarImagePicker = UIImagePickerController()
                self.avatarImagePicker!.delegate = self
                self.avatarImagePicker!.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    self.avatarImagePicker!.sourceType = .camera
                    self.present(self.avatarImagePicker!, animated: true, completion: nil)
                }
            }
        } else if actionSheet == self.actionSheetLogout {
            if buttonIndex == 0 {
                SAlogout()
            }
        }
    }
    
    @IBAction func setAvatar(_ sender: UITapGestureRecognizer) {
        
        actionSheetHead = UIActionSheet(title: "设定头像", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheetHead!.addButton(withTitle: "相册")
        actionSheetHead!.addButton(withTitle: "拍照")
        actionSheetHead!.addButton(withTitle: "取消")
        actionSheetHead!.cancelButtonIndex = 2
        actionSheetHead!.show(in: self.view)
    }
    
    
    /**
     编辑个人资料(进入下一页)
     */
    @IBAction func editMyProfile(_ sender: UITapGestureRecognizer) {
        let editProfileVC = EditProfileViewController(nibName: "EditProfileView", bundle: nil)
        if self.userDict != nil {
            editProfileVC.profileDict = ["name": self.userDict?["name"] as! String,
                "phone": self.userDict?["phone"] as! String,
                "gender": self.userDict?["gender"] as! String]
        }
        
        
        editProfileVC.delegate = self
        
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    /**
     账号绑定和设置（进入下一页）
     */
    @IBAction func setAccountBind(_ sender: UITapGestureRecognizer) {
        let accountBindVC = AccountBindViewController(nibName: "AccountBindView", bundle: nil)
        accountBindVC.delegate = self
        if let _email = self.userDict!["email"] as? String {
            if _email != "0" {
                accountBindVC.userEmail = _email
            }
        }
        
        self.navigationController?.pushViewController(accountBindVC, animated: true)
    }
    
    /**
     修改邮箱后，调用该函数来修改 userDict
     */
    func updateUserDict(_ email: String) {
        self.userDict!["email"] = email as AnyObject?
    }
    
    /**
     清理缓存
     */
    @IBAction func cleanCache(_ sender: UITapGestureRecognizer) {
        self.cacheActivityIndicator.isHidden = false
        self.cacheActivityIndicator.startAnimating()
        go {
            let searchPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
            let cachePath: NSString = searchPath.object(at: 0) as! NSString
            let files = FileManager.default.subpaths(atPath: cachePath as String)
            for p in files! as NSArray {
                let path = cachePath.appendingPathComponent("\(p)")
                if FileManager.default.fileExists(atPath: path) {
                    if "\(p)" != "\(SAUid()).jpg!dream" {
                        do {
                            try FileManager.default.removeItem(atPath: path)
                        } catch _ {
                        }
                    }
                }
            }
            back {
                self.cacheActivityIndicator.stopAnimating()
                self.cacheActivityIndicator.isHidden = true
                self.showTipText("缓存清理好了")
            }
        }
    }
    
    /**
     念是什么
     */
    @IBAction func introduceNian(_ sender: UITapGestureRecognizer) {
        let helpViewController = HelpViewController()
        self.navigationController?.pushViewController(helpViewController, animated: true)
    }
    
    /**
     引导用户去 app store 给予好评
     */
    @IBAction func fiveStarOnAppStore(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/cn/app/id929448912")!)
    }
    
    /**
     登出
     */
    @IBAction func logout(_ sender: UITapGestureRecognizer) {
        
        actionSheetLogout = UIActionSheet(title: "欢迎下次再来玩", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheetLogout!.addButton(withTitle: "拜拜")
        actionSheetLogout!.addButton(withTitle: "取消")
        actionSheetLogout!.cancelButtonIndex = 1
        actionSheetLogout!.show(in: self.view)
    }
}


extension NewSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        
        if picker == self.coverImagePicker {
            self.uploadImage(image, type: "cover")
            
        } else if picker == self.avatarImagePicker {
            self.uploadImage(image, type: "avatar")
            
        }
    }
    
    func uploadImage(_ image: UIImage, type: String) {
        
        if type == "cover" {
            beginLoading()
            let uy = UpYun()
            uy.successBlocker = ({ d in
                if let data = d as? NSDictionary {
                    let a = data.stringAttributeForKey("url")
                    let b = SAReplace(a, before: "/cover/", after: "") as String
                    let coverImageURL = "http://img.nian.so/cover/\(b)!cover"
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(b, forKey: "coverUrl")
                    userDefaults.synchronize()
                    Api.changeCoverImage(b) { json in
                        self.endLoading()
                        setCacheImage(coverImageURL, img: image, width: 500 * globalScale)
                        // 上传成功后，本地显示新的封面
                        self.coverImageView.image = image
                        self.coverImageModified = true
                    }
                }
            })
            uy.failBlocker = ({ error in
                self.endLoading()
                self.showTipText("上传不成功...")
            })
            
            uy.uploadImage(resizedImage(image, newWidth: 500), savekey: getSaveKey("cover", png: "jpg") as String)
            
        } else if type == "avatar" {
            beginLoading()
            
            let uy = UpYun()
            uy.successBlocker = ({ data in
                self.endLoading()
                
                self.avatarImageView.image = image
                self.avatarImageModified = true
                
                setCacheImage("http://img.nian.so/head/\(CurrentUser.sharedCurrentUser.uid!).jpg!dream", img: image, width: 150)
            })
            uy.failBlocker = ({ error in
                self.endLoading()
                self.showTipText("上传失败了...再试试")
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
    func editProfile(profileDict: Dictionary<String, String>) {
        
        for (key, value) in profileDict {
            _ = self.userDict?.updateValue(value as AnyObject, forKey: key)
        }
    }
    
}

extension NewSettingViewController {

    func settingSeperateHeight() {
        self.sp1HeightConstraint.constant = globalHalf
        self.sp2HeightConstraint.constant = globalHalf
        self.sp3HeightConstraint.constant = globalHalf
        self.sp4HeightConstraint.constant = globalHalf
        self.sp5HeightConstraint.constant = globalHalf
        self.sp6HeightConstraint.constant = globalHalf
        self.sp7HeightConstraint.constant = globalHalf
        self.sp8HeightConstraint.constant = globalHalf
        self.sp9HeightConstraint.constant = globalHalf
        self.sp10HeightConstraint.constant = globalHalf
        self.sp11HeightConstraint.constant = globalHalf
        self.sp12HeightConstraint.constant = globalHalf
        self.sp13HeightConstraint.constant = globalHalf
        self.sp14HeightConstraint.constant = globalHalf
        self.sp15HeightConstraint.constant = globalHalf
        self.sp16HeightConstraint.constant = globalHalf
        self.sp17HeightConstraint.constant = globalHalf
    }

}


