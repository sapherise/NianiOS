//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class PlayerViewController: VVeboViewController, UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate {
    
    var tableViewDream: UITableView!
    var tableViewStep: VVeboTableView!
    var dataArray = NSMutableArray()
    var dataArrayStep = NSMutableArray()
    var page: Int = 1
    var pageStep: Int = 1
    var Id:String = "0"
    var ownerMoreSheet:UIActionSheet?
    var guestMoreSheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteDreamSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath

    var newEditStepRow: Int = 0
    var newEditStepData: NSDictionary?
    
    var dreamowner:Int = 0 //如果是0，就不是主人，是1就是主人
    var userMoreSheet:UIActionSheet!
    
    var ReplyUser:String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReturnReplyRow:Int = 0
    var ReplyCid:String = ""
    var activityViewController:UIActivityViewController?
    
    var percentJson: String = ""
    var followJson: String = ""
    var likeJson: String = ""
    var imgJson: String = ""
    var privateJson: String = ""
    var contentJson: String = ""
    var owneruid: String = ""
    var likestepJson: String = ""
    var liketotalJson: Int = 0
    var stepJson: String = ""
    var desJson:String = ""
    
    var topCell:PlayerCellTop!
    var navView: UIImageView!
    var isBan: Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SALoadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = UIRectEdge()
        
        let safeuid = SAUid()
