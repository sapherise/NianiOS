//
//  NicknameViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/28/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class NicknameViewController: AccountBaseViewController {
    
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
        
        if self.validateNameFromTextField(nameTextfield.text) {

            self.button.startAnimating()
            
            LogOrRegModel.checkNameAvailability(name: nameTextfield.text!, callback: {
                (task, responseObject, error) -> Void in
                
                let (_, errorResult) = self.preProcessNetworkResult(task, object: responseObject, error: error)
                
                if let _error = errorResult {
                    self.button.stopAnimating()
                    self.button.setTitle("确定", forState: .Normal)
                    
                    switch _error {
                    case .resultError(_, _):
                        self.view.showTipText("昵称被占用...")
                    default:
                        break
                    }
                } else {
                    self.registerVia3rd()
                }
                
            })
        }
        
    }
    
    func registerVia3rd() {
        LogOrRegModel.registerVia3rd(self.id, type: self.originalType, name: self.nameTextfield.text!, nameFrom3rd: self.nameFrom3rd) {
            (task, responseObject, error) -> Void in
            
            self.button.stopAnimating()
            self.button.setTitle("确定", forState: UIControlState.Normal)
            
            let (_json, errorResult) = self.preProcessNetworkResult(task, object: responseObject, error: error)
            
            if let _ = errorResult {
                self.view.showTipText("注册不成功...")
            } else {
                NSUserDefaults.standardUserDefaults().setObject(self.nameTextfield.text!, forKey: "user")
                NSUserDefaults.standardUserDefaults().synchronize()

                self.presentViewController(self.enterHome(_json!), animated: true, completion: {
                    self.nameTextfield.text = ""
                })
                
                Api.postJpushBinding(){_ in }
                
            }
            
        }
    }
    
    
    
}












