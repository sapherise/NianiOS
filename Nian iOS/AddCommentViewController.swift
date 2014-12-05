//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol AddCommentDelegate {   //😍
    var ReturnReplyRow:Int { get set }
    var ReturnReplyContent:String { get set }
    var ReturnReplyId:String { get set }
    func commentFinish()
}

class AddCommentViewController: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet var TextView:UITextView!
    @IBOutlet var Line: UIView!
    var toggle:Int = 0
    var Id:String = ""
    var content:String = ""
    var Row:Int = 0
    var delegate: AddCommentDelegate?      //😍
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.view.backgroundColor = BGColor
        self.TextView.backgroundColor = BGColor
        self.Line.backgroundColor = LineColor
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addReply")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "回应"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        self.TextView.text = self.content
        
        dispatch_async(dispatch_get_main_queue(), {
            self.TextView.becomeFirstResponder()
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        })
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.TextView!.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addReply(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var safeuser = Sa.objectForKey("user") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)", "http://nian.so/api/comment_query.php")
            if sa != "" && sa != "err" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.ReturnReplyRow = self.Row
                    self.delegate?.ReturnReplyContent = self.TextView.text
                    self.delegate?.ReturnReplyId = sa
                    self.delegate?.commentFinish()
                    self.navigationController!.popViewControllerAnimated(true)
                })
            }
        })
        //推送通知
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(safeuid)", "http://nian.so/push/push_mobile.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
}
