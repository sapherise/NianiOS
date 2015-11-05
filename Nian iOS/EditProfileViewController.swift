//
//  EditProfileViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/31/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

@objc protocol EditProfileDelegate {
    
    optional func editProfile(profileDict profileDict: Dictionary<String, String>, coverImage: UIImage, avatarImage: UIImage)
    
}


class EditProfileViewController: SAViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIControl!
    
    @IBOutlet weak var imageContainerView: UIView!
    /// 封面
    @IBOutlet weak var coverImageView: UIImageView!
    /// 头像
    @IBOutlet weak var avatarImageView: UIImageView!
    /// 模糊背景
    @IBOutlet weak var settingCoverBlurView: FXBlurView!
    /// 模糊背景
    @IBOutlet weak var settingAvatarBlurView: FXBlurView!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var phoneView: UIView!
    
    @IBOutlet weak var genderView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var scrollViewToBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: EditProfileDelegate?
    
    var coverImage: UIImage?
    var avatarImage: UIImage?
    
    var coverImageModified: Bool = false
    var avatarImageModified: Bool = false
    
    var coverImagePicker: UIImagePickerController?
    var avatarImagePicker: UIImagePickerController?
    
    var profileDict: Dictionary<String, String>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self._setTitle("修改个人资料")
        self.coverImageView.image = self.coverImage
        self.avatarImageView.image = self.avatarImage
        
        self.settingAvatarBlurView.dynamic = true
        self.settingAvatarBlurView.tintColor = UIColor.blackColor()
        
        self.settingCoverBlurView.dynamic = true
        self.settingCoverBlurView.tintColor = UIColor.blackColor()
        
        self.imageContainerView.layer.cornerRadius = 8.0
        self.imageContainerView.layer.masksToBounds = true
        
        self.avatarImageView.layer.cornerRadius = 30.0
        self.avatarImageView.layer.masksToBounds = true
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                        selector: "handleChooseGender:",
                                                        name: "tapOnGenderTextField",
                                                        object: nil)
        
        self.nameTextField.text = self.profileDict!["name"]
        
        if self.profileDict!["phone"] != "0" {
            self.phoneTextField.text = self.profileDict!["phone"]
        }
        
        self.genderTextField.text = self.profileDict!["gender"] == "2" ? "保密": self.profileDict!["gender"] == "0" ? "男" : "女"
        
        self.setBarButton("保存", actionGesture: "saveProfileSetting:")

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
    }

    
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
     
     */
    func handleChooseGender(noti: NSNotification) {
        let alertController = PSTAlertController.actionSheetWithTitle(nil)
        
        alertController.addAction(PSTAlertAction(title: "男", style: .Destructive, handler: { (action) in
            self.genderTextField.text = "男"
            self.profileDict!["gender"] = "0"
        }))
        
        alertController.addAction(PSTAlertAction(title: "女", style: .Destructive, handler: { (action) in
            self.genderTextField.text = "女"
            self.profileDict!["gender"] = "1"
        }))
        
        alertController.addAction(PSTAlertAction(title: "保密", style: .Destructive, handler: { (action) in
            self.genderTextField.text = "保密"
            self.profileDict!["gender"] = "2"
        }))
        
        alertController.addCancelActionWithHandler(nil)
        
        alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
    }
    
    
    func handleKeyboardNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        // Get information about the animation.
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        // The text view should be adjusted, update the constant for this constraint.
        scrollViewToBottomConstraint.constant -= originDelta
        
        // Inform the view that its autolayout constraints have changed and the layout should be updated.
        view.setNeedsUpdateConstraints()
        
        // Animate updating the view's layout by calling layoutIfNeeded inside a UIView animation block.
        let animationOptions: UIViewAnimationOptions = [animationCurve, .BeginFromCurrentState]
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        // Scroll to the selected text once the keyboard frame changes.

    }
    
}



extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == self.genderTextField {
            
            NSNotificationCenter.defaultCenter().postNotificationName("tapOnGenderTextField", object: nil)
            
            return false
        }
        
        return true
    }
    
    /**
     
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        switch textField {
        case self.nameTextField:
            self.profileDict!["name"] = textField.text!
            
        case self.phoneTextField:
            self.profileDict!["phone"] = textField.text!
            
        default:
            break
        }
        
        return true
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if picker == self.coverImagePicker {
            self.coverImageView.image = image
            self.coverImageModified = true
        } else if picker == self.avatarImagePicker {
            self.avatarImageView.image = image
            self.avatarImageModified = true
        }
    }
}


extension EditProfileViewController {
    /**
     验证昵称是否符合要求
     */
    func validateNickname(name: String?) -> Bool {
        if let _text = name {
            if _text.characters.count >= 4 {
                if _text.isValidName() {
                    return true
                }
            }
        }

        return false
    }
    
    /**
     验证手机号是否正确
     */
    func validatePhone(phoneNumber: String?) -> Bool {
        
        if let _text = phoneNumber {
            if _text != "" {
                if _text.isValidPhone() {
                    return true
                }
            }
        }
        
        return false
    }

}

extension EditProfileViewController {
    
    func saveProfileSetting(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        if self.coverImageModified  {
            self.uploadImage(self.coverImageView.image!, type: "cover")
        }
        
        if self.avatarImageModified {
            self.uploadImage(self.avatarImageView.image!, type: "avatar")
        }
        
        if !self.validateNickname(self.nameTextField.text) {
            self.view.showTipText("名字不符合要求...", delay: 1)
            return
        }
        
        if !self.validatePhone(self.phoneTextField.text) {
            self.view.showTipText("手机号码不正确...", delay: 1)
            return
        }
        
        self.profileDict!["name"] = self.nameTextField.text!
        self.profileDict!["phone"] = self.phoneTextField.text!
        
        delegate?.editProfile?(profileDict: self.profileDict!, coverImage: self.coverImageView.image!, avatarImage: self.avatarImageView.image!)
        
        self.navigationController?.popViewControllerAnimated(true)
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

















