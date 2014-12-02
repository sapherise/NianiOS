//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class AddStep: UIView, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var imageArrow: UIImageView!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var btnUpload: UIButton!
    @IBOutlet var btnOK: UIButton!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var viewTop: UIView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var activityOK: UIActivityIndicatorView!
    @IBOutlet var imageUploaded: UIImageView!
    var keyboardHeight:CGFloat = 0
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    var dreamID:String = "0"
    
    var uploadWidth:String = ""
    var uploadHeight:String = ""
    
    override func awakeFromNib() {
        self.viewHolder.layer.cornerRadius = 4
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"AddStepCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "AddStepCell")
        self.viewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onViewTopClick"))
        self.textView.delegate = self
        self.btnUpload.addTarget(self, action: "onUploadClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnOK.addTarget(self, action: "onSubmitClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.activity.hidden = true
        self.activityOK.hidden = true
        self.imageUploaded.hidden = true
        self.btnOK.enabled = false
        
        Api.getDreamNewest() { json in
            if json != nil {
                var arr = json!["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                var data = self.dataArray[0] as NSDictionary
                var id = data.objectForKey("id") as String
                var title = data.objectForKey("title") as String
                var image = data.objectForKey("img") as String
                var userImageURL = "http://img.nian.so/dream/\(image)!dream"
                self.imageDream.setImage(userImageURL, placeHolder: IconColor, bool: false)
                self.dreamID = id
                self.labelDream.text = title
                self.btnOK.enabled = true
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier("AddStepCell", forIndexPath: indexPath) as AddStepCell
        var index = indexPath.row
        c.data = self.dataArray[index] as? NSDictionary
        cell = c
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index = indexPath.row
        var data = self.dataArray[index] as? NSDictionary
        var id = data!.objectForKey("id") as String     //选中梦想的编号
        var title = data!.objectForKey("title") as String     //选中梦想的编号
        var image = data!.objectForKey("img") as String     //选中梦想的编号
        var userImageURL = "http://img.nian.so/dream/\(image)!dream"
        self.imageDream.setImage(userImageURL, placeHolder: IconColor, bool: false)
        self.labelDream.text = title
        self.tableView.hidden = true
        self.dreamID = id
    }
    
    func onViewTopClick(){
        if self.tableView.hidden == false {
            self.tableView.hidden = true
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI ))
            })
        }else{
            self.tableView.hidden = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageArrow.transform = CGAffineTransformMakeRotation(CGFloat(0))
            })
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.frame.origin.y = 64+10
        })
        if self.textView.text == "进展正文" {
            self.textView.text = ""
            self.textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.setY(globalHeight/2-106)
        })
    }
    
    func onUploadClick(){
        self.textView.resignFirstResponder()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self)
    }
    
    func onSubmitClick(){
        var content = self.textView.text
        if content == "进展正文" {
            content = ""
        }
        self.btnOK.setTitle("", forState: UIControlState.Normal)
        self.btnOK.enabled = false
        self.activityOK.hidden = false
        self.activityOK.startAnimating()
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa=SAPost("dream=\(self.dreamID)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)&&img=\(self.uploadUrl)&&img0=\(self.uploadWidth)&&img1=\(self.uploadHeight)", "http://nian.so/api/addstep_query.php")
            if(sa == "1"){
                globalWillNianReload = 1
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityOK.stopAnimating()
                    self.activityOK.hidden = true
                    self.btnOK.setTitle("发送好了", forState: UIControlState.Normal)
                    var VC = self.findRootViewController() as HomeViewController
                    delay(1, { () -> () in
                        VC.onViewCloseClick()
                        var DreamVC = DreamViewController()
                        DreamVC.Id = self.dreamID
                        VC.navigationController!.pushViewController(DreamVC, animated: true)
                    })
                })
            }
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        var VC = findRootViewController()! as UIViewController
        if buttonIndex == 0 {
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            VC.presentViewController(self.imagePicker, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                VC.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        var VC = findRootViewController()! as UIViewController
//        VC.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadFile(img:UIImage){
        self.btnUpload.hidden = true
        self.activity.hidden = false
        self.activity.startAnimating()
        var uy = UpYun()
        uy.successBlocker = ({(uploadData:AnyObject!) in
            self.activity.hidden = true
            self.activity.stopAnimating()
            self.btnUpload.hidden = false
            self.imageUploaded.hidden = false
            self.imageUploaded.image = resizedImage(img, 150)
            self.imageUploaded.clipsToBounds = true
            self.textView.setWidth(208)
            self.uploadUrl = uploadData.objectForKey("url") as String
            var width: AnyObject? = uploadData.objectForKey("image-width")
            self.uploadWidth = "\(width!)"
            var height: AnyObject? = uploadData.objectForKey("image-height")
            self.uploadHeight = "\(height!)"
            self.uploadUrl = SAReplace(self.uploadUrl, "/step/", "") as String
        })
        uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("step", "png"))
    }
    
    func navHide(yPoint:CGFloat){
        var VC = self.findRootViewController() as HomeViewController
        var navigationFrame = VC.navigationController?.navigationBar.frame
        navigationFrame!.origin.y = yPoint
        VC.navigationController!.navigationBar.frame = navigationFrame!
    }
}

class AddStepCell: UITableViewCell {
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data:NSDictionary?
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var title:String = self.data!.objectForKey("title") as String
            var image:String = self.data!.objectForKey("img") as String
            var userImageURL = "http://img.nian.so/dream/\(image)!dream"
            self.labelTitle.text = title
            self.imageDream.setImage(userImageURL, placeHolder: IconColor, bool: false)
        }
    }
    override func awakeFromNib() {
        self.selectionStyle = .None
    }
    
    
}
