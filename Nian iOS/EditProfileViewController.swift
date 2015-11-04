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
    /// 封面
    @IBOutlet weak var coverImageView: UIImageView!
    /// 头像
    @IBOutlet weak var avatarImageView: UIImageView!
    /// 模糊背景
    @IBOutlet weak var settingCoverBlurView: FXBlurView!
    /// 模糊背景
    @IBOutlet weak var settingAvatarBlurView: FXBlurView!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: EditProfileDelegate?
    
    var coverImage: UIImage?
    var avatarImage: UIImage?
    
    var coverImagePicker: UIImagePickerController?
    var avatarImagePicker: UIImagePickerController?
    
    var profileDict: Dictionary<String, String>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self._setTitle("修改个人资料")
        self.coverImageView.image = self.coverImage
        self.avatarImageView.image = self.avatarImage
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                        selector: "handleChooseGender:",
                                                        name: "tapOnGenderTextField",
                                                        object: nil)
        
        
        self.nameTextField.text = self.profileDict!["name"]
        
        if self.profileDict!["phone"] != "0" {
            self.phoneTextField.text = self.profileDict!["phone"]
        }
        
        self.genderTextField.text = self.profileDict!["gender"] == "2" ? "保密": self.profileDict!["gender"] == "0" ? "男" : "女"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.view.frame.height - 64 < 472 {
            self.containerViewHeightConstraint.constant = 472
            self.view.setNeedsUpdateConstraints()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.editProfile?(profileDict: self.profileDict!, coverImage: self.coverImageView.image!, avatarImage: self.avatarImageView.image!)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        if self.view.frame.height - 64 < 472 {
            self.containerViewHeightConstraint.constant = 472
            self.view.setNeedsUpdateConstraints()
        }
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
        containerViewHeightConstraint.constant += originDelta
        
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        
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



