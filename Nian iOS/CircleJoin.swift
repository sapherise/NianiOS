//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol circleAddDelegate {
    func SAReloadData()
    func addDream(tag:Int)
    func changeBtnMainText(content:String)
}

class CircleJoin: UIView, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var imageArrow: UIImageView!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var btnOK: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var viewTop: UIView!
    @IBOutlet var activityOK: UIActivityIndicatorView!
    var hashTag:Int = -2
    var keyboardHeight:CGFloat = 0
    var dataArray = NSMutableArray()
    var actionSheet:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var dreamID:String = "0"
    var thePrivate:String = ""
    var circleID:String = "0"
    var uploadWidth:String = ""
    var uploadHeight:String = ""
    var delegate: circleAddDelegate?
    
    override func awakeFromNib() {
        self.viewHolder.layer.cornerRadius = 4
        self.viewHolder.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06).CGColor
        self.viewHolder.layer.borderWidth = 1
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"AddStepCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "AddStepCell")
        self.viewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onViewTopClick"))
        self.textView.delegate = self
        self.btnOK.addTarget(self, action: "onSubmitClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.activityOK.hidden = true
        self.btnOK.enabled = false
    }
    
    override func layoutSubviews() {
        if self.thePrivate == "0" {
            self.btnOK.setTitle("加入梦境", forState: UIControlState.Normal)
        }else if self.thePrivate == "1" {
            self.btnOK.setTitle("提交验证", forState: UIControlState.Normal)
        }
        Api.getDreamTag(self.hashTag) { json in
            if json != nil {
                var arr = json!["items"] as! NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                if self.dataArray.count == 0 {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, 278, 200))
                    var viewQuestion = viewEmpty(278, content: "还没有梦想")
                    viewQuestion.setY(20)
                    var btnGo = UIButton()
                    btnGo.setButtonNice("创建一个")
                    btnGo.setX(278/2-50)
                    btnGo.setY(viewQuestion.bottom())
                    btnGo.tag = self.hashTag
                    btnGo.addTarget(self, action: "onBtnGoClick:", forControlEvents: UIControlEvents.TouchUpInside)
                    viewHeader.addSubview(viewQuestion)
                    viewHeader.addSubview(btnGo)
                    self.tableView.tableHeaderView = viewHeader
                }else{
                    self.tableView.tableHeaderView = UIView()
                }
                self.btnOK.enabled = true
                self.labelDream.text = "绑定梦想"
            }
        }
    }
    
    func onBtnGoClick(sender:UIButton){
        var tag = sender.tag
        delegate?.addDream(tag)
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
        var id = data!.objectForKey("id") as! String     //选中梦想的编号
        var title = data!.objectForKey("title") as! String     //选中梦想的编号
        var image = data!.objectForKey("img") as! String     //选中梦想的编号
        var userImageURL = "http://img.nian.so/dream/\(image)!dream"
        self.imageDream.setImage(userImageURL, placeHolder: IconColor, bool: false)
        self.labelDream.text = title
        self.labelDream.font = UIFont.systemFontOfSize(17)
        self.labelDream.textColor = UIColor.blackColor()
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
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.setY(globalHeight/2-106)
        })
    }
    
    func onSubmitClick(){
        var content = self.textView.text
        content = SAEncode(SAHtml(content))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        if self.dreamID != "0" {
            self.btnOK.setTitle("", forState: UIControlState.Normal)
            self.btnOK.enabled = false
            self.activityOK.hidden = false
            self.activityOK.startAnimating()
            Api.postCircleJoinDirectly(self.circleID, dream: self.dreamID, word: content) { json in
                if json != nil {
                    var success = json!["success"] as! String
                    var reason = json!["reason"] as! String
                    if success == "1" {
                        self.activityOK.stopAnimating()
                        self.activityOK.hidden = true
                        var textOK = ""
                        if self.thePrivate == "0" {
                            textOK = "加入好了！"
                            var title = json!["title"] as! String
                            var image = json!["img"] as! String
                            var postdate = json!["postdate"] as! String
                            SQLCircleListInsert(self.circleID, title, image, postdate)
                            self.delegate?.SAReloadData()
                        }else if self.thePrivate == "1" {
                            textOK = "发好验证了！"
                            self.delegate?.changeBtnMainText("等待验证中")
                        }
                        self.btnOK.setTitle(textOK, forState: UIControlState.Normal)
                        if let v = self.superview {
                            delay(1, { () -> () in
                                UIView.animateWithDuration(0.2, animations: { () -> Void in
                                    var newTransform = CGAffineTransformScale(v.transform, 1.2, 1.2)
                                    v.transform = newTransform
                                    v.alpha = 0
                                    }) { (Bool) -> Void in
                                        v.removeFromSuperview()
                                }
                            })
                        }
                    }else{
                        var textReason = ""
                        if reason == "1" {
                            textReason = "这个梦境不存在..."
                        }else if reason == "2" {
                            textReason = "梦境需要验证，取消后返回再重进试试！"
                        }else if reason == "3" {
                            textReason = "梦境满了..."
                        }else if reason == "4" {
                            textReason = "你已经在里面啦"
                        }else{
                            textReason = "奇怪的错误，代码是「\(reason)」"
                        }
                        self.activityOK.stopAnimating()
                        self.activityOK.hidden = true
                        self.btnOK.setTitle("加入梦境", forState: UIControlState.Normal)
                        self.btnOK.enabled = true
                        self.showTipText(textReason, delay: 2)
                    }
                }
            }
        }else{
            self.showTipText("还没绑定一个梦想", delay: 2)
        }
    }
}
