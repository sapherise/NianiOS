//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol AddBBSCommentDelegate {   //😍
    var ReturnReplyRow:Int { get set }
    var ReturnReplyContent:String { get set }
    var ReturnReplyId:String { get set }
    func commentFinish()
}

class AddBBSCommentViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var TextView:UITextView!
    var toggle:Int = 0
    var Id:String = ""
    var content:String = ""
    var Row:Int = 0
    var delegate: AddBBSCommentDelegate?      //😍
    var navView:UIView!
    
    func setupViews(){
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = BGColor
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addReply")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "回应话题"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        self.TextView.setHeight(globalHeight-84)
        self.TextView.text = self.content
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        self.viewBack()
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.TextView!.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.TextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
    
    override func viewWillDisappear(animated: Bool) {
        keyboardEndObserve()
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        var keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size)!
        var keyboardHeight = keyboardSize.height
        var textHeight = globalHeight-keyboardHeight-20
        if textHeight > 0 {
            self.TextView.setHeight(textHeight)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        self.TextView.setHeight(globalHeight-20)
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
        Api.postAddBBSComment(self.Id, content: content) { string in
            if string != nil {
                println(string)
                self.delegate?.ReturnReplyRow = self.Row
                self.delegate?.ReturnReplyContent = self.TextView.text
                self.delegate?.ReturnReplyId = string!
                self.delegate?.commentFinish()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
//        static func postAddBBSComment(id: String, content: String, callback: V.StringCallback) {
//            loadCookies()
//            V.httpPostForString("http://nian.so/api/addbbscomment_query.php", content: "id=\(id)&&uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)", callback: callback)
//        }
        
    }
}
