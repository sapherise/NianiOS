//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol MaskDelegate {
    func onViewCloseClick()
}

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
    
    var delegate: MaskDelegate?
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var uploadUrl:String = ""
    var dreamID:String = "0"
    var uploadWidth:String = ""
    var uploadHeight:String = ""
    var viewCoin:Popup!
    var animated: Bool = true
    var isfirst: String = ""
    
    var niAlert: NIAlert?
    var niCoinLessAlert: NIAlert?
    var confirmNiAlert: NIAlert?
    var lotteryNiAlert: NIAlert?
    
    var img1: UIButton!
    var img2: UIButton!
    var img3: UIButton!
    
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
                var arr = json!["items"] as! NSArray
                self.dataArray.removeAllObjects()
                
                for data : AnyObject in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                var data = self.dataArray[0] as! NSDictionary
                var id = data.objectForKey("id") as! String
                var title = data.objectForKey("title") as! String
                var image = data.objectForKey("img") as! String
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
        var c = tableView.dequeueReusableCellWithIdentifier("AddStepCell", forIndexPath: indexPath) as! AddStepCell
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
        var id = data!.objectForKey("id") as! String
        var title = data!.objectForKey("title") as! String
        var image = data!.objectForKey("img") as! String
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
        if self.textView.text == "进展正文" {
            self.textView.text = ""
            self.textView.textColor = UIColor.blackColor()
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.frame.origin.y = 64 + 10
        })
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text != "" && textView.text != "进展正文") || self.uploadUrl != "" {
            self.btnOK.setTitle("写好了", forState: UIControlState.allZeros)
        }else{
            self.btnOK.setTitle("签到", forState: UIControlState.allZeros)
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
        if self.textView.text == "进展正文" {
            self.textView.text = ""
        }
        var content = self.textView.text
        self.btnOK.setTitle("", forState: UIControlState.Normal)
        self.btnOK.enabled = false
        self.activityOK.hidden = false
        self.activityOK.startAnimating()
        content = SAEncode(SAHtml(content))
        Api.postAddStep(self.dreamID, content: content, img: self.uploadUrl, img0: self.uploadWidth, img1: self.uploadHeight) { json in
            if json != nil {
                self.textView.resignFirstResponder()
                var coin = json!["coin"] as! String
                var totalCoin = json!["totalCoin"] as! String
                self.isfirst = json!["isfirst"] as! String
                globalWillNianReload = 1
                
                //  创建卡片
                let modeCard = SACookie("modeCard")
                if modeCard == "0" {
                } else {
                    var card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
                    card.content = self.textView.text
                    card.widthImage = self.uploadWidth
                    card.heightImage = self.uploadHeight
                    card.url = self.uploadUrl
                    card.onCardSave()
                }
                
                if true {
                    globalWillNianReload = 1
                    
                    self.hidden = true
                    self.delegate?.onViewCloseClick()

                      // 根据念币数量来判断
                    if false {
                        self.niCoinLessAlert = NIAlert()
                        self.niCoinLessAlert!.delegate = self
                        self.niCoinLessAlert!.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "你获得了念币奖励", ["好"]],
                                                           forKeys: ["img", "title", "content", "buttonArray"])
                        
                        self.niCoinLessAlert!.showWithAnimation(showAnimationStyle.flip)
                    } else {
                        // 如果念币多于 3， 那么就出现抽宠物
                        self.niAlert = NIAlert()
                        self.niAlert!.delegate = self
                        self.niAlert!.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
                            forKeys: ["img", "title", "content", "buttonArray"])
                        
                        self.niAlert!.showWithAnimation(showAnimationStyle.flip)
                    }
                
                } else {
                    self.activityOK.stopAnimating()
                    self.activityOK.hidden = true
                    self.btnOK.setTitle("发送好了", forState: UIControlState.Normal)
                    delay(0.5, { () -> () in
                        self.delegate?.onViewCloseClick()
                        var DreamVC = DreamViewController()
                        DreamVC.Id = self.dreamID
                        self.findRootViewController()?.navigationController?.pushViewController(DreamVC, animated: true)
                    })
                }
            }
        }
    }
    
    func onCoinClick() {
        self.viewCoin.removeFromSuperview()
        self.delegate?.onViewCloseClick()
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var VC = findRootViewController()! as UIViewController
        if buttonIndex == 0 {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            VC.presentViewController(self.imagePicker, animated: true, completion: nil)
        }else if buttonIndex == 1 {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                VC.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
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
            self.imageUploaded.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageUploadedClick:"))
            self.imageUploaded.clipsToBounds = true
            self.textView.setWidth(208)
            self.uploadUrl = uploadData.objectForKey("url") as! String
            var width: AnyObject? = uploadData.objectForKey("image-width")
            self.uploadWidth = "\(width!)"
            var height: AnyObject? = uploadData.objectForKey("image-height")
            self.uploadHeight = "\(height!)"
            self.uploadUrl = SAReplace(self.uploadUrl, "/step/", "") as String
            setCacheImage("http://img.nian.so/step/\(self.uploadUrl)!large", img, 0)
        })
        uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("step", "png") as String)
    }
    
    func onImageUploadedClick(sender:UIGestureRecognizer) {
        if let v = sender.view as? UIImageView {
            var yPoint = v.convertPoint(CGPointMake(0, 0), fromView: v.window!)
            var w = CGFloat((self.uploadWidth as NSString).floatValue)
            var h = CGFloat((self.uploadHeight as NSString).floatValue)
            if w * h > 0 {
                if w > h {
                    h = 50 * h / w
                    w = 50
                }else{
                    w = 50 * w / h
                    h = 50
                }
            }
            var rect = CGRectMake(-yPoint.x, -yPoint.y, w, h)
            self.textView.resignFirstResponder()
            v.showImage("http://img.nian.so/step/\(self.uploadUrl)!large", rect: rect)
        }
    }
}

