//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol editCircleDelegate {
    func editCircle(editPrivate:Int, editTitle:String, editDes:String, editImage:String)
}

class AddCircleController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, CircleTagDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var uploadWait: UIActivityIndicatorView!
    @IBOutlet weak var field1: UITextField!  //title text field
    @IBOutlet weak var field2: SZTextView!
    @IBOutlet weak var setPrivate: UIImageView!
    @IBOutlet weak var imageDreamHead: UIImageView!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet var viewTag: UIView!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelTag: UILabel!
    
    var actionSheet: UIActionSheet?
    var setDreamActionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editCircleDelegate?
    
    var isEdit: Bool = false
    var idDream: String = ""
    var idCircle: String = ""
    var titleCircle: String = ""
    var content: String = ""
    var uploadUrl: String = ""
    var isPrivate: Bool = false
    
    var keyboardHeight: CGFloat = 0.0  // 键盘的高度
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    func uploadClick() {
        self.dismissKeyboard()
        
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
                if !self.isPrivate {
                    //设置为私密
                    self.isPrivate = true
                    self.setPrivate.image = UIImage(named: "lock")
                } else {
                    //设置为公开
                    self.isPrivate = false
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
        self.imageDreamHead.image = UIImage(named: "add_no_plus")
        self.uploadWait!.startAnimating()
        var uy = UpYun()
        uy.successBlocker = ({(data: AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadUrl = data.objectForKey("url") as! String
            self.uploadUrl = SAReplace(self.uploadUrl, "/dream/", "") as String
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.contentMode = .ScaleToFill
            self.imageDreamHead.image = img
            setCacheImage(url, img, 0)
            self.uploadWait!.stopAnimating()
        })
        uy.failBlocker = ({(error: NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.imageDreamHead.image = UIImage(named: "add_plus")
        })
        uy.uploadImage(resizedImage(img, 260), savekey: getSaveKey("dream", "png") as String)
    }
    
    //MARK: view load 相关的方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.isEdit ? "编辑梦境" : "新梦境！"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        self.view.addSubview(navView)
        
        self.setPrivate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "setDream"))
        
        self.imageDreamHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "uploadClick"))
        self.imageDreamHead.layer.cornerRadius = 4.0
        self.imageDreamHead.layer.masksToBounds = true
        self.field1.setWidth(globalWidth - 124)
        self.setPrivate.setX(globalWidth - 44)
        self.field2.setWidth(globalWidth)
//        UIScreen.mainScreen().bounds.height > 480 ? self.field2.setHeight(120) : self.field2.setHeight(96)
//        self.field2.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.field2.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        self.seperatorView.setWidth(globalWidth)
        self.seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        self.view.backgroundColor = UIColor.whiteColor()
        //        self.field1!.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), forKeyPath: "_placeholderLabel.textColor")
        self.field1.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field1.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        
        self.field2.attributedPlaceholder = NSAttributedString(string: "梦境简介（可选）" ,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field2.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        self.field2.delegate = self
        setupField()
        
        if isPrivate {
            setPrivate.image = UIImage(named: "lock")
        } else {
            setPrivate.image = UIImage(named: "unlock")
        }
        
        uploadWait.transform = CGAffineTransformMakeScale(0.7, 0.7)
        uploadWait.center = imageDreamHead.center
        uploadWait.color = UIColor(red:0.6, green:0.6, blue:0.6, alpha:0.6)
        
        if self.isEdit {
            self.field1!.text = self.titleCircle.decode()
            self.field2.text = self.content.decode()
            var url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            imageDreamHead.setImage(url, placeHolder: IconColor, bool: false)
            
            labelTag.text = "不能编辑绑定的记本..."
            labelTag.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        } else {
            viewTag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTag"))
            labelTag.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "add")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        self.uploadWait!.hidden = true
        viewTag.setWidth(globalWidth)
        viewLine.setWidth(globalWidth)
        scrollView.frame.size = CGSizeMake(globalWidth, globalHeight - 64)
        scrollView.contentSize.height = globalHeight - 64
    }
    
    func onTag() {
        var sb = UIStoryboard(name: "CircleTag", bundle: nil)
        var vc = sb.instantiateViewControllerWithIdentifier("CircleTagViewController") as! CircleTagViewController
        vc.circleTagDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func delegateTag(title: String, id: String) {
        labelTag.text = title.decode()
        labelTag.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        self.idDream = id
    }
    
    func setupField() {
        var h = globalHeight - 64 - 64 - 44 - keyboardHeight
        field2.setHeight(h)
        viewTag.setY(field2.bottom())
        scrollView.contentSize.height = globalHeight - 64 - keyboardHeight
    }
    
    func setDream(){
        self.dismissKeyboard()
        self.setDreamActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        if self.isPrivate {
            self.setDreamActionSheet!.addButtonWithTitle("设置为开放加入")
        } else {
            self.setDreamActionSheet!.addButtonWithTitle("设置为验证加入")
        }
        
        self.setDreamActionSheet!.addButtonWithTitle("取消")
        self.setDreamActionSheet!.cancelButtonIndex = 1
        self.setDreamActionSheet!.showInView(self.view)
    }
    
    func dismissKeyboard() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
    }
    
    //MARK: 添加 new Dream
    
    func add(){
        var title = SAEncode(SAHtml(field1.text))
        var content = SAEncode(SAHtml(field2.text))
        if title == "" {
            field1.becomeFirstResponder()
            self.view.showTipText("你的梦境还没有名字...", delay: 2)
        } else if self.uploadUrl == "" {
            self.view.showTipText("你的梦境还没有封面...", delay: 2)
        } else if self.idDream == "" && !isEdit {
            self.view.showTipText("你的梦境还没绑定记本...", delay: 2)
        } else {
            self.navigationItem.rightBarButtonItems = buttonArray()
            var privateType = isPrivate ? 1 : 0
            if !isEdit {
                Api.postCircleNew(title, content: content, img: self.uploadUrl, privateType: privateType, dream: self.idDream) { json in
                    if json != nil {
                        var id = json!.objectForKey("id") as! String
                        var postdate = json!.objectForKey("postdate") as! String
                        var success = json!.objectForKey("success") as! String
                        if success == "1" {
                            var title = self.field1.text
                            SQLCircleListInsert(id, title, self.uploadUrl, postdate)
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        }
                    }
                }
            } else {
                Api.postCircleEdit(title, content: content, img: self.uploadUrl, privateType: privateType, ID: self.idCircle) { json in
                    if json != nil {
                        self.delegate?.editCircle(privateType, editTitle: self.field1.text, editDes: self.field2.text, editImage: self.uploadUrl)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        if let h = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
            keyboardHeight = h
            setupField()
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardHeight = 0
        setupField()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view .isKindOfClass(UITableView) || touch.view .isKindOfClass(UITableViewCell) {
            return false
        }
        
        return true
    }
    
}
