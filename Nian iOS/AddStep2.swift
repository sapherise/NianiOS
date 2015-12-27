//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import SpriteKit

protocol MaskDelegate {
    func onViewCloseClick()
    func onShare(avc: UIActivityViewController)
}

//class AddStep: UIView, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ShareDelegate, NIAlertDelegate{
//    @IBOutlet var imageDream: UIImageView!
//    @IBOutlet var imageArrow: UIImageView!
//    @IBOutlet var labelDream: UILabel!
//    @IBOutlet var textView: SZTextView!
//    @IBOutlet var btnUpload: UIButton!
//    @IBOutlet var btnOK: UIButton!
//    @IBOutlet var viewHolder: UIView!
//    @IBOutlet var tableView: UITableView!
//    @IBOutlet var viewTop: UIView!
//    @IBOutlet var activity: UIActivityIndicatorView!
//    @IBOutlet var activityOK: UIActivityIndicatorView!
//    @IBOutlet var imageUploaded: UIImageView!
//    
//    var delegate: MaskDelegate?
//    var dataArray = NSMutableArray()
//    var actionSheet:UIActionSheet!
//    var imagePicker:UIImagePickerController!
//    var uploadUrl:String = ""
//    var dreamID:String = "0"
//    var uploadWidth:String = ""
//    var uploadHeight:String = ""
//    var viewCoin:Popup!
//    var animated: Bool = true
//    var isfirst: String = ""
//    
//    var niCoinLessAlert: NIAlert?
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        self.viewHolder.layer.cornerRadius = 4
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        
//        let nib = UINib(nibName:"AddStepCell", bundle: nil)
//        self.tableView.registerNib(nib, forCellReuseIdentifier: "AddStepCell")
//        self.viewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onViewTopClick"))
//        self.textView.delegate = self
//        self.btnUpload.addTarget(self, action: "onUploadClick", forControlEvents: UIControlEvents.TouchUpInside)
//        self.btnOK.addTarget(self, action: "onSubmitClick", forControlEvents: UIControlEvents.TouchUpInside)
//        self.activity.hidden = true
//        self.activityOK.hidden = true
//        self.imageUploaded.hidden = true
//        self.btnOK.enabled = false
//        self.textView.attributedPlaceholder = NSAttributedString(string: "进展正文" ,
//                                                                attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
//                                                                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
//        
////        DreamNewest
//        
//        if let NianDreams = Cookies.get("NianDreams") as? NSMutableArray {
//            self.dataArray = NianDreams
//            self.tableView!.reloadData()
////            let data = self.dataArray[0] as! NSDictionary
//            var count = 0
//            for d in dataArray {
//                let id = (d as! NSDictionary).stringAttributeForKey("id")
//                if id == Cookies.get("DreamNewest") as? String {
//                    let data = d
//                    let title = data.objectForKey("title") as! String
//                    let image = data.objectForKey("img") as! String
//                    let userImageURL = "http://img.nian.so/dream/\(image)!dream"
//                    self.imageDream.setImage(userImageURL)
//                    self.dreamID = id
//                    self.labelDream.text = title
//                    self.btnOK.enabled = true
//                    count = 1
//                }
//            }
//            if count == 0 {
//                let data = dataArray[0] as! NSDictionary
//                let id = data.stringAttributeForKey("id")
//                let title = data.stringAttributeForKey("title")
//                let image = data.stringAttributeForKey("img")
//                let userImageURL = "http://img.nian.so/dream/\(image)!dream"
//                self.imageDream.setImage(userImageURL)
//                self.dreamID = id
//                self.labelDream.text = title
//                self.btnOK.enabled = true
//            }
//        }
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell:UITableViewCell
//        let c = tableView.dequeueReusableCellWithIdentifier("AddStepCell", forIndexPath: indexPath) as! AddStepCell
//        let index = indexPath.row
//        c.data = self.dataArray[index] as? NSDictionary
//        cell = c
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 54
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.dataArray.count
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let index = indexPath.row
//        let data = self.dataArray[index] as? NSDictionary
//        let id = data!.objectForKey("id") as! String
//        let title = data!.objectForKey("title") as! String
//        let image = data!.objectForKey("img") as! String
//        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
//        self.imageDream.setImage(userImageURL)
//        self.labelDream.text = title
//        self.tableView.hidden = true
//        self.dreamID = id
//    }
//    
//    func onViewTopClick(){
//        if self.tableView.hidden == false {
//            self.tableView.hidden = true
//            UIView.animateWithDuration(0.3, animations: { () -> Void in
//                self.imageArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI ))
//            })
//        }else{
//            self.tableView.hidden = false
//            UIView.animateWithDuration(0.3, animations: { () -> Void in
//                self.imageArrow.transform = CGAffineTransformMakeRotation(CGFloat(0))
//            })
//        }
//    }
//    
//    func textViewDidBeginEditing(textView: UITextView) {
//        if self.textView.text == "进展正文" {
//            self.textView.text = ""
//            self.textView.textColor = UIColor.blackColor()
//        }
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.frame.origin.y = 64 + 10
//        })
//    }
//    
//    func textViewDidChange(textView: UITextView) {
//        if (textView.text != "" && textView.text != "进展正文") || self.uploadUrl != "" {
//            self.btnOK.setTitle("写好了", forState: UIControlState())
//        }else{
//            self.btnOK.setTitle("签到", forState: UIControlState())
//        }
//    }
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.setY(globalHeight/2-106)
//        })
//    }
//    
//    func onUploadClick(){
//        self.textView.resignFirstResponder()
//        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
//        self.actionSheet!.addButtonWithTitle("相册")
//        self.actionSheet!.addButtonWithTitle("拍照")
//        self.actionSheet!.addButtonWithTitle("取消")
//        self.actionSheet!.cancelButtonIndex = 2
//        self.actionSheet!.showInView(self)
//    }
//    
//    func onShare(avc: UIActivityViewController) {
//        delegate?.onShare(avc)
//    }
//    
//    func onSubmitClick(){
//        if self.textView.text == "进展正文" {
//            self.textView.text = ""
//        }
//        let content = self.textView.text
//        self.btnOK.setTitle("", forState: UIControlState.Normal)
//        self.btnOK.enabled = false
//        self.activityOK.hidden = false
//        self.activityOK.startAnimating()
////        content = SAEncode(SAHtml(content))
//        Api.postAddStep_AFN(self.dreamID, content: content, img: self.uploadUrl, img0: self.uploadWidth, img1: self.uploadHeight) { json in
//            if json != nil {
//                self.textView.resignFirstResponder()
//                let data = json!.objectForKey("data") as! NSDictionary
//                let coin = data.objectForKey("coin") as! String
//                let totalCoin = data.objectForKey("totalCoin") as! String
//                self.isfirst = data.objectForKey("isfirst") as! String
//                
//                
//                globalWillNianReload = 1
//                
//                //  创建卡片
//                let modeCard = SACookie("modeCard")
//                if modeCard == "off" {
//                } else {
//                    let card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
//                    card.content = self.textView.text
//                    card.widthImage = self.uploadWidth
//                    card.heightImage = self.uploadHeight
//                    card.url = "http://img.nian.so/step/\(self.uploadUrl)!large"
//                    card.onCardSave()
//                }
//                
//                if self.isfirst == "1" {
//                    globalWillNianReload = 1
//                    
//                    self.hidden = true
//                    self.delegate?.onViewCloseClick()
//
//                      // 如果念币小于 3
//                    if Int(totalCoin) < 3 {
//                        self.niCoinLessAlert = NIAlert()
//                        self.niCoinLessAlert?.delegate = self
//                        self.niCoinLessAlert?.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "你获得了念币奖励", ["好"]],
//                                                        forKeys: ["img", "title", "content", "buttonArray"])
//                        self.niCoinLessAlert?.showWithAnimation(.flip)
//                    } else {
//                        // 如果念币多于 3， 那么就出现抽宠物
//                        let v = SAEgg()
//                        v.delegateShare = self
//                        v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
//                            forKeys: ["img", "title", "content", "buttonArray"])
//                        v.showWithAnimation(.flip)
//                    }
//                    
//                } else {
//                    self.activityOK.stopAnimating()
//                    self.activityOK.hidden = true
//                    self.btnOK.setTitle("发送好了", forState: UIControlState.Normal)
//                    delay(0.5, closure: { () -> () in
//                        self.delegate?.onViewCloseClick()
//                        let DreamVC = DreamViewController()
//                        DreamVC.Id = self.dreamID
//                        self.findRootViewController()?.navigationController?.pushViewController(DreamVC, animated: true)
//                    })
//                }
//            }
//        }
//    }
//    
//    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
//        if niAlert == self.niCoinLessAlert {
//            niAlert.dismissWithAnimation(.normal)
//        } else {
//            
//        }
//    }
//    
//    func onCoinClick() {
//        self.viewCoin.removeFromSuperview()
//        self.delegate?.onViewCloseClick()
//    }
//    
//    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
//        let VC = findRootViewController()! as UIViewController
//        if buttonIndex == 0 {
//            self.imagePicker = UIImagePickerController()
//            self.imagePicker.delegate = self
//            self.imagePicker.allowsEditing = false
//            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            VC.presentViewController(self.imagePicker, animated: true, completion: nil)
//        }else if buttonIndex == 1 {
//            self.imagePicker = UIImagePickerController()
//            self.imagePicker.delegate = self
//            self.imagePicker.allowsEditing = false
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
//                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
//                VC.presentViewController(self.imagePicker, animated: true, completion: nil)
//            }
//        }
//    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        self.uploadFile(image)
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func uploadFile(img:UIImage){
//        self.btnUpload.hidden = true
//        self.activity.hidden = false
//        self.activity.startAnimating()
//        let uy = UpYun()
//        uy.successBlocker = ({(uploadData:AnyObject!) in
//            self.activity.hidden = true
//            self.activity.stopAnimating()
//            self.btnUpload.hidden = false
//            self.imageUploaded.hidden = false
//            self.imageUploaded.image = resizedImage(img, newWidth: 150)
//            self.imageUploaded.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageUploadedClick:"))
//            self.imageUploaded.clipsToBounds = true
//            self.textView.setWidth(208)
//            self.uploadUrl = uploadData.objectForKey("url") as! String
//            let width: AnyObject? = uploadData.objectForKey("image-width")
//            self.uploadWidth = "\(width!)"
//            let height: AnyObject? = uploadData.objectForKey("image-height")
//            self.uploadHeight = "\(height!)"
//            self.uploadUrl = SAReplace(self.uploadUrl, before: "/step/", after: "") as String
//            setCacheImage("http://img.nian.so/step/\(self.uploadUrl)!large", img: img, width: (globalWidth - 40) * globalScale)
//        })
//        uy.uploadImage(resizedImage(img, newWidth: 500), savekey: getSaveKey("step", png: "png") as String)
//    }
//    
//    func onImageUploadedClick(sender:UIGestureRecognizer) {
//        if let v = sender.view as? UIImageView {
//            self.textView.resignFirstResponder()
//            v.showImage("http://img.nian.so/step/\(self.uploadUrl)!large")
//        }
//    }
//}


class AddStepCell: UITableViewCell {
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data:NSDictionary?
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let title:String = self.data!.objectForKey("title") as! String
            let image:String = self.data!.objectForKey("img") as! String
            let userImageURL = "http://img.nian.so/dream/\(image)!dream"
            self.labelTitle.text = title
            self.imageDream.setImage(userImageURL)
        }
    }
    override func awakeFromNib() {
        self.selectionStyle = .None
    }
    
    
}

