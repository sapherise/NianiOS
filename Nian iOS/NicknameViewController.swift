//
//  NicknameViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/28/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController {
    
    @IBOutlet weak var nameTextfield: NITextfield!
    @IBOutlet weak var button: CustomButton!
    
    var originalType: String = ""
    /// 第三方账号的 id 
    var id: String = ""
    var nameFrom3rd: String = ""
    var hasRegistered = false   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameTextfield.layer.cornerRadius = 22
        self.nameTextfield.layer.masksToBounds = true
        
        self.nameTextfield.delegate = self
        self.nameTextfield.text = nameFrom3rd
        
        self.button.layer.cornerRadius = 22
        self.button.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmRegister(sender: UIButton) {
        self.handleConfirmRegister()
    }
    
    @IBAction func backWelcomeViewController(sender: UIButton) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: UIControl) {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toPrivacy" {
            let privacyWebView = segue.destinationViewController as! PrivacyViewController
            privacyWebView.urlString = "http://nian.so/privacy.php"
        }
    }
    
}


extension NicknameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.nameTextfield.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.handleConfirmRegister()
    }
    
}

extension NicknameViewController {
    
    /**
     <#Description#>
     */
    func handleConfirmRegister() {
        if nameTextfield.text?.characters.count > 0 {
            
            if !self.validateNickname(nameTextfield.text!) {
                return
            }
            
            self.button.startAnimating()
            
            LogOrRegModel.checkNameAvailability(name: self.nameTextfield.text!) {
                (task, responseObject, error) in
                
                if let _ = error {
                    self.showTipText("网络有点问题，等一会儿再试")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["error"] != 0 {
                        self.button.stopAnimating()
                        self.button.setTitle("确定", forState: .Normal)
                        
                        self.showTipText("昵称被占用...")
                        
                    } else {
                        /*=========================================================================================================================================*/
                        
                        LogOrRegModel.registerVia3rd(self.id, type: self.originalType, name: self.nameTextfield.text!, nameFrom3rd: self.nameFrom3rd) {
                            (task, responseObject, error) in
                            
                            self.button.stopAnimating()
                            self.button.setTitle("确定", forState: UIControlState.Normal)
                            
                            if let _ = error {
                                self.showTipText("网络有点问题，等一会儿再试")
                            } else {
                                
                                let json = JSON(responseObject!)
                                
                                if json["error"] != 0 {
                                    self.showTipText("注册不成功...")
                                } else {
                                    let shell = json["data"]["shell"].stringValue
                                    let uid = json["data"]["uid"].stringValue

                                    /// uid 和 shell 保存到 keychain
                                    let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                                    uidKey.setObject(uid, forKey: kSecAttrAccount)
                                    uidKey.setObject(shell, forKey: kSecValueData)
                                    
                                    NSUserDefaults.standardUserDefaults().setObject(self.nameTextfield.text!, forKey: "user")
                                    
                                    Api.requestLoad()
                                    globalWillReEnter = 1
                                    self.launch()
                                    
                                    print("昵称")
                                    self.nameTextfield.text = ""
                                }
                            }
                        }
                        
                    }
                }
            }
        } else {
            
        }
    }
    
    
    /**
     验证昵称是否符合要求
     */
    func validateNickname(name: String) -> Bool {
        if name == "" {
            self.showTipText("名字不能是空的...")
            
            return false
        } else if name.characters.count < 2 {
            self.showTipText("名字有点短...")
            
            return false
        } else if !name.isValidName() {
            self.showTipText("名字里有奇怪的字符...")
            
            return false
        }
        
        return true
    }
    
    
}












