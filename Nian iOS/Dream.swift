//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class NILabel: UILabel {
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = CGRectInset(bounds, 4, 0)
        
        return rect
    }
}

class DreamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, UIGestureRecognizerDelegate, editDreamDelegate, delegateSAStepCell{
    
    var tableView: UITableView!
    var page: Int = 1
    var Id: String = "1"
    var deleteDreamSheet:UIActionSheet?
    var navView:UIView!
    var viewCoin: Popup!
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    var dataArray = NSMutableArray()
    var dataArrayTop: NSDictionary!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func setupViews() {
        self.viewBack()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"DreamCell", bundle: nil)
        var nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: "dream")
        self.tableView?.registerNib(nib2, forCellReuseIdentifier: "dreamtop")
        self.tableView?.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        self.view.addSubview(self.tableView!)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
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
                var data = json!["data"]
                if clear {
                    self.dataArrayTop = data!!["dream"] as! NSDictionary
                    self.dataArray.removeAllObjects()
                    var btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "setupNavBtn")
                    btnMore.image = UIImage(named: "more")
                    self.navigationItem.rightBarButtonItems = [btnMore]
                }
                var steps = data!!["steps"] as! NSArray
                for data in steps {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
                self.tableView.footerEndRefreshing()
                self.page++
            }
        }
        //  todo
//        self.tableView!.setFooterHidden(clear)
//        Api.getDreamStep(self.Id, page: self.page) { json in
//            if json != nil {
//                println(json)
//                var thePrivate = json!["private"] as! String
//                var uid = json!["uid"] as! String
//                var arr = json!["items"] as! NSArray
//                if clear {
//                    self.dataArray.removeAllObjects()
//                }
//                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//                var safeuid = Sa.objectForKey("uid") as! String
//                if thePrivate == "2" {
//                    // 删除
//                    var viewTop = viewEmpty(globalWidth, content: "这个记本\n不见了")
//                    viewTop.setY(104)
//                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
//                    viewHolder.addSubview(viewTop)
//                    self.view.addSubview(viewHolder)
//                    self.tableView?.hidden = true
//                    self.navigationItem.rightBarButtonItems = []
//                }else if thePrivate == "1" && uid != safeuid {
//                    // 私密
//                    var viewTop = viewEmpty(globalWidth, content: "你发现了\n一个私密的记本\n里面记着什么？")
//                    viewTop.setY(104)
//                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
//                    viewHolder.addSubview(viewTop)
//                    self.view.addSubview(viewHolder)
//                    self.tableView?.hidden = true
//                    self.navigationItem.rightBarButtonItems = []
//                }else{
//                    for data: AnyObject in arr {
//                        self.dataArray.addObject(data)
//                    }
//                }
//                self.tableView?.reloadData()
//                self.tableView?.headerEndRefreshing()
//                self.tableView?.footerEndRefreshing()
//                self.page++
//            }
//        }
    }
    
    func setupNavBtn() {
        var uid = dataArrayTop.stringAttributeForKey("uid")
        var percent = dataArrayTop.stringAttributeForKey("percent")
        var title = dataArrayTop.stringAttributeForKey("title")
        var follow = dataArrayTop.stringAttributeForKey("follow")
        var isLiked = dataArrayTop.stringAttributeForKey("isliked")
        
        var acEdit = SAActivity()
        acEdit.saActivityTitle = "编辑"
        acEdit.saActivityType = "编辑"
        acEdit.saActivityImage = UIImage(named: "av_edit")
        acEdit.saActivityFunction = {
            self.editMyDream()
        }
        
        var acDone = SAActivity()
        acDone.saActivityTitle = percent == "0" ? "完成" : "未完成"
        var percentNew = percent == "0" ? "1" : "0"
        acDone.saActivityType = "完成"
        acDone.saActivityImage = UIImage(named: "av_finish")
        acDone.saActivityFunction = {
            var mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(percentNew, forKey: "percent")
            self.dataArrayTop = mutableData
            self.tableView.reloadData()
            Api.postCompleteDream(self.Id, percent: percentNew) { string in
            }
        }
        
        var acDelete = SAActivity()
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
        
        var acLike = SAActivity()
        acLike.saActivityTitle = isLiked == "0" ? "赞" : "取消赞"
        var isLikedNew = isLiked == "0" ? "1" : "0"
        acLike.saActivityType = "赞"
        acLike.saActivityImage = UIImage(named: "av_like")
        acLike.saActivityFunction = {
            var mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(isLikedNew, forKey: "isliked")
            self.dataArrayTop = mutableData
            self.tableView.reloadData()
            Api.postLikeDream(self.Id, like: isLikedNew) { string in }
        }
        
        var acReport = SAActivity()
        acReport.saActivityTitle = "举报"
        acReport.saActivityType = "举报"
        acReport.saActivityImage = UIImage(named: "av_report")
        acReport.saActivityFunction = {
            self.view.showTipText("举报好了！", delay: 2)
        }
        
        var arr = SAUid() == uid ? [WeChatSessionActivity(), WeChatMomentsActivity(), acDone, acEdit, acDelete] : [WeChatSessionActivity(), WeChatMomentsActivity(), acLike, acReport]
        var acv = UIActivityViewController(activityItems: ["「\(title)」- 来自念", NSURL(string: "http://nian.so/m/dream/\(self.Id)")!], applicationActivities: arr)
        acv.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop,UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard]
        self.presentViewController(acv, animated: true, completion: nil)
    }
    //  todo
