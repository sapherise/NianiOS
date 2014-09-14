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
    @IBOutlet var coinNumber:UILabel?
    @IBOutlet var helpView:UIView?
    
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
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var safename = Sa.objectForKey("user") as String
        self.view.backgroundColor = BGColor
        var userImageURL = "http://img.nian.so/head/\(safeuid).jpg!head"
        self.head.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        
        
        var url = NSURL(string:"http://nian.so/api/user.php?uid=\(safeuid)")
        var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var sa: AnyObject! = json.objectForKey("user")
        var email: AnyObject! = sa.objectForKey("email") as String
        var coin: AnyObject! = sa.objectForKey("coin") as String
        
        self.inputName.text = safename
        self.inputEmail.text = "\(email)"
        self.coinNumber!.text = "\(coin)"
        
        self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAhelp"))
        self.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "SAlogout"))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    }
    
    func SAhelp(){
        var helpVC = HelpViewController()
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        inputName.resignFirstResponder()
        inputEmail.resignFirstResponder()
    }
    
    func SAlogout(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        Sa.removeObjectForKey("uid")
        Sa.removeObjectForKey("shell")
        Sa.removeObjectForKey("followData")
        Sa.removeObjectForKey("user")
        Sa.synchronize()
        delegate?.SALogout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func back(sender:UISwipeGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }
}