//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class AddDreamController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DreamTagDelegate {
    
    @IBOutlet var Line1: UIView?
    @IBOutlet var Line2: UIView?
    @IBOutlet var uploadButton: UIButton?
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var uploadDone: UIImageView?
    @IBOutlet var field1:UITextField?
    @IBOutlet var field2:UITextField?
    @IBOutlet var setButton: UIButton!
    @IBOutlet var labelTag: UILabel?
    var actionSheet:UIActionSheet?
    var setDreamActionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    
    var uploadUrl:String = ""
    
    var isEdit:Int = 0
    var editId:String = ""
    var editTitle:String = ""
    var editContent:String = ""
    var editImage:String = ""
    var editPrivate:String = ""
    
    var isPrivate:Int = 0
    
    @IBAction func uploadClick(sender: AnyObject) {
        self.field1!.resignFirstResponder()
        self.field2!.resignFirstResponder()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
        self.imagePicker = UIImagePickerController()
        self.imagePicker!.delegate = self
        self.imagePicker!.allowsEditing = false
        if buttonIndex == 0 {
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }
        }
        }else if actionSheet == self.setDreamActionSheet {
            if buttonIndex == 0 {
                self.isPrivate = 0
                self.editPrivate = "0"
                println("变为公开")
            }else if buttonIndex == 1 {
                self.isPrivate = 1
                self.editPrivate = "1"
                println("变为私密")
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        self.uploadWait!.hidden = false
        self.uploadWait!.startAnimating()
        self.uploadDone!.hidden = true
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = false
            self.uploadUrl = data.objectForKey("url") as String
            self.uploadUrl = SAReplace(self.uploadUrl, "/dream/", "") as String
        })
        uy.failBlocker = ({(error:NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = true
        })
        uy.uploadImage(resizedImage(img, 260), savekey: getSaveKey("dream", "png"))
    }
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = NavColor
        self.view.addSubview(navView)
        
        self.view.backgroundColor = BGColor
        self.Line1!.backgroundColor = LineColor
        self.Line2!.backgroundColor = LineColor
        self.field1!.textColor = IconColor
        self.field2!.textColor = IconColor
        self.field1!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        self.field2!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        
        dispatch_async(dispatch_get_main_queue(), {
            self.field1!.becomeFirstResponder()
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        })
        
        if self.isEdit == 1 {
            self.field1!.text = self.editTitle
            self.field2!.text = self.editContent
            self.uploadUrl = self.editImage
            
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editDreamOK")
            rightButton.image = UIImage(named:"ok")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }else{
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamOK")
            rightButton.image = UIImage(named:"ok")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        
        self.uploadWait!.hidden = true
        self.uploadDone!.hidden = true
        
        
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        if self.isEdit == 1 {
            titleLabel.text = "编辑梦想"
        }else{
            titleLabel.text = "新梦想！"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        self.setButton.addTarget(self, action: "setDream", forControlEvents: UIControlEvents.TouchUpInside)
        self.labelTag!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTagClick"))
        self.labelTag!.userInteractionEnabled = true
    }
    
    func onTagClick(){
        var storyboard = UIStoryboard(name: "DreamTagViewController", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("DreamTagViewController") as DreamTagViewController
        viewController.dreamTagDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setDream(){
        self.field1!.resignFirstResponder()
        self.field2!.resignFirstResponder()
        
        self.setDreamActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.setDreamActionSheet!.addButtonWithTitle("设为公开")
        self.setDreamActionSheet!.addButtonWithTitle("设为私密")
        self.setDreamActionSheet!.addButtonWithTitle("取消")
        self.setDreamActionSheet!.cancelButtonIndex = 2
        self.setDreamActionSheet!.showInView(self.view)
        
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2!.resignFirstResponder()
    }
    
    func addDreamOK(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        var title = self.field1?.text
        var content = self.field2?.text
        title = SAEncode(SAHtml(title!))
        content = SAEncode(SAHtml(content!))
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content!)&&title=\(title!)&&img=\(self.uploadUrl)&&private=\(self.isPrivate)", "http://nian.so/api/add_query.php")
            if(sa == "1"){
                dispatch_async(dispatch_get_main_queue(), {
                    globalWillNianReload = 1
                    self.navigationController!.popViewControllerAnimated(true)
                })
            }
        })
    }
    
    func editDreamOK(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        var title = self.field1?.text
        var content = self.field2?.text
        title = SAEncode(SAHtml(title!))
        content = SAEncode(SAHtml(content!))
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("uid=\(safeuid)&&shell=\(safeshell)&&content=\(content!)&&title=\(title!)&&img=\(self.uploadUrl)&&private=\(self.editPrivate)&&id=\(self.editId)", "http://nian.so/api/editdream.php")
            if(sa == "1"){
                dispatch_async(dispatch_get_main_queue(), {
                    globalWillNianReload = 1
                    self.navigationController!.popViewControllerAnimated(true)
                })
            }
        })
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func onTagSelected(tag: String) {
        self.labelTag?.text = tag
    }
}