//    func onStepClick(){
//        UIView.animateWithDuration(0.3, animations: {
//            self.tableView!.contentOffset.y = 287
//        })
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var c = tableView.dequeueReusableCellWithIdentifier("dreamtop", forIndexPath: indexPath) as! DreamCellTop
            c.data = dataArrayTop
            if dataArrayTop != nil {
                var uid = dataArrayTop.stringAttributeForKey("uid")
                if SAUid() == uid {
                    c.btnMain.addTarget(self, action: "onAddStep", forControlEvents: UIControlEvents.TouchUpInside)
                    c.btnMain.setTitle("更新", forState: UIControlState.allZeros)
                }
            }
            return c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.data = self.dataArray[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArray.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if dataArrayTop != nil {
                var title = SADecode(SADecode(dataArrayTop.stringAttributeForKey("title")))
                if dataArrayTop.stringAttributeForKey("private") == "1" {
                    title = "\(title)（私密）"
                } else if dataArrayTop.stringAttributeForKey("percent") == "1" {
                    title = "\(title)（完成）"
                }
                return title.stringHeightBoldWith(19, width: 242) + 256 + 14 + 44
            }
            return 0
        }else{
            var data = self.dataArray[indexPath.row] as! NSDictionary
            var h = SAStepCell.cellHeightByData(data)
            return h
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
        var vc = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        vc.Id = self.Id
        vc.delegate = self    //😍
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func countUp(coin: String, isfirst: String){
        self.load()
        if let step = dataArrayTop.stringAttributeForKey("step").toInt() {
            var mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue("\(step + 1)", forKey: "step")
            dataArrayTop = mutableData
            tableView.reloadData()
        }
        if isfirst == "1" {
            self.viewCoin = (NSBundle.mainBundle().loadNibNamed("Popup", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Popup
            self.viewCoin.textTitle = "获得 \(coin) 念币"
            self.viewCoin.textContent = "你获得了念币奖励！"
            self.viewCoin.heightImage = 130
            self.viewCoin.textBtnMain = "好"
            self.viewCoin.btnMain.addTarget(self, action: "onCoinClick", forControlEvents: UIControlEvents.TouchUpInside)
            self.viewCoin.viewBackGround.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCoinClick"))
            self.viewCoin.viewHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
            var imageCoin = UIImageView(frame: CGRectMake(135 - 28, 55, 56, 70))
            imageCoin.image = UIImage(named: "coin")
            self.viewCoin.viewHolder.addSubview(imageCoin)
            self.view.addSubview(self.viewCoin)
        }
    }
    
    func onCoinClick() {
        self.viewCoin.removeFromSuperview()
    }
    
    func Editstep() {      //😍
        self.dataArray[self.editStepRow] = self.editStepData!
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.tableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.load()
        })
        self.tableView!.addFooterWithCallback({
            self.load(clear: false)
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        
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
        var editdreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        editdreamVC.delegate = self
        editdreamVC.isEdit = 1
        var id = dataArrayTop.stringAttributeForKey("id")
        var title = dataArrayTop.stringAttributeForKey("title")
        var content = dataArrayTop.stringAttributeForKey("content")
        var img = dataArrayTop.stringAttributeForKey("image")
        var thePrivate = dataArrayTop.stringAttributeForKey("private").toInt()!
        editdreamVC.editId = id
        editdreamVC.editTitle = SADecode(SADecode(title))
        editdreamVC.editContent = SADecode(SADecode(content))
        editdreamVC.editImage = img
        editdreamVC.isPrivate = thePrivate
        var tags: Array<String> = dataArrayTop.objectForKey("tags") as! Array
        editdreamVC.tagsArray = tags
        self.navigationController?.pushViewController(editdreamVC, animated: true)
    }
    
    func editDream(editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTag:String, editTags:Array<String>) {
        var mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue(editPrivate, forKey: "private")
        mutableData.setValue(editTitle, forKey: "title")
        mutableData.setValue(editDes, forKey: "content")
        mutableData.setValue(editImage, forKey: "image")
        mutableData.setValue(editTags, forKey: "tags")
        dataArrayTop = mutableData
        self.tableView.reloadData()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            var v = otherGestureRecognizer.view?.frame.origin.y
            if v > 0 {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            var v = otherGestureRecognizer.view?.frame.origin.y
            if v == 0 {
                return true
            }
        }
        return false
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArray, index, key, value, self.tableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 1, self.tableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArray, index, self.tableView, 1)
    }
    
}

