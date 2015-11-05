//
//  BindEmailViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/5/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

@objc protocol bindEmailDelegate {

    optional func bindEmail(email email: String)
}

class BindEmailViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var emailTextField: NITextfield!
    
    @IBOutlet weak var passwordTextField: NITextfield!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    /// email text field 距离顶部的约束
    @IBOutlet weak var emailTextFieldToTop: NSLayoutConstraint!
    /// password text field 顶部到 email text field 的约束
    @IBOutlet weak var pwdTextFieldTopToEmail: NSLayoutConstraint!
    
    weak var delegate: bindEmailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.emailTextField.layer.cornerRadius = 22
        self.emailTextField.layer.masksToBounds = true
        self.emailTextField.leftViewMode = .Always
        
        self.passwordTextField.hidden = true
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }

    @IBAction func dismissVC(sender: UIButton) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}


extension BindEmailViewController: UITextFieldDelegate {
    
    
    
    
    
    
}