//        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        if self.Id != safeuid {
            let moreButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(PlayerViewController.userMore))
            moreButton.image = UIImage(named:"more")
            self.navigationItem.rightBarButtonItems = [ moreButton ]
            self.dreamowner = 0
        }else{
            self.dreamowner = 1
        }
        self.navView = UIImageView(frame: CGRect(x: 0, y: -64, width: globalWidth, height: 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.navView.isHidden = true
        self.navView.clipsToBounds = true
        self.view.addSubview(self.navView)
        self.topCell = (Bundle.main.loadNibNamed("PlayerCellTop", owner: self, options: nil))?.first as! PlayerCellTop
        self.topCell.frame = CGRect(x: 0, y: -64, width: globalWidth, height: 364)
        self.setupPlayerTop(Int(self.Id)!)
        let nib3 = UINib(nibName:"StepCell", bundle: nil)
        self.tableViewDream = UITableView(frame:CGRect(x: 0, y: -64, width: globalWidth,height: globalHeight))
        self.tableViewDream.delegate = self
        self.tableViewDream.dataSource = self
        self.tableViewDream.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableViewDream.register(nib3, forCellReuseIdentifier: "step")
        self.tableViewDream.showsVerticalScrollIndicator = false
        self.tableViewStep = VVeboTableView(frame:CGRect(x: 0, y: -64, width: globalWidth,height: globalHeight))
        currenTableView = tableViewStep
        self.tableViewStep.delegate = self
        self.tableViewStep.dataSource = self
        self.tableViewStep.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableViewStep.showsVerticalScrollIndicator = false
        self.tableViewStep.isHidden = true
        
        self.topCell.labelMenuLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.onMenuClick(_:))))
        self.topCell.labelMenuRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.onMenuClick(_:))))
        self.view.addSubview(self.tableViewStep)
        self.view.addSubview(self.tableViewDream)
        self.view.addSubview(self.topCell)
    }
    
    @objc func userMore(){
        self.userMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.isBan == 0 {
            self.userMoreSheet.addButton(withTitle: "拖进小黑屋")
        }else{
            self.userMoreSheet.addButton(withTitle: "取消小黑屋")
        }
        self.userMoreSheet.addButton(withTitle: "取消")
        self.userMoreSheet.cancelButtonIndex = 1
        self.userMoreSheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == self.userMoreSheet {
            if buttonIndex == 0 {
                if self.isBan == 0 {
                    // 拖进小黑屋
                    self.showTipText("成功拖进小黑屋")
                    Api.postBlackAdd(Id) { json in
                        if json != nil {
                            RCIMClient.shared().add(toBlacklist: self.Id, success: nil, error: nil)
                            self.isBan = 1
                        }
                    }
                }else{
                    // 取消小黑屋
                    self.showTipText("和好了")
                    Api.postBlackRemove(Id) { json in
                        if json != nil {
                            RCIMClient.shared().remove(fromBlacklist: self.Id, success: nil, error: nil)
                            self.isBan = 0
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentOffset.y
        if scrollView == self.tableViewDream || scrollView == self.tableViewStep {
            self.scrollLayout(height)
        }
    }
    
    func scrollLayout(_ height:CGFloat){
        if height > 0 {
            self.topCell.setY(-height-64)
            self.topCell.BGImage.setY(height/2)
        }else{
            self.topCell.setY(-64)
            self.topCell.BGImage.frame = CGRect(x: height/10, y: height/10, width: globalWidth-height/5, height: 320-height/5)
        }
        scrollHidden(self.topCell.viewHolderHead, height: height, scrollY: 68)
        scrollHidden(self.topCell.imageBadge, height: height, scrollY: 68)
        scrollHidden(self.topCell.UserName, height: height, scrollY: 138)
        scrollHidden(self.topCell.imageSex, height: height, scrollY: 138)
        scrollHidden(self.topCell.UserFo, height: height, scrollY: 161)
        scrollHidden(self.topCell.UserFoed, height: height, scrollY: 161)
        scrollHidden(self.topCell.btnMain, height: height, scrollY: 214)
        scrollHidden(self.topCell.btnLetter, height: height, scrollY: 214)
        if height >= 320 - 64 {
            self.navView.isHidden = false
            self.view.bringSubview(toFront: self.navView)
        }else{
            self.navView.isHidden = true
        }
    }
    
    func scrollHidden(_ theView:UIView, height:CGFloat, scrollY:CGFloat){
        if ( height > scrollY - 50 && height <= scrollY ) {
            theView.alpha = ( scrollY - height ) / 50
        }else if height > scrollY {
            theView.alpha = 0
        }else{
            theView.alpha = 1
        }
    }
    
    func ownerMore(){
        self.ownerMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.ownerMoreSheet!.addButton(withTitle: "编辑记本")
        if self.percentJson == "1" {
            self.ownerMoreSheet!.addButton(withTitle: "还未完成记本")
        }else if self.percentJson == "0" {
            self.ownerMoreSheet!.addButton(withTitle: "完成记本")
        }
        self.ownerMoreSheet!.addButton(withTitle: "分享记本")
        self.ownerMoreSheet!.addButton(withTitle: "删除记本")
        self.ownerMoreSheet!.addButton(withTitle: "取消")
        self.ownerMoreSheet!.cancelButtonIndex = 4
        self.ownerMoreSheet!.show(in: self.view)
    }
    
    func guestMore(){
        self.guestMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.followJson == "1" {
            self.guestMoreSheet!.addButton(withTitle: "取消关注记本")
        }else if self.followJson == "0" {
            self.guestMoreSheet!.addButton(withTitle: "关注记本")
        }
        if self.likeJson == "1" {
            self.guestMoreSheet!.addButton(withTitle: "取消赞")
        }else if self.likeJson == "0" {
            self.guestMoreSheet!.addButton(withTitle: "赞记本")
        }
        self.guestMoreSheet!.addButton(withTitle: "分享记本")
        self.guestMoreSheet!.addButton(withTitle: "举报")
        self.guestMoreSheet!.addButton(withTitle: "取消")
        self.guestMoreSheet!.cancelButtonIndex = 4
        self.guestMoreSheet!.show(in: self.view)
    }
    
    func SALoadData(_ isClear: Bool = true) {
        if isClear {
            self.tableViewDream.setFooterHidden(false)
            self.page = 1
            let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 70))
            let activity = UIActivityIndicatorView()
            activity.color = UIColor.HighlightColor()
            activity.startAnimating()
            activity.isHidden = false
            v.addSubview(activity)
            activity.center = v.center
            self.tableViewDream.tableFooterView = v
        }
        Api.getUserDream(Id, page: page) { json in
            if json != nil {
                self.tableViewDream.tableFooterView = UIView()
                let d = json!.object(forKey: "data")
                let arr = (d! as AnyObject).object(forKey: "dreams") as! NSArray
                
                if isClear {
                    self.dataArray.removeAllObjects()
                }
                for data in arr {
                    self.dataArray.add(data)
                }
                self.tableViewDream.reloadData()
                self.tableViewStep.footerEndRefreshing()
                self.page += 1
            }
        }
    }
    
    func SALoadDataStep(_ isClear: Bool = true) {
        if isClear {
            globalVVeboReload = true
            self.tableViewStep.setFooterHidden(false)
            self.pageStep = 1
            let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 70))
            let activity = UIActivityIndicatorView()
            activity.color = UIColor.HighlightColor()
            activity.startAnimating()
            activity.isHidden = false
            v.addSubview(activity)
            activity.center = CGPoint(x: v.center.x, y: v.center.y + 30)
            self.tableViewStep.tableFooterView = v
        } else {
            globalVVeboReload = false
        }
        Api.getUserActive(Id, page: self.pageStep) { json in
            if json != nil {
                self.tableViewStep.tableFooterView = UIView()
                let data = json!.object(forKey: "data")
                let arr = (data! as AnyObject).object(forKey: "steps") as! NSArray
                if isClear {
                    self.dataArrayStep.removeAllObjects()
                }
                for data in arr {
                    let d = VVeboCell.SACellDataRecode(data as! NSDictionary)
                    self.dataArrayStep.add(d)
                }
                self.currentDataArray = self.dataArrayStep
                self.tableViewStep.reloadData()
                self.tableViewStep.footerEndRefreshing()
                self.pageStep += 1
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath as NSIndexPath).section == 0 {
            let c = UITableViewCell()
            c.isHidden = true
            c.selectionStyle = .none
            return c
        }else{
            if tableView == self.tableViewDream {
                let c = tableView.dequeueReusableCell(withIdentifier: "step", for: indexPath) as? StepCell
                let dictionary:Dictionary<String, String> = ["id":"", "title":"", "img":"", "percent":""]
                let index = (indexPath as NSIndexPath).row * 3
                if index<self.dataArray.count {
                    c!.data1 = self.dataArray[index] as! NSDictionary
                    c!.img1?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.dreamclick(_:))))
                }else{
                    c!.data1 = dictionary as NSDictionary!
                }
                if index+1<self.dataArray.count {
                    c!.data2 = self.dataArray[index + 1] as! NSDictionary
                    c!.img2?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.dreamclick(_:))))
                }else{
                    c!.data2 = dictionary as NSDictionary!
                }
                if index+2<self.dataArray.count {
                    c!.data3 = self.dataArray[index + 2] as! NSDictionary
                    c!.img3?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.dreamclick(_:))))
                }else{
                    c!.data3 = dictionary as NSDictionary!
                }
                c!._layoutSubviews()
                return c!
            }else{
                return getCell(indexPath, dataArray: dataArrayStep, type: 0)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            if tableView == self.tableViewDream {
                return 364 + 30
            }else{
                return 364
            }
        }else{
            if tableView == self.tableViewDream {
                return  129
            }else{
                return getHeight(indexPath, dataArray: dataArrayStep)
            }
        }
    }
    
    func setupRefresh(){
        self.tableViewStep.addFooterWithCallback({
            self.SALoadDataStep(false)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            if tableView == self.tableViewDream {
                return Int(ceil(Double(self.dataArray.count)/3))
            }else{
                return self.dataArrayStep.count
            }
        }
    }
    
    func setupPlayerTop(_ theUid:Int){
        Api.getUserTop(theUid){ json in
            if json != nil {
                let _data = json!.object(forKey: "data") as! NSDictionary
                let data = _data.object(forKey: "user") as! NSDictionary
                let name = data.stringAttributeForKey("name")
                var fo = data.stringAttributeForKey("follows")
                var foed = data.stringAttributeForKey("followed")
                let isfo = data.stringAttributeForKey("is_followed")
                let cover = data.stringAttributeForKey("cover")
                let black = data.stringAttributeForKey("isban")
                let sex = data.stringAttributeForKey("gender")
                if let v = Int(black) {
                    self.isBan = v
                }
                if sex == "1" {
                    self.topCell.imageSex.image = UIImage(named: "user_male")
                    self.topCell.imageSex.isHidden = false
                }else if sex == "2" {
                    self.topCell.imageSex.image = UIImage(named: "user_female")
                    self.topCell.imageSex.isHidden = false
                }
                fo = "\(fo) 关注，"
                foed = "\(foed) 听众"
                let foWidth = fo.stringWidthBoldWith(12, height: 21) + 8
                let foedWidth = foed.stringWidthBoldWith(12, height: 21) + 8
                let foX = ( globalWidth - foWidth - foedWidth ) / 2
                let foedX = foX + foWidth
                let AllCoverURL = "http://img.nian.so/cover/\(cover)!cover"
                self.topCell.UserName.text = name
                let width = name.stringWidthBoldWith(19, height: 23) + 4
                self.topCell.UserName.setWidth(width)
                self.topCell.UserName.setX((globalWidth-width)/2)
                self.topCell.imageSex.setX((globalWidth-width)/2+width)
                self.topCell.UserFo.text = fo
                self.topCell.UserFoed.text = foed
                self.topCell.UserFo.setX(foX)
                self.topCell.UserFoed.setX(foedX)
                self.topCell.UserFo.setWidth(foWidth)
                self.topCell.UserFoed.setWidth(foedWidth)
                self.topCell.UserHead.setHead("\(theUid)")
                self.topCell.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.onUserHeadClick(_:))))
                let vip = data.stringAttributeForKey("vip")
                self.topCell.imageBadge.setType(vip)
                
                self.topCell.btnMain.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)
                self.topCell.btnLetter.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)
                if cover == "" {
                    self.navView.image = UIImage(named: "bg")
                    self.navView.contentMode = UIViewContentMode.scaleAspectFill
                }else{
                    self.navView.setCover(AllCoverURL)
                }
                self.topCell.UserFo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.onFoClick)))
                self.topCell.UserFoed.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.onFoedClick)))
                if isfo == "1" {
                    self.topCell.btnMain.addTarget(self, action: #selector(PlayerViewController.SAunfo(_:)), for: UIControlEvents.touchUpInside)
                    self.topCell.btnMain.setTitle("已关注", for: UIControlState())
                }else{
                    self.topCell.btnMain.addTarget(self, action: #selector(PlayerViewController.SAfo(_:)), for: UIControlEvents.touchUpInside)
                    self.topCell.btnMain.setTitle("关注", for: UIControlState())
                }
                self.topCell.btnLetter.addTarget(self, action: #selector(PlayerViewController.SALetter(_:)), for: UIControlEvents.touchUpInside)
                self.topCell.btnLetter.setTitle("写信", for: UIControlState())
                
                let safeuid = SAUid()
                
                if self.Id == safeuid {
                    self.topCell.btnLetter.isHidden = true
                    self.topCell.btnMain.setTitle("设置", for: UIControlState())
                    self.topCell.btnMain.setX(globalWidth/2 - 50)
                    self.topCell.btnMain.removeTarget(self, action: #selector(PlayerViewController.SAunfo(_:)), for: UIControlEvents.touchUpInside)
                    self.topCell.btnMain.removeTarget(self, action: #selector(PlayerViewController.SAfo(_:)), for: UIControlEvents.touchUpInside)
                    self.topCell.btnMain.addTarget(self, action: #selector(PlayerViewController.SASettings), for: UIControlEvents.touchUpInside)
                }
                if cover == "" {
                    self.topCell.BGImage.contentMode = UIViewContentMode.scaleAspectFill
                    self.topCell.BGImage.image = UIImage(named: "bg")
                }else{
                    self.topCell.BGImage.setCover(AllCoverURL, ignore: false, animated: true)
                }
            }
        }
    }
    
    @objc func SASettings() {
        let vc = NewSettingViewController(nibName: "NewSettingView", bundle: nil)
        vc.coverImage = self.topCell.BGImage.image
        vc.avatarImage = self.topCell.UserHead.image
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func onUserHeadClick(_ sender:UIGestureRecognizer) {
        if let v = sender.view as? UIImageView {
            let images = NSMutableArray()
            let data = ["path": "\(self.Id).jpg", "width": "500", "height": "500"]
            images.add(data)
//            v.showImage("http://img.nian.so/head/\(self.Id).jpg!dream")
//            v.open(images, index: 0, exten: "!dream")
            v.open(images, index: 0, exten: "!dream", folder: "head")
        }
    }
    
    @objc func onMenuClick(_ sender:UIGestureRecognizer){
        let tag = sender.view!.tag
        let y1 = self.tableViewDream.contentOffset.y
        let y2 = self.tableViewStep.contentOffset.y
        if tag == 100 {
            self.tableViewDream.contentOffset.y = y2
            self.tableViewStep.isHidden = true
            self.tableViewDream.isHidden = false
            self.topCell.labelMenuLeft.textColor = UIColor.HighlightColor()
            self.topCell.labelMenuRight.textColor = UIColor.black
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.topCell.labelMenuSlider.setX(self.topCell.labelMenuLeft.x()+15)
            })
            if self.dataArray.count == 0 {
                self.SALoadData()
            }
        }else if tag == 200 {
            self.tableViewStep.contentOffset.y = y1
            self.tableViewDream.isHidden = true
            self.tableViewStep.isHidden = false
            self.topCell.labelMenuRight.textColor = UIColor.HighlightColor()
            self.topCell.labelMenuLeft.textColor = UIColor.black
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.topCell.labelMenuSlider.setX(self.topCell.labelMenuRight.x()+15)
            })
            if self.dataArrayStep.count == 0 {
                self.SALoadDataStep()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if (indexPath as NSIndexPath).section > 0 && tableView == self.tableViewStep {
            let index = (indexPath as NSIndexPath).row
            let data = self.dataArrayStep[index] as! NSDictionary
            let dream = data.stringAttributeForKey("dream")
            let DreamVC = DreamViewController()
            DreamVC.Id = dream
            self.navigationController!.pushViewController(DreamVC, animated: true)
        }
    }
    
    @objc func onFoClick(){
        let LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 1
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    @objc func onFoedClick(){
        let LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 2
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    @objc func SAfo(_ sender:UIButton){
        sender.setTitle("已关注", for: UIControlState())
        sender.removeTarget(self, action: #selector(PlayerViewController.SAfo(_:)), for: UIControlEvents.touchUpInside)
        sender.addTarget(self, action: #selector(PlayerViewController.SAunfo(_:)), for: UIControlEvents.touchUpInside)
        let textFoed = SAReplace(self.topCell.UserFoed.text!, before: " 听众", after: "") as String
        if let num = Int(textFoed) {
            self.topCell.UserFoed.text = "\(num + 1) 听众"
        }
        Api.getFollow(self.Id) { json in
        }
    }
    
    @objc func SAunfo(_ sender:UIButton){
        sender.setTitle("关注", for: UIControlState())
        sender.removeTarget(self, action: #selector(PlayerViewController.SAunfo(_:)), for: UIControlEvents.touchUpInside)
        sender.addTarget(self, action: #selector(PlayerViewController.SAfo(_:)), for: UIControlEvents.touchUpInside)
        let textFoed = SAReplace(self.topCell.UserFoed.text!, before: " 听众", after: "") as String
        if let num = Int(textFoed) {
            self.topCell.UserFoed.text = "\(num - 1) 听众"
        }
        Api.getUnfollow(self.Id) { json in
        }
    }
    
    @objc func SALetter(_ sender: UIButton) {
        let letterVC = CircleController()
        if let id = Int(self.Id) {
            letterVC.id = id
            letterVC.name = self.topCell.UserName.text!
            self.navigationController?.pushViewController(letterVC, animated: true)
        }
    }
    
    @objc func dreamclick(_ sender:UITapGestureRecognizer){
        let DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
}

//extension PlayerViewController: NewAddStepDelegate {
//    
//    func newCountUp(coin: String, isfirst: String) {
//        self.SALoadData()
//    }
//    
//    func newEditstep() {
//        if self.newEditStepData != nil {
//            self.dataArrayStep[self.newEditStepRow] = self.newEditStepData!
//            let newpath = NSIndexPath(forRow: self.newEditStepRow, inSection: 1)
//            self.tableViewStep.reloadRowsAtIndexPaths([newpath], withRowAnimation: .Left)
//        }
//    }
//    
//}






