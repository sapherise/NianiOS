//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


protocol AddDelegate {   //😍
    func SAReloadData()
}
class AddDreamController: UIViewController {
    
    @IBOutlet var Line1: UIView?
    @IBOutlet var Line2: UIView?
    @IBOutlet var uploadButton: UIButton?
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var uploadDone: UIImageView?
    @IBOutlet var field1:UITextField?
    @IBOutlet var field2:UITextField?
    var delegate: AddDelegate?      //😍
    
    var toggle:Int = 0
    
    @IBAction func uploadClick(sender: AnyObject) {
        if(toggle == 0){    //uploading
            self.uploadWait!.hidden = false
            self.uploadWait!.startAnimating()
            self.uploadDone!.hidden = true
            toggle = 1
        }else{      //done
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = false
            toggle = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        self.view.backgroundColor = BGColor
        self.Line1?.backgroundColor = LineColor
        self.Line2?.backgroundColor = LineColor
        self.field1?.textColor = IconColor
        self.field2?.textColor = IconColor
        self.field1?.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        self.field2?.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        self.field1?.becomeFirstResponder()
        
        self.uploadWait?.hidden = true
        self.uploadDone?.hidden = true
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamOK")
        rightButton.image = UIImage(named:"ok")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "新梦想！"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var swipe = UISwipeGestureRecognizer(target: self, action: "back")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipe)
    }
    
    func addDreamOK(){
        var title = self.field1?.text
        var content = self.field2?.text
        title = SAEncode(SAHtml(title!))
        content = SAEncode(SAHtml(content!))
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        
        var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)&&title=\(title)", "http://nian.so/api/add_query.php")
        if(sa == "1"){
            self.navigationController!.popViewControllerAnimated(true)
            delegate?.SAReloadData()        //debug
        }
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    
    
}
