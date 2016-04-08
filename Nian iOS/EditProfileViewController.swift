//
//  EditProfileViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/31/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

@objc protocol EditProfileDelegate {
    optional func editProfile(profileDict profileDict: Dictionary<String, String>)
}


class EditProfileViewController: SAViewController, UIActionSheetDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIControl!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var phoneView: UIView!
    
    @IBOutlet weak var genderView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var scrollViewToBottomConstraint: NSLayoutConstraint!
    
    /// 根据界面上下顺序，每个 “分割线 View” 的高度
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp4HeightConstraint: NSLayoutConstraint!
    
    weak var delegate: EditProfileDelegate?
    var actionSheet: UIActionSheet!
    
    var profileDict: Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self._setTitle("编辑个人资料")
        self.settingSeperateHeight()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                        selector: #selector(EditProfileViewController.handleChooseGender(_:)),
                                                        name: "tapOnGenderTextField",
                                                        object: nil)
        if self.profileDict != nil {
            self.nameTextField.text = self.profileDict!["name"]
            
            if self.profileDict!["phone"] != "0" {
                self.phoneTextField.text = self.profileDict!["phone"]
            }
            
            self.genderTextField.text = self.profileDict!["gender"] == "0" ? "保密": self.profileDict!["gender"] == "1" ? "男" : "女"
            self.setBarButton("保存", actionGesture: #selector(EditProfileViewController.saveProfileSetting(_:)))
        }
        

    }

    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
        
    }

    /**
     
     */
    func handleChooseGender(noti: NSNotification) {
        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("男")
        actionSheet.addButtonWithTitle("女")
        actionSheet.addButtonWithTitle("保密")
        actionSheet.addButtonWithTitle("取消")
        actionSheet.cancelButtonIndex = 3
        actionSheet.showInView(self.view)
        
//        let alertController = PSTAlertController.actionSheetWithTitle(nil)
//        
//        alertController.addAction(PSTAlertAction(title: "男", style: .Default, handler: { (action) in
//            self.genderTextField.text = "男"
//        }))
//        
//        alertController.addAction(PSTAlertAction(title: "女", style: .Default, handler: { (action) in
//            self.genderTextField.text = "女"
//        }))
//        
//        alertController.addAction(PSTAlertAction(title: "保密", style: .Default, handler: { (action) in
//            self.genderTextField.text = "保密"
//        }))
//        
//        alertController.addCancelActionWithHandler(nil)
//        
//        alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.genderTextField.text = "男"
            } else if buttonIndex == 1 {
                self.genderTextField.text = "女"
            } else if buttonIndex == 2 {
                self.genderTextField.text = "保密"
            }
        }
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


extension EditProfileViewController {
    /**
     验证昵称是否符合要求
     */
    func validateNickname(name: String?) -> Bool {
        if let _text = name {
            if _text.characters.count >= 2 {
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
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
        
        var shouldReturn = true
        
        let previousName = self.profileDict!["name"]
        let _name = self.nameTextField.text!
        
        if _name != "" {
            if self.validateNickname(_name) {
                self.profileDict!["name"] = _name
            } else {
                shouldReturn = false
                self.showTipText("昵称里有奇怪的字符...")
            }
        } else {
            shouldReturn = false
            self.showTipText("昵称不能为空...")
        }
        
        let previousPhone = self.profileDict!["phone"]
        let _phone = self.phoneTextField.text!
        
        
        if _phone != "" {
            if self.validatePhone(_phone) {
                self.profileDict!["phone"] = _phone
            } else {
                shouldReturn = false
                self.showTipText("手机号码不正确...")
            }
        } else {
            self.profileDict!["phone"] = ""
        }
        
        let previousGender = self.profileDict!["gender"]
        var _gender = self.genderTextField.text!
        if _gender == "男" {
            _gender = "1"
        } else if _gender == "女" {
            _gender = "2"
        } else {
            _gender = "0"
        }
        
        self.profileDict!["gender"] = _gender
        
        if shouldReturn {
            
            var _tmpDict: Dictionary<String, String> = Dictionary()
            
            if previousName == _name && previousPhone == _phone && previousGender == _gender  {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                
                if previousName != _name {
                    _tmpDict["name"] = _name
                }
                
                if previousPhone != _phone {
                    _tmpDict["phone"] = _phone
                }
                
                if previousGender != _gender {
                    _tmpDict["gender"] = _gender
                }
                
                SettingModel.updateUserInfo(_tmpDict, callback: {
                    (task, responseObject, error) -> Void in
                    
                    if let _ = error {
                        self.showTipText("网络有点问题，等一会儿再试")
                    } else {
                        let json = JSON(responseObject!)
                        
                        if json["error"] != 0 {
                            self.showTipText("昵称或手机号不可用...")
                        } else {
                            self.delegate?.editProfile?(profileDict: self.profileDict!)
                        
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                })
            }
       
        }
    }

}


extension EditProfileViewController {
    
    func settingSeperateHeight() {
        self.sp1HeightConstraint.constant = globalHalf
        self.sp2HeightConstraint.constant = globalHalf
        self.sp3HeightConstraint.constant = globalHalf
        self.sp4HeightConstraint.constant = globalHalf
    }
}














