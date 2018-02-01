//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DreamViewController: VVeboViewController, UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, editDreamDelegate, topDelegate, ShareDelegate {
    
    var page: Int = 1
    var Id: String = "1"
    var deleteDreamSheet:UIActionSheet?
    var quitSheet: UIActionSheet!
    var navView: UIImageView!
    var isDesc = true
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    var newEditStepRow: Int = 0
    var newEditStepData: NSDictionary?
    
    var dataArrayTop: NSDictionary!
    
    var SATableView: VVeboTableView!
    var dataArray = NSMutableArray()
    var delegateDelete: DeleteDreamDelegate?
    var willBackToRootViewController = false
    
    var removeSheet: UIActionSheet?
    var dreamCellTop: DreamCellTop?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
        
        /* 从导航栏栈里删除，只剩下 Home 和当前视图控制器 */
        if willBackToRootViewController {
            var arr = navigationController?.viewControllers
            var arrNew: [UIViewController] = []
            if arr != nil {
                for i in 0...(arr!.count - 1) {
                    if i == 0 || i == arr!.count - 1 {
                        arrNew.append(arr![i])
                    }
                }
                navigationController?.viewControllers = arrNew
            }
        }
    }
    
    func setupViews() {
        self.viewBack()
        
        self.view.backgroundColor = UIColor.BackgroundColor()
        
        self.SATableView = VVeboTableView(frame:CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight))
        self.SATableView.delegate = self
        self.SATableView.dataSource = self
        self.SATableView.separatorStyle = .none
        self.automaticallyAdjustsScrollViewInsets = false
        
        let nib = UINib(nibName:"DreamCell", bundle: nil)
        let nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        
        self.SATableView.register(nib, forCellReuseIdentifier: "dream")
        self.SATableView.register(nib2, forCellReuseIdentifier: "dreamtop")
        self.view.addSubview(self.SATableView)
        currenTableView = SATableView
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLabel
        
        /* 添加导航栏 */
        navView = UIImageView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        navView.isHidden = true
        navView.layer.masksToBounds = true
        self.SATableView.addSubview(navView)
    }
    
    func load(_ clear: Bool = true){
        if clear {
            self.page = 1
        }
        var sort = "asc"
        if isDesc {
            sort = "desc"
        }
        Api.getDreamStep(Id, page: page, sort: sort) { json in
            if json != nil {
                if SAValue(json, "error") != "0" {
                    if let j = json as? NSDictionary {
                        let status = j.stringAttributeForKey("status")
                        self.navigationItem.rightBarButtonItems = []
                        if status == "404" {
                            self.SATableView.addGhost("这个记本\n不见了")
                        } else if status == "403" {
                            self.SATableView.addGhost("你发现了\n一个私密的记本\n里面记着什么？")
                        } else {
                            self.showTipText("遇到了一个奇怪的错误，代码是 \(status)")
                        }
                    }
                } else {
                    if let j = json as? NSDictionary {
                        if let data = j.object(forKey: "data") as? NSDictionary {
                            if clear {
                                if let _dream = data.object(forKey: "dream") as? NSDictionary {
                                    let dream = self.DataDecode(_dream)
                                    self.dataArrayTop = dream
                                }
                                self.dataArray.removeAllObjects()
                                globalVVeboReload = true
                                let btnMore = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(DreamViewController.setupNavBtn))
                                btnMore.image = UIImage(named: "more")
                                self.navigationItem.rightBarButtonItems = [btnMore]
                                
                                /* 导航栏填充背景 */
                                //                        let cover = self.dataArrayTop.stringAttributeForKey("cover")
                                //                        self.navView.setImage("http://img.nian.so/cover/\(cover)!cover")
                                
                                /* 第一页加载成功后，才建立上拉加载 */
                                self.setupRefresh()
                            } else {
                                globalVVeboReload = false
                            }
                            if let steps = data.object(forKey: "steps") as? NSArray {
                                for d in steps {
                                    let data = VVeboCell.SACellDataRecode(d as! NSDictionary)
                                    self.dataArray.add(data)
                                }
                                self.currentDataArray = self.dataArray
                                self.SATableView.reloadData()
                                self.SATableView.headerEndRefreshing()
                                self.SATableView.footerEndRefreshing()
                                self.page += 1
                            }
                        }
                    } 
                }
            }
        }
    }
    
    @objc func setupNavBtn() {
        let uid = dataArrayTop.stringAttributeForKey("uid")
        let percent = dataArrayTop.stringAttributeForKey("percent")
        let title = dataArrayTop.stringAttributeForKey("title")
        let isLiked = dataArrayTop.stringAttributeForKey("isliked")
        let joined = dataArrayTop.stringAttributeForKey("joined")
        
        let acEdit = SAActivity()
        acEdit.saActivityTitle = "编辑"
        acEdit.saActivityType = UIActivityType(rawValue: "编辑")
        acEdit.saActivityImage = UIImage(named: "av_edit")
        acEdit.saActivityFunction = {
            self.editMyDream()
        }
        
        let acDone = SAActivity()
        acDone.saActivityTitle = percent == "0" ? "完成" : "未完成"
        let percentNew = percent == "0" ? "1" : "0"
        let imageNew = percent == "0" ? "av_finish" : "av_nofinish"
        acDone.saActivityType = UIActivityType(rawValue: "完成")
        acDone.saActivityImage = UIImage(named: imageNew)
        acDone.saActivityFunction = {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(percentNew, forKey: "percent")
            self.dataArrayTop = mutableData
            self.SATableView.reloadData()
            if percent == "0" {
                Api.getDreamComplete(self.Id) { json in }
            } else {
                Api.getDreamInComplete(self.Id) { json in }
            }
            
        }
        
        let acDelete = SAActivity()
        acDelete.saActivityTitle = "删除"
        acDelete.saActivityType = UIActivityType(rawValue: "删除")
        acDelete.saActivityImage = UIImage(named: "av_delete")
        acDelete.saActivityFunction = {
            self.deleteDreamSheet = UIActionSheet(title: "再见啦，记本 #\(self.Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.deleteDreamSheet!.addButton(withTitle: "确定删除")
            self.deleteDreamSheet!.addButton(withTitle: "取消")
            self.deleteDreamSheet!.cancelButtonIndex = 1
            self.deleteDreamSheet!.show(in: self.view)
        }
        
        let acLike = SAActivity()
        acLike.saActivityTitle = isLiked == "0" ? "赞" : "取消赞"
        let isLikedNew = isLiked == "0" ? "1" : "0"
        acLike.saActivityType = UIActivityType(rawValue: "赞")
        acLike.saActivityImage = UIImage(named: "av_like")
        acLike.saActivityFunction = {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(isLikedNew, forKey: "isliked")
            self.dataArrayTop = mutableData
            self.SATableView.reloadData()
            if isLiked == "0" {
                Api.getDreamLike(self.Id) { json in
                }
            } else {
                Api.getDreamUnLike(self.Id) { json in
                }
            }
        }
        
        let acReport = SAActivity()
        acReport.saActivityTitle = "举报"
        acReport.saActivityType = UIActivityType(rawValue: "举报")
        acReport.saActivityImage = UIImage(named: "av_report")
        acReport.saActivityFunction = {
            self.showTipText("举报好了！")
        }
        
        let acQuit = SAActivity()
        acQuit.saActivityTitle = "离开"
        acQuit.saActivityType = UIActivityType(rawValue: "离开")
        acQuit.saActivityImage = UIImage(named: "av_quit")
        acQuit.saActivityFunction = {
            self.quitSheet = UIActionSheet(title: "再见啦，记本 #\(self.Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.quitSheet.addButton(withTitle: "确定退出")
            self.quitSheet.addButton(withTitle: "取消")
            self.quitSheet.cancelButtonIndex = 1
            self.quitSheet.show(in: self.view)
        }
        
        let acTime = SAActivity()
        acTime.saActivityTitle = "颠倒排序"
        acTime.saActivityType = UIActivityType(rawValue: "颠倒排序")
        acTime.saActivityImage = UIImage(named: "av_time")
        acTime.saActivityFunction = {
            let vc = DreamViewController()
            vc.Id = self.Id
            vc.isDesc = !self.isDesc
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        var arr = [acLike, acReport, acTime]
        if uid == SAUid() {
            arr = [acDone, acEdit, acDelete, acTime]
        } else if joined == "1" {
            arr = [acQuit, acLike, acReport, acTime]
        }
        let avc = SAActivityViewController.shareSheetInView(["「\(title)」- 来自念" as AnyObject, URL(string: "http://nian.so/m/dream/\(self.Id)")! as AnyObject], applicationActivities: arr)
        self.present(avc, animated: true, completion: nil)
    }
    
    func onStep(){
        if dataArrayTop != nil {
            var title = dataArrayTop.stringAttributeForKey("title").decode()
            if dataArrayTop.stringAttributeForKey("private") == "1" {
                title = "\(title)（私密）"
            } else if dataArrayTop.stringAttributeForKey("percent") == "1" {
                title = "\(title)（完成）"
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.SATableView.contentOffset.y = title.stringHeightBoldWith(18, width: 240) + 252 + 52
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let c = tableView.dequeueReusableCell(withIdentifier: "dreamtop", for: indexPath) as! DreamCellTop
            c.data = dataArrayTop != nil ? NSMutableDictionary(dictionary: dataArrayTop) : nil
            c.delegate = self
            c.setup()
            dreamCellTop = c
            return c
        } else {
            return getCell(indexPath, dataArray: dataArray, type: 1)
        }
    }
    
    func onFo() {
        let id = dataArrayTop.stringAttributeForKey("id")
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue("1", forKey: "followed")
        dataArrayTop = mutableData
        SATableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
        Api.getFollowDream(id) { json in }
    }
    
    func onUnFo() {
        let id = dataArrayTop.stringAttributeForKey("id")
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue("0", forKey: "followed")
        dataArrayTop = mutableData
        SATableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
        Api.getUnFollowDream(id) { json in }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            if dataArrayTop != nil {
                if let h = dataArrayTop.object(forKey: "heightCell") as? CGFloat {
                    return h
                }
            }
            return 100
        }else{
            return getHeight(indexPath, dataArray: dataArray)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func onAddStep(){
        let vc = AddStep(nibName: "AddStep", bundle: nil)
        vc.idDream = Id
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func setupRefresh(){
        self.SATableView!.addFooterWithCallback({
            self.load(false)
        })
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {       //删除记本
                self.navigationItem.rightBarButtonItems = buttonArray()
                Api.getDeleteDream(self.Id, callback: { json in
                    self.navigationItem.rightBarButtonItems = []
                    self.delegateDelete?.deleteDreamCallback(self.Id)
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
        } else if actionSheet == quitSheet {
            /* 离开多人记本 */
            if buttonIndex == 0 {
                self.navigationItem.rightBarButtonItems = buttonArray()
                Api.getQuit(self.Id) { json in
                    self.navigationItem.rightBarButtonItems = []
//                    self.delegateDelete?.deleteDreamCallback(self.Id)
                    //
                    
                    
                    if Nian.dataArray.count > 0 {
                        for i in 0...(Nian.dataArray.count - 1) {
                            let data = Nian.dataArray[i] as! NSDictionary
                            let _id = data.stringAttributeForKey("id")
                            if _id == self.Id {
                                Nian.dataArray.removeObject(at: i)
                                Nian.reloadFromDataArray()
                                Cookies.set(Nian.dataArray, forKey: "NianDreams")
                                break
                            }
                        }
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                }
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
        if let permission = Int(dataArrayTop.stringAttributeForKey("permission")) {
            editdreamVC.permission = permission
        }
        let tags: Array<String> = dataArrayTop.object(forKey: "tags") as! Array
        editdreamVC.tagsArray = tags
        self.navigationController?.pushViewController(editdreamVC, animated: true)
    }
    
    func editDream(_ editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTags: NSArray, editPermission: Int) {
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue(editPrivate, forKey: "private")
        mutableData.setValue(editTitle, forKey: "title")
        mutableData.setValue(editDes, forKey: "content")
        mutableData.setValue(editImage, forKey: "image")
        mutableData.setValue(editTags as Array, forKey: "tags")
        mutableData.setValue("\(editPermission)", forKey: "permission")
        dataArrayTop = DataDecode(mutableData)
        self.SATableView.reloadData()
    }
    
    func Join() {
        let d = NSMutableDictionary(dictionary: dataArrayTop)
        d.setValue("1", forKey: "joined")
        if let totalUser = Int(dataArrayTop.stringAttributeForKey("total_users")) {
            let t = totalUser + 1
            d.setValue("\(t)", forKey: "total_users")
        }
        if let editors = dataArrayTop.object(forKey: "editors") as? NSArray {
            let arr = NSMutableArray(array: editors)
            arr.add(SAUid())
            d.setValue(arr, forKey: "editors")
        }
        dataArrayTop = d
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
            let v = otherGestureRecognizer.view?.frame.origin.y
            if v > 0 {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
            let v = otherGestureRecognizer.view?.frame.origin.y
            if v == 0 {
                return true
            }
        }
        return false
    }
    
    func onShare(_ avc: UIActivityViewController) {
        self.present(avc, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == SATableView {
            let y = SATableView.contentOffset.y
            dreamCellTop?.scroll(y)
            if y > 32 {
                navView.isHidden = false
                navView.setY(y)
            } else {
                navView.isHidden = true
            }
        }
    }
    
    func DataDecode(_ data: NSDictionary) -> NSDictionary {
        let thePrivate = data.stringAttributeForKey("private")
        let percent = data.stringAttributeForKey("percent")
        let title = data.stringAttributeForKey("title").decode()
        let content = data.stringAttributeForKey("content").decode()
        let step = "进展 \(data.stringAttributeForKey("step"))"
        var like = ""
        if let likeDream = Int(data.stringAttributeForKey("like")) {
            if let likeStep = Int(data.stringAttributeForKey("like_step")) {
                let likeNum = likeDream + likeStep
                like = "赞 \(likeNum)"
            }
        }
        let followers = "关注 \(data.stringAttributeForKey("followers"))"
        var _title = ""
        if thePrivate == "1" {
            _title = "\(title)（私密）"
        } else if percent == "1" {
            _title = "\(title)（完成）"
        } else {
            _title = title
        }
        let hTitle = _title.stringHeightBoldWith(18, width: globalWidth - SIZE_PADDING * 2)
        var hContent: CGFloat = 0
        if content != "" {
            hContent = content.stringHeightWith(12, width: globalWidth - SIZE_PADDING * 2)
            let h4Lines = "\n\n\n".stringHeightWith(12, width: globalWidth - SIZE_PADDING * 2)
            hContent = min(hContent, h4Lines)
        }
        var heightCell = 314 + hTitle + hContent
        if content == "" {
            heightCell = 314 - 8 + hTitle
        }
        
        /* 当不在记本中，没有加入的权限，编辑者只有作者一个人，且当前用户不是作者本人 */
        var willHeadersHidden = "0"
        if data.stringAttributeForKey("joined") == "0" {
            if data.stringAttributeForKey("total_users") == "1" {
                if data.stringAttributeForKey("uid") != SAUid() {
                    if data.stringAttributeForKey("permission") == "0" {
                        heightCell = heightCell - 64 + 8
                        willHeadersHidden = "1"
                    } else if data.stringAttributeForKey("permission") == "1" {
                        /* 当是好友可加入时，但是不是好友的话，也隐藏 */
                        if data.stringAttributeForKey("is_friend") == "0" {
                            heightCell = heightCell - 64 + 8
                            willHeadersHidden = "1"
                        }
                    }
                }
            }
        }
        
        let wStep = step.stringWidthWith(12, height: 32)
        let wLike = like.stringWidthWith(12, height: 32)
        let wFollowers = followers.stringWidthWith(12, height: 32)
        heightCell = SACeil(heightCell, dot: 0, isCeil: true)
        let mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(hTitle, forKey: "heightTitle")
        mutableData.setValue(hContent, forKey: "heightContent")
        mutableData.setValue(heightCell, forKey: "heightCell")
        mutableData.setValue(content, forKey: "content")
        mutableData.setValue(title, forKey: "title")
//        mutableData.setValue(step, forKey: "step")
//        mutableData.setValue(like, forKey: "like")
//        mutableData.setValue(followers, forKey: "followers")
        mutableData.setValue(wStep, forKey: "widthStep")
        mutableData.setValue(wLike, forKey: "widthLike")
        mutableData.setValue(wFollowers, forKey: "widthFollowers")
        mutableData.setValue(willHeadersHidden, forKey: "willHeadersHidden")
        return NSDictionary(dictionary: mutableData)
    }
}
