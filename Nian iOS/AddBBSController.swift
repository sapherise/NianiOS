//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class AddBBSController: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate{
    @IBOutlet var field1:UITextField?
    @IBOutlet var field2:UITextView?
    @IBOutlet var viewHolder: UIView!
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.viewHolder.layer.borderColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1).CGColor
        self.viewHolder.layer.borderWidth = 1
        
        self.view.backgroundColor = BGColor
        self.field2!.delegate = self
        self.field1!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        self.field1!.becomeFirstResponder()
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addBBSOK")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "新话题"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "话题内容" {
            textView.text = ""
        }
        textView.textColor = UIColor.blackColor()
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2!.resignFirstResponder()
    }
    
    func addBBSOK(){
        if (( self.field1!.text != "" ) & ( self.field2!.text != "" ) & ( self.field2!.text != "话题内容" )) {
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
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
}