extension NIAlert {
    func evolution(url: String) {
//        var _tmpImg = self.imgView?.image!
        
        UIView.animateWithDuration(0.7, animations: {
            self.imgView!.setScale(0.8)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.15, animations: {
                    self.imgView!.setScale(0.75)
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.15, animations: {
                            self.imgView!.setScale(0.8)
                            }, completion: { (Bool) -> Void in
                                UIView.animateWithDuration(0.15, animations: {
                                    self.imgView!.setScale(0.75)
                                    }, completion: { (Bool) -> Void in
                                        UIView.animateWithDuration(0.15, animations: {
                                            self.imgView!.setScale(0.8)
                                            }, completion: { (Bool) -> Void in
                                                UIView.animateWithDuration(0.15, animations: {
                                                    self.imgView!.setScale(0.75)
                                                    }, completion: { (Bool) -> Void in
                                                        UIView.animateWithDuration(0.2, animations: {
                                                            self.imgView!.setScale(1.15)
                                                            }, completion: { (Bool) -> Void in
                                                                self.imgView?.image = nil
                                                                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                                                                    let skView = SKView(frame: CGRectMake(0, 0, 272, 108))
                                                                    if #available(iOS 8.0, *) {
                                                                        skView.allowsTransparency = true
                                                                    }
                                                                    self._containerView!.addSubview(skView)
                                                                    scene.scaleMode = SKSceneScaleMode.AspectFit
                                                                    skView.presentScene(scene)
                                                                    scene.setupViews()
                                                                    self._containerView?.sendSubviewToBack(skView)
                                                                }
                                                                delay(0.1, closure: {
                                                                    self.imgView!.setScale(1.35)
                                                                    self.imgView?.alpha = 0
                                                                    self.imgView?.setPet("http://img.nian.so/pets/\(url)!d")
                                                                    UIView.animateWithDuration(0.1, animations: {
                                                                        self.imgView?.alpha = 1
                                                                        self.imgView!.setScale(1.55)
                                                                        }, completion: { (Bool) -> Void in
                                                                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                                                                self.imgView!.setScale(1.2)
                                                                            })
                                                                            UIView.animateWithDuration(1, delay: 1, options: UIViewAnimationOptions(), animations: {
                                                                                self.imgView!.setScale(1)
                                                                                }, completion: { (Bool) -> Void in
                                                                            })
                                                                    })
                                                                })
                                                        })
                                                })
                                        })
                                })
                        })
                })
        })
    }
}

extension UIView {
    func setScale(x: CGFloat) {
        self.transform = CGAffineTransformMakeScale(x, x)
    }
}
