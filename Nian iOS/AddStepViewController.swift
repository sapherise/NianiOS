//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

@objc protocol AddstepDelegate {   //😍
    func Editstep()
    optional func countUp(coin: String, isfirst: String)
    optional func countUp(coin: String, total: String, isfirst: String)
    var editStepRow:Int { get set }
    var editStepData:NSDictionary? { get set }
}

class AddStepViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var uploadWait: UIActivityIndicatorView!
    @IBOutlet var uploadDone: UIImageView!
    @IBOutlet var TextView:UITextView!
    @IBOutlet var viewHolder: UIView!
    
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
    var keyboardHeight:CGFloat = 0
    
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
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
            self.uploadUrl = uploadData.objectForKey("url") as! String
            var width: AnyObject? = uploadData.objectForKey("image-width")
            self.uploadWidth = "\(width!)"
            var height: AnyObject? = uploadData.objectForKey("image-height")
            self.uploadHeight = "\(height!)"
            self.uploadUrl = SAReplace(self.uploadUrl, "/step/", "") as String
            setCacheImage("http://img.nian.so/step/\(self.uploadUrl)!large", img, 0)
        })
        uy.failBlocker = ({(error:NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.uploadDone!.hidden = true
        })
        uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("step", "png") as String)
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.uploadWait.hidden = true
        self.view.backgroundColor = UIColor.whiteColor()
        self.viewHolder.setY(globalHeight-50)
        
        self.uploadWait!.hidden = true
        self.uploadDone!.hidden = true
        self.TextView.setWidth(globalWidth-20)
        self.viewHolder.setWidth(globalWidth)
        
        if self.isEdit == 1 {
            self.Id = self.data!.objectForKey("sid") as! String
            self.TextView.text =  SADecode(self.data!.stringAttributeForKey("content"))
            
            self.uploadUrl = self.data!.stringAttributeForKey("image")
            self.uploadWidth = self.data!.stringAttributeForKey("width")
            self.uploadHeight = self.data!.stringAttributeForKey("height")
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editStep")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }else{
            var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStep")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        if self.isEdit == 1 {
            titleLabel.text = "编辑进展！"
        }else{
            titleLabel.text = "新进展！"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        self.viewBack()
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
        Api.postAddStep(self.Id, content: content, img: self.uploadUrl, img0: self.uploadWidth, img1: self.uploadHeight) { json in
            if json != nil {
                globalWillNianReload = 1
                var coin = json!.objectForKey("coin") as! String
                var isfirst = json!.objectForKey("isfirst") as! String
                var totalCoin = json!.objectForKey("totalCoin") as! String
                self.navigationController?.popViewControllerAnimated(true)
                
                //  创建卡片
                let modeCard = SACookie("modeCard")
                if modeCard == "0" {
                } else {
                    var card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
                    card.content = self.TextView.text
                    card.widthImage = self.uploadWidth
                    card.heightImage = self.uploadHeight
                    card.url = self.uploadUrl
                    card.onCardSave()
                }
                //
                self.delegate?.countUp!(coin, total: totalCoin, isfirst: isfirst)
            }
        }
    }
    
    func editStep(){
        self.navigationItem.rightBarButtonItems = buttonArray()
        var content = self.TextView.text
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa=SAPost("sid=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)&&img=\(self.uploadUrl)&&img0=\(self.uploadWidth)&&img1=\(self.uploadHeight)", "http://nian.so/api/editstep_query.php")
            if(sa == "1"){
                globalWillNianReload = 1
                dispatch_async(dispatch_get_main_queue(), {
                    if self.data != nil {
                        var mutableData = NSMutableDictionary(dictionary: self.data!)
                        mutableData.setValue(self.TextView.text, forKey: "content")
                        mutableData.setValue(self.uploadUrl, forKey: "image")
                        mutableData.setValue(self.uploadWidth, forKey: "width")
                        mutableData.setValue(self.uploadHeight, forKey: "height")
                        self.delegate?.editStepRow = self.row
                        self.delegate?.editStepData = mutableData
                        self.delegate?.Editstep()
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            }
        })
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        var keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size)!
        self.keyboardHeight = keyboardSize.height
        self.viewHolder.setY(globalHeight-50-self.keyboardHeight)
        var textHeight = globalHeight-self.keyboardHeight-50-64-20
        if textHeight > 0 {
            self.TextView.setHeight(textHeight)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        self.viewHolder.setY(globalHeight-50)
        self.TextView.setHeight(globalHeight-50-64-20)
    }
    
    override func viewWillDisappear(animated: Bool) {
        keyboardEndObserve()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.TextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
}

extension UIViewController {
    func keyboardStartObserve() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func keyboardEndObserve() {
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }
}