/**
*  AddStep 实现 NIAlertDelegate
*/
extension AddStep: NIAlertDelegate {
    func niAlert(niALert: NIAlert, didselectAtIndex: Int) {
        // 处理那些念币不足的丫们
        if niALert == self.niCoinLessAlert {
            if didselectAtIndex == 0 {
                niALert.dismissWithAnimation()
                self.delegate?.onViewCloseClick()
            }
        }
        // 处理 add step 之后询问要不要抽宠物的界面
        else if niALert == self.niAlert {
           
            // 改进，消失从外面控制
            niALert.dismissWithAnimation()
            
            // 先把用户点击 “不” 的情况处理了
            if didselectAtIndex == 1 {
                self.delegate?.onViewCloseClick()
            } else if didselectAtIndex == 0 {
                
                // 进入确认抽奖的界面
                self.confirmNiAlert = NIAlert()
                self.confirmNiAlert!.delegate = self
                self.confirmNiAlert!.dict = NSMutableDictionary(objects: ["", "抽蛋", "在上方随便选一个蛋！", []],
                                                          forKeys: ["img", "title", "content", "buttonArray"])
                
                img1 = setupEgg(40, named: "pet_egg1")
                img1.tag = 0
                img2 = setupEgg(104, named: "pet_egg2")
                img2.tag = 1
                img3 = setupEgg(168, named: "pet_egg3")
                img3.tag = 2
                self.confirmNiAlert?._containerView?.addSubview(img1)
                self.confirmNiAlert?._containerView?.addSubview(img2)
                self.confirmNiAlert?._containerView?.addSubview(img3)
                
                self.confirmNiAlert!.showWithAnimation(showAnimationStyle.flip)
            }
        }
        // 处理抽奖结果页面
        else if niALert == self.lotteryNiAlert {
            if didselectAtIndex == 0 {
                // 处理分享界面
                
                
                
            } else if didselectAtIndex == 1 {
                niALert.dismissWithAnimation()
                self.delegate?.onViewCloseClick()
            }
        }
    }
    
    func setupEgg(x: CGFloat, named: String) -> UIButton {
        var button = UIButton(frame: CGRectMake(x, 40, 64, 80))
        button.addTarget(self, action: "onEggTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        button.addTarget(self, action: "onEggTouchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "onEggTouchCancel:", forControlEvents: UIControlEvents.TouchDragOutside)
        button.setBackgroundImage(UIImage(named: named), forState: UIControlState.allZeros)
        button.setBackgroundImage(UIImage(named: named), forState: UIControlState.Highlighted)
        button.layer.cornerRadius = 8
        return button
    }
    
    func onEggTouchDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    func onEggTouchCancel(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor()
    }
    
    func onEggTouchUp(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor()
        self.confirmNiAlert?.titleLabel?.hidden = true
        self.confirmNiAlert?.contentLabel?.hidden = true
        var v = img1
        if sender.tag == 1 {
            v = img2
            img1.hidden = true
            img3.hidden = true
        } else if sender.tag == 2 {
            v = img3
            img1.hidden = true
            img2.hidden = true
        } else {
            img2.hidden = true
            img3.hidden = true
        }
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            v.setX(104)
        })
        var ac = UIActivityIndicatorView(frame: CGRectMake(121, 150, 30, 30))
        ac.color = SeaColor
        ac.hidden = false
        ac.startAnimating()
        self.confirmNiAlert?._containerView!.addSubview(ac)
        Api.postPetLottery() { json in
            if json != nil {
                let err = json!["error"] as! NSNumber
                if err == 0 {
                    self.confirmNiAlert?.removeFromSuperview()
                    let petInfo = (json!["data"] as! NSDictionary).objectForKey("pet") as! NSDictionary
                    let petName = petInfo.stringAttributeForKey("name")
                    let petImage = petInfo.stringAttributeForKey("image")
                    self.lotteryNiAlert = NIAlert()
                    self.lotteryNiAlert!.delegate = self
                    self.lotteryNiAlert!.dict = NSMutableDictionary(objects: ["http://img.nian.so/pets/\(petImage)", petName, "你获得了一个\(petName)", ["分享", "好"]],
                        forKeys: ["img", "title", "content", "buttonArray"])
                    self.lotteryNiAlert!.showWithAnimation(showAnimationStyle.spring)
                }
            }
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        self.delegate?.onViewCloseClick()
    }
}


class AddStepCell: UITableViewCell {
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data:NSDictionary?
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var title:String = self.data!.objectForKey("title") as! String
            var image:String = self.data!.objectForKey("img") as! String
            var userImageURL = "http://img.nian.so/dream/\(image)!dream"
            self.labelTitle.text = title
            self.imageDream.setImage(userImageURL, placeHolder: IconColor, bool: false)
        }
    }
    override func awakeFromNib() {
        self.selectionStyle = .None
    }
    
    
}
