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
class AddDreamController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var Line1: UIView?
    @IBOutlet var Line2: UIView?
    @IBOutlet var uploadButton: UIButton?
    @IBOutlet var uploadWait: UIActivityIndicatorView?
    @IBOutlet var uploadDone: UIImageView?
    @IBOutlet var field1:UITextField?
    @IBOutlet var field2:UITextField?
    var actionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    var delegate: AddDelegate?      //😍
    
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
        if buttonIndex == 0 {
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func getSaveKey() -> NSString{
        var date = NSDate().timeIntervalSince1970
        var string = NSString.stringWithString("/test/\(Int(date)).png")
        return string
    }
    
    func uploadFile(img:UIImage){
        self.uploadWait!.hidden = false
        self.uploadWait!.startAnimating()
        self.uploadDone!.hidden = true
        var uy = UpYun()
        var data:AnyObject
        uy.successBlocker = ({(data:AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = false
            println(data)
        })
        uy.failBlocker = ({(error:NSError!) in
            println("失败了！")
        })
      //  var finalImage = resizedImage(img)
        var finalImage = resizedImage(img, 200)
        uy.uploadImage(finalImage, savekey: self.getSaveKey())
    }
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupViews(){
        self.Line1!.backgroundColor = LineColor
        self.Line2!.backgroundColor = LineColor
        self.field1!.textColor = IconColor
        self.field2!.textColor = IconColor
        self.field1!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        self.field2!.setValue(IconColor, forKeyPath: "_placeholderLabel.textColor")
        self.field1!.becomeFirstResponder()
        
        self.uploadWait!.hidden = true
        self.uploadDone!.hidden = true
        
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
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.field1!.resignFirstResponder()
        self.field2!.resignFirstResponder()
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
    
    override func viewDidAppear(animated: Bool) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker!.delegate = self
        self.imagePicker!.allowsEditing = false
    }
    
    
    
    
    
}
