//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class AddBBSController: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet var Line1: UIView?
    @IBOutlet var Line2: UIView?
    @IBOutlet var field1:UITextField?
    @IBOutlet var field2:UITextView?
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        self.view.backgroundColor = BGColor
        self.Line1!.backgroundColor = LineColor
        self.Line2!.backgroundColor = LineColor
        self.field1!.textColor = IconColor
        self.field2!.textColor = IconColor
        self.field1!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        
        dispatch_async(dispatch_get_main_queue(), {
            self.field1!.becomeFirstResponder()
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        })
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addBBSOK")
        rightButton.image = UIImage(named:"ok")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "新话题"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2!.resignFirstResponder()
    }
    
    func addBBSOK(){
        if (( self.field1!.text != "" ) & ( self.field2!.text != "" )) {
            self.navigationItem.rightBarButtonItems = buttonArray()
            var title = self.field1!.text
            var content = self.field2!.text
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            
            dispatch_async(dispatch_get_main_queue(), {
                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content!)&&title=\(title!)", "http://nian.so/api/add_bbs.php")
                if(sa == "1"){
                    globalWillBBSReload = 1
                    self.navigationController!.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
