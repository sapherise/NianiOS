//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol AddstepDelegate {   //😍
    func Editstep()
    func countUp()
    var editStepRow:Int { get set }
    var editStepData:NSDictionary? { get set }
}

class AddStepViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var uploadWait: UIActivityIndicatorView!
    @IBOutlet var uploadDone: UIImageView!
    @IBOutlet var TextView:UITextView!
    @IBOutlet var Line: UIView!
    var Id:String = ""
    var delegate: AddstepDelegate?      //😍
    var actionSheet:UIActionSheet?
    var imagePicker:UIImagePickerController?
    var uploadUrl:String = ""
    var uploadWidth:String = ""
    var uploadHeight:String = ""
    var data :NSDictionary?
    var isEdit:Int = 0
    var row:Int = 0
    
    @IBAction func uploadClick(sender: AnyObject) {
        self.TextView!.resignFirstResponder()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
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
        uy.successBlocker = ({(uploadData:AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = false
            self.uploadUrl = uploadData.objectForKey("url") as String
            var width: AnyObject? = uploadData.objectForKey("image-width")
            self.uploadWidth = "\(width!)"
            var height: AnyObject? = uploadData.objectForKey("image-height")
            self.uploadHeight = "\(height!)"
            self.uploadUrl = SAReplace(self.uploadUrl, "/step/", "") as String
        })
        uy.failBlocker = ({(error:NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = true
        })
        uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("step", "png"))
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.uploadWait.hidden = true
        self.view.backgroundColor = BGColor
        self.TextView.backgroundColor = BGColor
        self.Line.backgroundColor = LineColor
        
        self.uploadWait!.hidden = true
        self.uploadDone!.hidden = true
        
        if self.isEdit == 1 {
            self.Id = self.data!.objectForKey("sid") as String
            self.TextView.text =  self.data!.objectForKey("content") as String
            
            self.uploadUrl = self.data!.objectForKey("img") as String
            self.uploadWidth = self.data!.objectForKey("img0") as String
            self.uploadHeight = self.data!.objectForKey("img1") as String
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editStep")
            rightButton.image = UIImage(named:"ok")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }else{
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStep")
            rightButton.image = UIImage(named:"ok")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.TextView.becomeFirstResponder()
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        })
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        if self.isEdit == 1 {
            titleLabel.text = "编辑进展！"
        }else{
            titleLabel.text = "新进展！"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
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
    
    func addStep(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        var sa=SAPost("dream=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)&&img=\(self.uploadUrl)&&img0=\(self.uploadWidth)&&img1=\(self.uploadHeight)", "http://nian.so/api/addstep_query.php")
            if(sa == "1"){
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController!.popViewControllerAnimated(true)
                    self.delegate?.countUp()
                })
        }
        })
    }
    
    func editStep(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa=SAPost("sid=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)&&img=\(self.uploadUrl)&&img0=\(self.uploadWidth)&&img1=\(self.uploadHeight)", "http://nian.so/api/editstep_query.php")
            if(sa == "1"){
                dispatch_async(dispatch_get_main_queue(), {
                    self.data!.setValue(self.TextView.text, forKey: "content")
                    self.data!.setValue(self.uploadUrl, forKey: "img")
                    self.data!.setValue(self.uploadWidth, forKey: "img0")
                    self.data!.setValue(self.uploadHeight, forKey: "img1")
                    self.delegate?.editStepRow = self.row
                    self.delegate?.editStepData = self.data!
                    self.delegate?.Editstep()
                    self.navigationController!.popViewControllerAnimated(true)
                })
            }
        })
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
