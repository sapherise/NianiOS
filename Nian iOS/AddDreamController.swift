//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol editDreamDelegate {
    func editDream(editPrivate:String, editTitle:String, editDes:String, editImage:String, editTag:String)
}

class AddDreamController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DreamTagDelegate, UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var field1: UITextField?  //title text field
    @IBOutlet var field2: UITextView!   //brief introduction text field
    @IBOutlet var tokenView: KSTokenView!
    @IBOutlet var setPrivate: UIImageView!
    @IBOutlet var imageDreamHead: UIImageView!
    @IBOutlet var imageTag: UIImageView!
    
    var actionSheet: UIActionSheet?
    var setDreamActionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editDreamDelegate?
    var tagType: Int = 0
    var readyForTag: Int = 0     //当为1时自动跳转到Tag去
    
    var uploadUrl: String = ""
    
    var isEdit: Int = 0
    var editId: String = ""
    var editTitle: String = ""
    var editContent: String = ""
    var editImage: String = ""
    var editPrivate: String = ""
    
    var isPrivate: Int = 0  // 0: 公开；1：私密
    
    func uploadClick() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        } else if actionSheet == self.setDreamActionSheet {
            if buttonIndex == 0 {
                if self.isPrivate == 0 {
                    //设置为私密
                    self.isPrivate = 1
                    self.editPrivate = "0"
                    self.setPrivate.image = UIImage(named: "lock")
                } else if self.isPrivate == 1 {
                    //设置为公开
                    self.isPrivate = 0
                    self.editPrivate = "1"
                    self.setPrivate.image = UIImage(named: "unlock")
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        self.uploadWait!.hidden = false
        self.uploadWait!.startAnimating()
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadUrl = data.objectForKey("url") as! String
            self.uploadUrl = SAReplace(self.uploadUrl, "/dream/", "") as String
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.setImage(url, placeHolder: UIColor(red:0.9, green:0.89, blue:0.89, alpha:1))
            setCacheImage(url, img, 150)
        })
        uy.failBlocker = ({(error:NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
        })
        uy.uploadImage(resizedImage(img, 260), savekey: getSaveKey("dream", "png") as String)
    }
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.delaysContentTouches = false
        self.scrollView.canCancelContentTouches = false
        setupViews()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
//        var height = 64 + 182 - 112 + field2.frame.size.height - 22 + tokenView.frame.size.height
        var height = 101 + field2.frame.size.height + tokenView.frame.size.height
        var tmpSize: CGSize = CGSizeMake(self.containerView.frame.size.width, max(height, self.containerView.frame.size.height))
        if self.tokenView._tokenField.isFirstResponder() {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, height + 300)
            self.scrollView.setContentOffset(CGPointMake(0, field2.frame.size.height + 76), animated: true)
        } else {
            self.scrollView.contentSize = tmpSize
        }
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        
        self.imageDreamHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "uploadClick"))
        self.view.addSubview(navView)

        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.view.backgroundColor = UIColor.whiteColor()
        self.field1!.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), forKeyPath: "_placeholderLabel.textColor")
        self.field2.delegate = self
        self.scrollView.delegate = self
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        delay(0.5, { () -> () in
            if self.readyForTag == 1 {
                self.onTagClick()
                return
            }
        })
        
        if self.isEdit == 1 {
            self.field1!.text = self.editTitle
            self.field2.text = self.editContent
            self.uploadUrl = self.editImage
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.setImage(url, placeHolder: UIColor(red:0.9, green:0.89, blue:0.89, alpha:1))
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }else{
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        self.uploadWait!.hidden = true
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        if self.isEdit == 1 {
            titleLabel.text = "编辑记本"
        }else{
            titleLabel.text = "新记本！"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        
        self.setPrivate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "setDream"))
        self.imageTag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTagClick"))
        
        //设置 tag view ---- 引用了第三方库
        tokenView.delegate = self    
        tokenView.promptText = "    "
        tokenView.placeholder = "按空格输入多个标签"
        tokenView.maxTokenLimit = 20 //default is -1 for unlimited number of tokens
        tokenView.style = .Squared
        tokenView.font = UIFont.systemFontOfSize(14)
