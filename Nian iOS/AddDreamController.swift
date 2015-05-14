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
    @IBOutlet weak var tagSearchTableView: UITableView!
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var field1: UITextField?  //title text field
    @IBOutlet var field2: UITextView!   //brief introduction text field
    @IBOutlet var field3: KSTokenView!
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
        setupViews()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        // 根据 self.tagSearchTableView 是否出现来决定 tmpSize 的高度是否增加一个 table
        
//        var height = 64 + 182 - 112 + field2.frame.size.height - 22 + field3.frame.size.height
        var height = 101 + field2.frame.size.height + field3.frame.size.height + (self.tagSearchTableView.hidden ? 0 : self.tagSearchTableView.frame.size.height)
        var tmpSize: CGSize = CGSizeMake(self.containerView.frame.size.width, max(height, self.containerView.frame.size.height))
        self.scrollView.contentSize = tmpSize
    }
    
    func setupViews(){
        //刚一开始的时候, tagSearchTableView 应该隐藏，因为 field3(tag text view) 不是 firstResponser
        self.tagSearchTableView.hidden = true
        
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        
        self.imageDreamHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "uploadClick"))
        self.view.addSubview(navView)

        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.field1!.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), forKeyPath: "_placeholderLabel.textColor")
        self.field2.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
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
        field3.delegate = self    
        field3.promptText = "Top 5: "
        field3.placeholder = "Type to search"
        field3.descriptionText = "Languages"
        field3.maxTokenLimit = 5 //default is -1 for unlimited number of tokens
        field3.style = .Squared
        
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
    }
    
    func addDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
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
                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content!)&&title=\(title!)&&img=\(self.uploadUrl)&&private=\(self.isPrivate)&&hashtag=\(self.tagType)", "http://nian.so/api/add_query.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        globalWillNianReload = 1
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            })
        }else{
            self.field1!.becomeFirstResponder()
        }
    }
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content!)&&title=\(title!)&&img=\(self.uploadUrl)&&private=\(self.editPrivate)&&id=\(self.editId)&&hashtag=\(self.tagType)", "http://nian.so/api/editdream.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        globalWillNianReload = 1
                        self.navigationController?.popViewControllerAnimated(true)
                        self.delegate?.editDream(self.editPrivate, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTag: "\(self.tagType)")
                    })
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
}


extension AddDreamController: KSTokenViewDelegate {
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        
    }
    
    
    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
}

























