//
//  NicknameViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/28/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    @IBAction func confirmRegister(_ sender: UIButton) {
        self.handleConfirmRegister()
    }
    
    @IBAction func backWelcomeViewController(_ sender: UIButton) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: UIControl) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toPrivacy" {
            let privacyWebView = segue.destination as! PrivacyViewController
            privacyWebView.urlString = "http://nian.so/privacy.php"
        }
    }
    
}


extension NicknameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextfield.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
            // todo
//            LogOrRegModel.checkNameAvailability(name: self.nameTextfield.text!) {
//                (task, responseObject, error) in
//                
//                if let _ = error {
//                    self.showTipText("网络有点问题，等一会儿再试")
//                } else {
//                    // todo
////                    let json = JSON(responseObject!)
////                    if json["error"] != 0 {
////                        self.button.stopAnimating()
////                        self.button.setTitle("确定", for: UIControlState())
////                        self.showTipText("昵称被占用...")
////                    } else {
////                        LogOrRegModel.registerVia3rd(self.id, type: self.originalType, name: self.nameTextfield.text!, nameFrom3rd: self.nameFrom3rd) {
////                            (task, responseObject, error) in
////                            
////                            self.button.stopAnimating()
////                            self.button.setTitle("确定", for: UIControlState())
////                            
////                            if let _ = error {
////                                self.showTipText("网络有点问题，等一会儿再试")
////                            } else {
////                                
////                                let json = JSON(responseObject!)
////                                
////                                if json["error"] != 0 {
////                                    self.showTipText("注册不成功...")
////                                } else {
////                                    let shell = json["data"]["shell"].stringValue
////                                    let uid = json["data"]["uid"].stringValue
////
////                                    /// uid 和 shell 保存到 keychain
////                                    let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
////                                    uidKey.setObject(uid, forKey: kSecAttrAccount)
////                                    uidKey.setObject(shell, forKey: kSecValueData)
////                                    
////                                    UserDefaults.standard.set(self.nameTextfield.text!, forKey: "user")
////                                    
////                                    Api.requestLoad()
////                                    
////                                    /* 使用第三方来注册 */
////                                    self.launch(0)
////                                    self.pushTomorrow()
////                                    self.nameTextfield.text = ""
////                                }
////                            }
////                        }
////                        
////                    }
//                }
//            }
        } else {
            
        }
    }
    
    
    /**
     验证昵称是否符合要求
     */
    func validateNickname(_ name: String) -> Bool {
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












