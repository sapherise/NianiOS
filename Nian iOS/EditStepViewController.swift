//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol EditstepDelegate {   //😍
    func Editstep()
}

class EditStepViewController: UIViewController {
    
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var uploadWait: UIActivityIndicatorView!
    @IBOutlet var uploadDone: UIImageView!
    @IBOutlet var TextView:UITextView!
    @IBOutlet var Line: UIView!
    var toggle:Int = 0
    var sid:String = ""
    var delegate: EditstepDelegate?      //😍
    
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        var url = NSURL(string:"http://nian.so/api/editstep.php?sid=\(sid)")
        var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var sa: AnyObject! = json.objectForKey("dream")
        var content: AnyObject! = sa.objectForKey("content")
        var img: AnyObject! = sa.objectForKey("img")
        var img0: AnyObject! = sa.objectForKey("img0")
        var img1: AnyObject! = sa.objectForKey("img1")
        self.TextView.text = content as String
        
        self.uploadWait.hidden = true
        self.view.backgroundColor = BGColor
        self.TextView.backgroundColor = BGColor
        self.Line.backgroundColor = LineColor
        
        self.uploadWait!.hidden = true
        self.uploadDone!.hidden = true
        
        self.TextView.becomeFirstResponder()
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editStep")
        rightButton.image = UIImage(named:"ok")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "修改进展"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(){
        self.navigationController.popViewControllerAnimated(true)
    }
    
    func editStep(){
        println(self.sid)
        println("更新成功")
        
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var sa=SAPost("sid=\(sid)&&uid=1&&content=\(content)", "http://nian.so/api/editstep_query.php")
        if(sa == "1"){
            delegate?.Editstep()
            self.navigationController.popViewControllerAnimated(true)
            println("太棒辣")
        }
    }
}
