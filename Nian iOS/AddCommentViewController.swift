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

class AddCommentViewController: UIViewController {
    
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
        self.view.backgroundColor = BGColor
        self.TextView.backgroundColor = BGColor
        self.Line.backgroundColor = LineColor
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addReply")
        rightButton.image = UIImage(named:"ok")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "回应"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.TextView.text = content
        self.TextView.becomeFirstResponder()
        
        var swipe = UISwipeGestureRecognizer(target: self, action: "back")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipe)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addReply(){
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var sa = SAPost("id=\(Id)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)", "http://nian.so/api/comment_query.php")
        if sa != "" {
            delegate?.ReturnReplyRow = self.Row
            delegate?.ReturnReplyContent = self.TextView.text
            delegate?.ReturnReplyId = sa
            delegate?.commentFinish()
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
