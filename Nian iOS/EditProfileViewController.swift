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


class EditProfileViewController: UIViewController {

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
    
    
    weak var delegate: EditProfileDelegate?
    
    var coverImage: UIImage?
    var avatarImage: UIImage?
    
    var coverImagePicker: UIImagePickerController?
    var avatarImagePicker: UIImagePickerController?
    
    var profileDict: Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewBack()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "修改个人资料"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        
        self.coverImageView.image = self.coverImage
        self.avatarImageView.image = self.avatarImage
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleChooseGender:", name: "tapOnGenderTextField", object: nil)
        
        
        self.nameTextField.text = self.profileDict!["name"]
        
        if self.profileDict!["phone"] != "0" {
            self.phoneTextField.text = self.profileDict!["phone"]
        }
        
        self.genderTextField.text = self.profileDict!["gender"] == "2" ? "保密": self.profileDict!["gender"] == "0" ? "男" : "女"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.editProfile?(profileDict: self.profileDict!, coverImage: self.coverImageView.image!, avatarImage: self.avatarImageView.image!)
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