//        tokenView.direction = KSTokenViewScrollDirection.Horizontal
    }
    
    func onTagClick(){
        var storyboard = UIStoryboard(name: "DreamTagViewController", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("DreamTagViewController") as! DreamTagViewController
        viewController.dreamTagDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setDream(){
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()
        self.setDreamActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        if self.isPrivate == 0 {
            self.setDreamActionSheet!.addButtonWithTitle("设为私密")
        } else if self.isPrivate == 1 {
            self.setDreamActionSheet!.addButtonWithTitle("设为公开")
        }
        
        self.setDreamActionSheet!.addButtonWithTitle("取消")
        self.setDreamActionSheet!.cancelButtonIndex = 1
        self.setDreamActionSheet!.showInView(self.view)
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()   
    }
    
    @IBAction func dismissKbd(sender: UIControl) {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.resignFirstResponder()
    }
    
    
    func addDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokens()
        var text = [String]()

        if count(tags!) > 0 {
            for i in 0...(count(tags!) - 1){
                var tmpString: String = dropFirst((tags![i] as KSToken).title)
                text.append(tmpString)
            }
        }
        
        if content == "记本简介（可选）" {
            content = ""
        }
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postAddDream(title!, content: content!, uploadUrl: self.uploadUrl, isPrivate: self.isPrivate, tagType: self.tagType, tags: text) {
                    result in
                    if result == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            globalWillNianReload = 1
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    }
                }
            })
        }else{
            self.field1!.becomeFirstResponder()
        }
    }
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokens()
        var text = [String]()
        
        if count(tags!) > 0 {
            for i in 0...(count(tags!) - 1) {
                var tmpString: String = dropFirst((tags![i] as KSToken).title)
                text.append(tmpString)
            }
        }
        
        
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postAddDream(title!, content: content!, uploadUrl: self.uploadUrl, isPrivate: self.isPrivate, tagType: self.tagType, tags: text) {
                    result in
                    if result == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            globalWillNianReload = 1
                            self.navigationController?.popViewControllerAnimated(true)
                            self.delegate?.editDream(self.editPrivate, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTag: "\(self.tagType)")
                        })
                    }
                }
            })
        } else {
            self.field1!.becomeFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "记本简介（可选）" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    // MARK: DreamTagDelegate
    
    func onTagSelected(tag: String, tagType: Int) {
//        self.labelTag?.text = tag
//        self.tagType = tagType + 1
    }
    
//    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
//        let textField = notification.object as! UITextField
//        
//        if count(textField.text) < 5 {
//            textField.text = "     "
//        }
//    }
//    
//    func handleTextFieldTextDidBeginEditingNotification(notification: NSNotification) {
//        let textField = notification.object as! UITextField
//        
//        if count(textField.text) < 5 {
//            textField.text = "     "
//        }
//    }
//    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        return touch.view == gestureRecognizer.view
//    }
    
}

extension AddDreamController: KSTokenViewDelegate {
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        var data: Array<String> = []
        if count(string) > 0 {
            
            //用户有可能输入汉字、空格等，要先转义
            var _string = SAEncode(SAHtml(string))
            Api.getAutoComplete(_string, callback: {
                json in
                if json != nil {
                    data = json as! Array
                }
                completion!(results: data)
            })
        }
    }
    
    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
    
    func tokenViewDidBeginEditing(tokenView: KSTokenView) {
    }
    
    func tokenViewDidEndEditing(tokenView: KSTokenView) {
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)

    }
    
    func tokenView(tokenView: KSTokenView, didAddToken token: KSToken) {
        // 用户已经添加了 token
        var _string = token.title.stringByReplacingOccurrencesOfString("#", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
        
        Api.getTags(SAEncode(SAHtml(_string)), callback:{
            json in
                var status = json!["status"] as! NSNumber
        })
    }
    
    func tokenView(tokenView: KSTokenView, didDeleteToken token: KSToken) {
        var number = count(self.tokenView.tokens()!)
        
        if number == 0 {
            self.tokenView._searchTableView.hidden == true
        } else {
            self.tokenView._searchTableView.hidden = false 
        }
    }
    
}

























