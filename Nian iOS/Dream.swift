//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamViewController: VVeboViewController, UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, editDreamDelegate, topDelegate, ShareDelegate {
    
    var page: Int = 1
    var Id: String = "1"
    var deleteDreamSheet:UIActionSheet?
    var navView:UIView!
    var viewCoin: Popup!
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    var dataArrayTop: NSDictionary!
    var btnMain: UIButton!
    
    var alertCoin: NIAlert?
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SATableView.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    //
    
    func setupViews() {
        self.viewBack()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.SATableView = VVeboTableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.SATableView.delegate = self
        self.SATableView.dataSource = self
        self.SATableView.touchDelegate = self
        
        let nib = UINib(nibName:"DreamCell", bundle: nil)
        let nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        
        self.SATableView.registerNib(nib, forCellReuseIdentifier: "dream")
        self.SATableView.registerNib(nib2, forCellReuseIdentifier: "dreamtop")
        self.SATableView.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        self.view.addSubview(self.SATableView)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
    }
    
    func load(clear: Bool = true){
        if clear {
            self.page = 1
        }
        Api.getDreamStep(Id, page: page) { json in
            if json != nil {
                if json!.objectForKey("error") as! NSNumber != 0 {
                    let status = json!.objectForKey("status") as! NSNumber
                    self.SATableView.hidden = true
                    self.navigationItem.rightBarButtonItems = []
                    if status == 404 {
                        self.view.addGhost("这个记本\n不见了")
                    } else if status == 403 {
                        self.view.addGhost("你发现了\n一个私密的记本\n里面记着什么？")
                    } else {
                        self.view.showTipText("遇到了一个奇怪的错误，代码是 \(status)", delay: 2)
                    }
                } else {
                    let data: AnyObject? = json!.objectForKey("data")
                    if clear {
                        self.dataArrayTop = data!.objectForKey("dream") as! NSDictionary
                        self.dataArray.removeAllObjects()
                        let btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "setupNavBtn")
                        btnMore.image = UIImage(named: "more")
                        self.navigationItem.rightBarButtonItems = [btnMore]
                    }
                    let steps = data!.objectForKey("steps") as! NSArray
                    for d in steps {
                        let data = SACell.SACellDataRecode(d as! NSDictionary)
                        self.dataArray.addObject(data)
                    }
                    self.SATableView.reloadData()
                    self.SATableView.headerEndRefreshing()
                    self.SATableView.footerEndRefreshing()
                    self.page++
                }
            }
        }
    }
    
    func setupNavBtn() {
        let uid = dataArrayTop.stringAttributeForKey("uid")
        let percent = dataArrayTop.stringAttributeForKey("percent")
        let title = dataArrayTop.stringAttributeForKey("title")
        let isLiked = dataArrayTop.stringAttributeForKey("isliked")
        
        let acEdit = SAActivity()
        acEdit.saActivityTitle = "编辑"
        acEdit.saActivityType = "编辑"
        acEdit.saActivityImage = UIImage(named: "av_edit")
        acEdit.saActivityFunction = {
            self.editMyDream()
        }
        
        let acDone = SAActivity()
        acDone.saActivityTitle = percent == "0" ? "完成" : "未完成"
        let percentNew = percent == "0" ? "1" : "0"
        let imageNew = percent == "0" ? "av_finish" : "av_nofinish"
        acDone.saActivityType = "完成"
        acDone.saActivityImage = UIImage(named: imageNew)
        acDone.saActivityFunction = {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(percentNew, forKey: "percent")
            self.dataArrayTop = mutableData
            self.SATableView.reloadData()
            Api.postCompleteDream(self.Id, percent: percentNew) { string in
            }
        }
        
        let acDelete = SAActivity()
        acDelete.saActivityTitle = "删除"
        acDelete.saActivityType = "删除"
        acDelete.saActivityImage = UIImage(named: "av_delete")
        acDelete.saActivityFunction = {
            self.deleteDreamSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.deleteDreamSheet!.addButtonWithTitle("确定删除")
            self.deleteDreamSheet!.addButtonWithTitle("取消")
            self.deleteDreamSheet!.cancelButtonIndex = 1
            self.deleteDreamSheet!.showInView(self.view)
        }
        
        let acLike = SAActivity()
        acLike.saActivityTitle = isLiked == "0" ? "赞" : "取消赞"
        let isLikedNew = isLiked == "0" ? "1" : "0"
        acLike.saActivityType = "赞"
        acLike.saActivityImage = UIImage(named: "av_like")
        acLike.saActivityFunction = {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(isLikedNew, forKey: "isliked")
            self.dataArrayTop = mutableData
            self.SATableView.reloadData()
            Api.postLikeDream(self.Id, like: isLikedNew) { string in }
        }
        
        let acReport = SAActivity()
        acReport.saActivityTitle = "举报"
        acReport.saActivityType = "举报"
        acReport.saActivityImage = UIImage(named: "av_report")
        acReport.saActivityFunction = {
            self.view.showTipText("举报好了！", delay: 2)
        }
        
        let arr = SAUid() == uid ? [acDone, acEdit, acDelete] : [acLike, acReport]
        let avc = SAActivityViewController.shareSheetInView(["「\(title)」- 来自念", NSURL(string: "http://nian.so/m/dream/\(self.Id)")!], applicationActivities: arr)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func onStep(){
        if dataArrayTop != nil {
            var title = dataArrayTop.stringAttributeForKey("title").decode()
            if dataArrayTop.stringAttributeForKey("private") == "1" {
                title = "\(title)（私密）"
            } else if dataArrayTop.stringAttributeForKey("percent") == "1" {
                title = "\(title)（完成）"
            }
            UIView.animateWithDuration(0.3, animations: {
                self.SATableView.contentOffset.y = title.stringHeightBoldWith(18, width: 240) + 252 + 52
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("dreamtop", forIndexPath: indexPath) as! DreamCellTop
            c.data = dataArrayTop
            c.delegate = self
            if dataArrayTop != nil {
                let uid = dataArrayTop.stringAttributeForKey("uid")
                let follow = dataArrayTop.stringAttributeForKey("follow")
                c.numMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onStep"))
                if SAUid() == uid {
                    c.btnMain.addTarget(self, action: "onAddStep", forControlEvents: UIControlEvents.TouchUpInside)
                    c.btnMain.setTitle("更新", forState: UIControlState())
                } else {
                    self.btnMain = c.btnMain
                    if follow == "0" {
                        c.btnMain.setTitle("关注", forState: UIControlState())
                        c.btnMain.addTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
                    } else {
                        c.btnMain.setTitle("已关注", forState: UIControlState())
                        c.btnMain.addTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                }
            }
            return c
        } else {
            return getCell(indexPath)
        }
    }
    
    // MARK: - 分割线 ---------------------------------------------------------
    
    func onFo() {
        btnMain.setTitle("已关注", forState: UIControlState())
        btnMain.removeTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
        btnMain.addTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
        let id = dataArrayTop.stringAttributeForKey("id")
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue("1", forKey: "follow")
        dataArrayTop = mutableData
        Api.postFollowDream(id, follow: "1") { string in }
    }
    
    func onUnFo() {
        btnMain.setTitle("关注", forState: UIControlState())
        btnMain.removeTarget(self, action: "onUnFo", forControlEvents: UIControlEvents.TouchUpInside)
        btnMain.addTarget(self, action: "onFo", forControlEvents: UIControlEvents.TouchUpInside)
        let id = dataArrayTop.stringAttributeForKey("id")
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue("0", forKey: "follow")
        dataArrayTop = mutableData
        Api.postFollowDream(id, follow: "0") { string in }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if dataArrayTop != nil {
                var title = dataArrayTop.stringAttributeForKey("title").decode()
                if dataArrayTop.stringAttributeForKey("private") == "1" {
                    title = "\(title)（私密）"
                } else if dataArrayTop.stringAttributeForKey("percent") == "1" {
                    title = "\(title)（完成）"
                }
                return title.stringHeightBoldWith(18, width: 240) + 252 + 52
            }
            return 0
        }else{
            return getHeight(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func onAddStep(){
        let vc = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        vc.Id = self.Id
        vc.delegate = self    //😍
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - add step delegate
    func update(data: NSDictionary) {
        if let step = Int(dataArrayTop.stringAttributeForKey("step")) {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue("\(step + 1)", forKey: "step")
            dataArrayTop = mutableData
            dataArray.insertObject(data, atIndex: 0)
            for c in SATableView.visibleCells {
                if let cell = c as? SACell {
                    cell.clear()
                }
            }
            SATableView.reloadData()
        }
    }
    func countUp(coin: String, total: String, isfirst: String) {
        if isfirst == "1" {
            if Int(total) < 3 {
                self.alertCoin = NIAlert()
                self.alertCoin?.delegate = self
                self.alertCoin?.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "你获得了念币奖励", ["好"]],
                    forKeys: ["img", "title", "content", "buttonArray"])
                self.alertCoin?.showWithAnimation(.flip)
            } else {
                // 如果念币多于 3， 那么就出现抽宠物
                let v = SAEgg()
                v.delegateShare = self
                v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "获得 \(coin) 念币", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
                    forKeys: ["img", "title", "content", "buttonArray"])
                v.showWithAnimation(.flip)
            }
        }
    }
    
    func Editstep() {
        self.dataArray[self.editStepRow] = self.editStepData!
        let newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.SATableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func setupRefresh(){
        self.SATableView!.addHeaderWithCallback({
            self.load()
        })
        self.SATableView!.addFooterWithCallback({
            self.load(false)
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {       //删除记本
                self.navigationItem.rightBarButtonItems = buttonArray()
                globalWillNianReload = 1
                Api.getDeleteDream(self.Id, callback: { json in
                    self.navigationItem.rightBarButtonItems = []
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        }
    }
    
    func editMyDream() {
        let editdreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        editdreamVC.delegate = self
        editdreamVC.isEdit = 1
        let id = dataArrayTop.stringAttributeForKey("id")
        let title = dataArrayTop.stringAttributeForKey("title")
        let content = dataArrayTop.stringAttributeForKey("content")
        let img = dataArrayTop.stringAttributeForKey("image")
        let thePrivate = Int(dataArrayTop.stringAttributeForKey("private"))!
        editdreamVC.editId = id
        editdreamVC.editTitle = title.decode()
        editdreamVC.editContent = content.decode()
        editdreamVC.editImage = img
        editdreamVC.isPrivate = thePrivate
        let tags: Array<String> = dataArrayTop.objectForKey("tags") as! Array
        editdreamVC.tagsArray = tags
        self.navigationController?.pushViewController(editdreamVC, animated: true)
    }
    
    func editDream(editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTags:Array<String>) {
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue(editPrivate, forKey: "private")
        mutableData.setValue(editTitle, forKey: "title")
        mutableData.setValue(editDes, forKey: "content")
        mutableData.setValue(editImage, forKey: "image")
        mutableData.setValue(editTags, forKey: "tags")
        dataArrayTop = mutableData
        self.SATableView.reloadData()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            let v = otherGestureRecognizer.view?.frame.origin.y
            if v > 0 {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            let v = otherGestureRecognizer.view?.frame.origin.y
            if v == 0 {
                return true
            }
        }
        return false
    }
    
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
}

// MARK: - 实现 NIAlertDelegate
extension DreamViewController: NIAlertDelegate {
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == self.alertCoin {
                niAlert.dismissWithAnimation(.normal)
        }
    }
}


