//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

//protocol AddstepDelegate {   //😍
//    func countUp()
//}

class AddCommentViewController: UIViewController {
    
    @IBOutlet var TextView:UITextView!
    @IBOutlet var Line: UIView!
    var toggle:Int = 0
    var Id:String = ""
    var content:String = ""
//    var delegate: AddstepDelegate?      //😍
    
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
        var sa = SAPost("id=\(Id)&&uid=1&&content=\(content)", "http://nian.so/api/comment_query.php")
        if sa == "1" {
            self.navigationController.popViewControllerAnimated(true)
        }
    }
    
    func back(){
        self.navigationController.popViewControllerAnimated(true)
    }
}
