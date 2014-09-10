//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

protocol LogoutDelegate {      //😍       我拥有一个代理公司
    func SALogout()
}

class SettingsViewController: UIViewController{
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var head:UIImageView!
    @IBOutlet var logout:UIView!
    var delegate: LogoutDelegate?  //😍    设定这个代理公司
    @IBOutlet var inputName:UITextField!
    @IBOutlet var inputEmail:UITextField!
    
    override func viewDidLoad(){
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.scrollView.contentSize = CGSizeMake(320, 700)
    }
    
    
    func setupViews(){
        self.view.backgroundColor = BGColor
        var img = "1.jpg"
        var userImageURL = "http://img.nian.so/head/\(img)!head"
        self.head.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        
        self.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAlogout"))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        inputName.resignFirstResponder()
        inputEmail.resignFirstResponder()
    }
    
    func SAlogout(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        Sa.removeObjectForKey("uid")
        Sa.removeObjectForKey("shell")
        Sa.synchronize()
        delegate?.SALogout()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func back(sender:UISwipeGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }
}