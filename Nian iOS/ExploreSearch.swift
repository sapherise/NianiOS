//
//  ExploreSearch.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit
import Foundation

class ExploreSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

    class DreamSearchData {
        var id: String!
        var uid: String!
        var title: String!
        var lastdate: String!
        var content: String!
        var img: String!
        var sid: String!
        var follow: String!
    }
    
    class UserSearchData  {
        var uid: String!
        var user: String!
        var follow: String!
    }
    
    class DreamStepData {
        var sid: String!
        var uid: String!
        var user: String!
        var content: String!
        var lastdate: String!
        var title: String!
        var img: String!
        var img0: Float!
        var img1: Float!
        var like: Int!
        var liked: Int!
        var comment: Int!
        var follow: String!
    }
    
    //MARK: custom textfield
    class NITextfield: UITextField {
        override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectMake(bounds.origin.x, bounds.origin.y, 26 , 26)
        }
        
        override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectMake(bounds.size.width - 25, bounds.origin.y, 26, 26)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!  //user table view 
    @IBOutlet weak var dreamTableView: UITableView! //dream table view
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var indiView: UIView!   //indication view
    @IBOutlet weak var dreamButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var floatView: UIView!
    
     private var kvoContext: UInt8 = 1
    
    var searchText = NITextfield()
    var index: Int = 0
    var dreamPage: Int = 1
    var userPage: Int = 1
    var dreamSearchDataSource = [DreamSearchData]()
    var dreamStepDataSource = [DreamStepData]()
    var dreamStepArray = NSMutableArray()
    dynamic var userSearchDataSource = [UserSearchData]()
    var netResult: Bool = false  //将要显示的数据是否是服务器返回的数据
    var dreamLastSearch: String = ""
    var userLastSearch: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dreamTableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
//        self.dreamTableView.registerClass(searchResultCell.self, forCellReuseIdentifier: "searchResultCell")
//        self.tableView.registerClass(searchUserResultCell.self, forCellReuseIdentifier: "searchUserResultCell")
        
        setupView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: searchText)
        self.addObserver(self, forKeyPath: "userSearchDataSource", options: NSKeyValueObservingOptions.New, context: &kvoContext)
        self.addObserver(self, forKeyPath: "dreamSearchDataSource", options: NSKeyValueObservingOptions.New, context: &kvoContext)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
        
        searchText.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //index = 0, dream table view 应该显示
        self.dreamTableView.hidden = !(index == 0)
        self.tableView.hidden = !self.dreamTableView.hidden
    }

    deinit {
        self.removeObserver(self, forKeyPath: "userSearchDataSource")
        self.removeObserver(self, forKeyPath: "dreamSearchDataSource")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.navigationController?.navigationBar.addSubview(searchText)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            if keyPath == "userSearchDataSource" {
                if count(userSearchDataSource) > 0 {
                    self.tableView.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                    self.dreamTableView.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                } else {
                    self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                    self.dreamTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                }
            } else if keyPath == "dreamSearchDataSource" {
                if count(dreamSearchDataSource) > 0 || count(dreamStepDataSource) > 0 {
                    self.tableView.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                    self.dreamTableView.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                } else {
                    self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                    self.dreamTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
                }
            } else {
                    super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            
            }
        }
    }
    

    func load(index: Int, clear: Bool, callback: Bool -> Void) {
        if index == 0 {
            self.dreamSearch(clear, callback: callback)
        } else {
            self.userSearch(clear, callback: callback)
        }
    }
    
    func onRefresh() {
        if self.index == 0 {
            dreamPage = 1
            
            load(index, clear: true) {
                success in
                self.dreamTableView.headerEndRefreshing()
                self.dreamTableView.reloadData()
            }
        } else {
            userPage = 1
            
            load(index, clear: true) {
                success in
                self.tableView.headerEndRefreshing(animated: true)
                self.tableView.reloadData()
            }
        }
    }
    
    func onLoad() {
        if index == 0 {
            load(index, clear: false) {
                success in
                    if success {
                        self.dreamTableView.footerEndRefreshing(animated: true)
                        self.dreamTableView.reloadData()
                    } else {
                        self.view.showTipText("已经到底啦", delay: 1)
                        self.dreamTableView.footerEndRefreshing(animated: true)
                    }
            }
        } else {
            load(index, clear: false) {
                success in
                if success {
                    self.tableView.footerEndRefreshing(animated: true)
                    self.tableView.reloadData()
                }  else {
                    self.view.showTipText("已经到底啦", delay: 1)
                    self.tableView.footerEndRefreshing(animated: true)
                }
            }
        }
    }
    
    func onPullDown() {
        self.onRefresh()
    }
    
    func onPullUp() {
        self.onLoad()
    }
    
    func setupView() {
        viewBack()
        
        setupButtonColor(index)
        
        tableView.setHeight(globalHeight - 104)
        tableView.setWidth(globalWidth)
        dreamTableView.setHeight(globalHeight - 104)
        dreamTableView.setWidth(globalWidth)
        navView.setWidth(globalWidth)
        indiView.setWidth(globalWidth)
        dreamButton.setX(globalWidth/2 - 85)
        userButton.setX(globalWidth/2 + 5)
        floatView.setX(globalWidth/2 - 70)
        //globalWidth/2 + 49
        
        searchText = NITextfield(frame: CGRectMake(44, 8, globalWidth-60, 26))
        var color = UIColor(red: 0xd8/255, green: 0xd8/255, blue: 0xd8/255, alpha: 1)
        searchText.layer.cornerRadius = 13
        searchText.layer.masksToBounds = true
        searchText.backgroundColor = UIColor(red: 0x3b/255, green: 0x40/255, blue: 0x44/255, alpha: 1.0)
        searchText.leftViewMode = .Always
        searchText.leftView  = UIImageView(image: UIImage(named: "search"))
        searchText.leftView?.contentMode = .Center
        searchText.rightView = UIImageView(image: UIImage(named: "close-1"))
        searchText.rightView!.contentMode = .Center
        searchText.rightView!.userInteractionEnabled = true
        searchText.rightView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clearText:"))
        searchText.attributedPlaceholder = NSAttributedString(string: "点此搜索梦想、用户", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFontOfSize(12.0)])
        searchText.contentVerticalAlignment = .Center
        searchText.font = UIFont.systemFontOfSize(12.0)
        searchText.textColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1)
        searchText.returnKeyType = .Search
        searchText.clearsOnBeginEditing = false
        searchText.delegate = self
        self.navigationController?.navigationBar.addSubview(searchText)
       
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
        self.dreamTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKbd:"))
        
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
        dreamTableView.addHeaderWithCallback(onPullDown)
        dreamTableView.addFooterWithCallback(onPullUp)
    }
    
    func setupButtonColor(index: Int) {
        if index == 0 {
            dreamButton.setTitleColor(UIColor(red: 0x6c/255, green: 0xc5/255, blue: 0xee/255, alpha: 1), forState: .Normal)
            userButton.setTitleColor(UIColor(red: 0x1c/255, green: 0x1f/255, blue: 0x21/255, alpha: 1), forState: .Normal)
        } else {
            userButton.setTitleColor(UIColor(red: 0x6c/255, green: 0xc5/255, blue: 0xee/255, alpha: 1), forState: .Normal)
            dreamButton.setTitleColor(UIColor(red: 0x1c/255, green: 0x1f/255, blue: 0x21/255, alpha: 1), forState: .Normal)
        }
    }
    
    func dismissKbd(sender: UITapGestureRecognizer) { //点击界面收键盘
        if !searchText.exclusiveTouch {
            searchText.resignFirstResponder()
        }
    }
    
    @IBAction func dream(sender: AnyObject) {
        index = 0
        dreamPage = 1
        setupButtonColor(index)
        self.dreamTableView.hidden = false
        self.tableView.hidden =  true
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 70)
        })

        if (dreamSearchDataSource.count == 0 && dreamStepDataSource.count == 0) || searchText.text != dreamLastSearch {
            if count(searchText.text) > 0 {
                dreamLastSearch = searchText.text
                self.dreamTableView.headerBeginRefreshing()
                self.onPullDown()
            }
        }
    }
    
    @IBAction func user(sender: AnyObject) {
        index = 1
        userPage = 1
        setupButtonColor(index)
        self.tableView.hidden = false
        self.dreamTableView.hidden = true
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 20)
        })

        if userSearchDataSource.count == 0 || searchText.text != userLastSearch {
            if count(searchText.text) > 0 {
                userLastSearch = searchText.text
                self.tableView.headerBeginRefreshing()
                self.onPullDown()
            }
        }
    }
    
    func clearText(sender: UITapGestureRecognizer) {
        searchText.text = ""
        searchText.rightViewMode = .Never
    }
    
    // MARK: several abstract method

    func userSearch(clear: Bool, callback: Bool -> Void) {
        Api.getSearchUsers(searchText.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, page: userPage++, callback: {
            json in
            var success = false
            
            if json != nil {
                var items = json!["users"] as! NSArray
                
                if (items.count != 0) {
                    if clear {
                        self.userSearchDataSource.removeAll(keepCapacity: true)
                    }
                    
                    success = true
                    
                    for item in items {
                        var userSearchData = UserSearchData()
                        userSearchData.uid = item["uid"] as! String
                        userSearchData.user = item["user"] as! String
                        userSearchData.follow = item["follow"] as! String
                        
                        self.userSearchDataSource.append(userSearchData)
                    }
                }
            }
            self.netResult = true
            callback(success)
        })
    }
    
    func dreamSearch(clear: Bool, callback: Bool -> Void) {
        Api.getSearchDream(searchText.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, page: dreamPage++, callback: {
            json in
            var success = false
            
            if json != nil {
                var items = json!["dreams"] as? NSArray
                var stepItems = json!["steps"] as? NSArray
                
                success = true
                
                if (items != nil && items?.count != 0) {
                    if clear {
                        self.dreamSearchDataSource.removeAll(keepCapacity: true)
                    }
                    
                    for item in items! {
                        var dreamSearchData = DreamSearchData()
                        dreamSearchData.id = item["id"] as? String
                        dreamSearchData.title = item["title"] as? String
                        dreamSearchData.lastdate = item["lastdate"] as? String
                        dreamSearchData.content = item["content"] as? String
                        dreamSearchData.img = item["img"] as? String
                        dreamSearchData.follow = item["follow"] as? String
                        dreamSearchData.uid = item["uid"] as? String
                        dreamSearchData.sid = item["sid"] as? String
                        
                        self.dreamSearchDataSource.append(dreamSearchData)
                    }
                }
                
                if (stepItems != nil && stepItems?.count != 0) {
                    if clear {
                        self.dreamStepDataSource.removeAll(keepCapacity: true)
                    }
                    
                    for item in stepItems! {
                        var stepdata = DreamStepData()
                        stepdata.sid = item["sid"] as! String
                        stepdata.uid = item["uid"] as! String
                        stepdata.user = item["user"] as? String
                        stepdata.content = item["content"] as! String
                        stepdata.lastdate = item["lastdate"] as! String
                        stepdata.title = item["title"] as? String
                        stepdata.img = item["img"] as! String
                        stepdata.img0 = (item["img0"] as! NSNumber).floatValue
                        stepdata.img1 = (item["img1"] as! NSNumber).floatValue
                        stepdata.like = (item["like"] as! NSNumber).integerValue
                        stepdata.liked = (item["liked"] as! NSNumber).integerValue
                        stepdata.comment = (item["comment"] as! NSNumber).integerValue
                        stepdata.follow = item["follow"] as! String
                        
                        self.dreamStepDataSource.append(stepdata)
                        self.dreamStepArray.addObject(item)
                    }
                }
            }
            self.netResult = true
            callback(success)
        })
    }
    
    // MARK: table view delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if netResult {
            if index == 0 {
                if self.dreamSearchDataSource.count != 0 && self.dreamStepDataSource.count != 0 {
                    return 2
                }
            }
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if index == 0{
            if section == 0 {
                return dreamSearchDataSource.count
            } else if section == 1 {
                return dreamStepDataSource.count
            } else {
                return 0
            }
        } else {
            return userSearchDataSource.count
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView()
        
        if netResult {
            if index == 0 {
                if section == 0 {
                    if self.dreamSearchDataSource.count != 0 {
                        view = UIView(frame: CGRectMake(0, 0, globalWidth, 15))
                        view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
                        
                        return view
                    }
                }
            }
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if index == 0 {
            if section == 0 {
                if self.dreamSearchDataSource.count != 0 {
                    return 15
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if !netResult {
            cell = UITableViewCell()
        } else {
            if index == 0 {
                if indexPath.section == 0 {
                    var dreamCell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as? searchResultCell
                    
                    if dreamCell == nil {
                        dreamCell = searchResultCell(style: .Default, reuseIdentifier: "searchResultCell")
                    }
                    
                    dreamCell!.bindData(dreamSearchDataSource[indexPath.row], tableView: tableView)
                    dreamCell!.headImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toDream:"))
                    cell = dreamCell!
                } else if indexPath.section == 1 {
                    var stepCell = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
                    stepCell.labelTime.hidden = true
                    stepCell.labelDream.setWidth(globalWidth - 148)
                    var data = self.dreamStepArray[indexPath.row] as! NSDictionary
                    stepCell.data = data
                    stepCell.indexPathRow = index
                    stepCell.tag = index + 10
                    stepCell.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                    stepCell.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                    stepCell.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
                    stepCell.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick:"))
                    stepCell.imageHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
                    stepCell.btnLike.addTarget(self, action: "onLikeTap:", forControlEvents: UIControlEvents.TouchUpInside)
                    stepCell.btnUnLike.addTarget(self, action: "onUnLikeTap:", forControlEvents: UIControlEvents.TouchUpInside)
                    stepCell.btnLike.tag = index + 10
                    stepCell.btnUnLike.tag = index + 10
                    var followButton = UIButton(frame: CGRectMake(globalWidth - 85, 20, 70, 30))
                    followButton.layer.cornerRadius = 15.0
                    followButton.layer.masksToBounds = true
                    followButton.titleLabel?.font = UIFont.systemFontOfSize(12.0)
                    followButton.addTarget(self, action: "onFollowClick:", forControlEvents: .TouchUpInside)
                    
                    if dreamStepDataSource[indexPath.row].follow == "0" {
                        followButton.tag = 100
                        followButton.layer.borderColor = SeaColor.CGColor
                        followButton.layer.borderWidth = 1
                        followButton.setTitleColor(SeaColor, forState: .Normal)
                        followButton.backgroundColor = .whiteColor()
                        followButton.setTitle("关注", forState: .Normal)
                    } else {
                        followButton.tag = 200
                        followButton.layer.borderWidth = 0
                        followButton.setTitleColor(SeaColor, forState: .Normal)
                        followButton.backgroundColor = SeaColor
                        followButton.setTitle("关注中", forState: .Normal)
                    }
                    stepCell.addSubview(followButton)
                    
                    if indexPath.row == self.dreamStepArray.count - 1 {
                        stepCell.viewLine.hidden = true
                    } else {
                        stepCell.viewLine.hidden = false
                    }
                    cell = stepCell
                    
                } else {
                    cell = UITableViewCell()
                }
            } else {
                var userCell = tableView.dequeueReusableCellWithIdentifier("searchUserResultCell", forIndexPath: indexPath) as? searchUserResultCell
                
                if userCell == nil {
                    userCell = searchUserResultCell(style: .Default, reuseIdentifier: "searchUserResultCell")
                }
                
                userCell!.bindData(userSearchDataSource[indexPath.row], tableview: tableView)
                userCell!.headImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toPlayer:"))
                cell = userCell!
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if netResult {
            if index == 0{
                if indexPath.section == 0 {
                    return 80
                } else {
                    var data = self.dreamStepArray[indexPath.row] as! NSDictionary
                    var height = SAStepCell.cellHeightByData(data)
                    return height
                }
            } else {
                return 71
            }
        }
        
        return 71
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if index == 0 {
//            if indexPath.section == 0 {
//                var viewController = DreamViewController()
//                viewController.Id = dreamSearchDataSource[indexPath.row].id
//                var data = dreamSearchDataSource[indexPath.row]
//                self.navigationController?.pushViewController(viewController, animated: true)
//            } else {
//                var data = self.dreamStepArray[indexPath.row] as! NSDictionary
//                var dream = data.stringAttributeForKey("dream")
//                var dreamVC = DreamViewController()
//                dreamVC.Id = dream
//                self.navigationController!.pushViewController(dreamVC, animated: true)
//            }
//        } else {
//            var playerViewController = PlayerViewController()
//            playerViewController.Id = userSearchDataSource[indexPath.row].uid
//            var data = userSearchDataSource[indexPath.row]
//            self.navigationController?.pushViewController(playerViewController, animated: true)
//        }
//    }
    
    // MARK: text field delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        dreamPage = 1
        userPage = 1
        
        if count(textField.text) > 0 {
            searchText.rightViewMode = .Always
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        
        if searchText.text != "" {
            if index == 0 {
                if searchText.text != dreamLastSearch {
                    self.dreamTableView.headerBeginRefreshing()
                    dreamLastSearch = searchText.text
                    
                    load(index, clear: true) {
                        success in
                        self.dreamTableView.reloadData()
                        self.dreamTableView.headerEndRefreshing(animated: true)
                    }
                }
            } else {
                if searchText.text != userLastSearch {
                    self.tableView.headerBeginRefreshing()
                    userLastSearch = searchText.text
                    
                    load(index, clear: true) {
                        success in
                        self.tableView.reloadData()
                        self.tableView.headerEndRefreshing(animated: true)
                    }
                }
            }
        }
        
        return true
    }
    
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textfield = notification.object as! UITextField
        
        if count(textfield.text) > 0 {
            searchText.rightViewMode = .Always
        } else {
            searchText.rightViewMode = .Never
        }
    }
    
    // MARK: gesture 
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        return  !(touch.view is UITableViewCell)
//    }
//    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    func toPlayer(sender: UITapGestureRecognizer) {
        var playerViewController = PlayerViewController()
        playerViewController.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    func toDream(sender: UITapGestureRecognizer) {
        var viewController = DreamViewController()
        viewController.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onLikeTap(sender: UIButton) {
        var tag = sender.tag - 10
        var data = self.dreamStepArray[tag] as! NSDictionary
        if let numLike = data.stringAttributeForKey("like").toInt() {
            var numNew = numLike + 1
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setValue("\(numNew)", forKey: "like")
            mutableItem.setValue("1", forKey: "liked")
            self.dreamStepArray.replaceObjectAtIndex(tag, withObject: mutableItem)
            self.dreamTableView.reloadData()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "1") { json in
            }
        }
    }
    
    func onUnLikeTap(sender: UIButton) {
        var tag = sender.tag - 10
        var data = self.dreamStepArray[tag] as! NSDictionary
        if let numLike = data.stringAttributeForKey("like").toInt() {
            var numNew = numLike - 1
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setValue("\(numNew)", forKey: "like")
            mutableItem.setValue("0", forKey: "liked")
            self.dreamStepArray.replaceObjectAtIndex(tag, withObject: mutableItem)
            self.dreamTableView.reloadData()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "0") { json in
            }
        }
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view  = self.findTableCell(sender.view)!
        var img = dreamStepArray[view.tag - 10].objectForKey("img") as! String
        var img0 = dreamStepArray[view.tag - 10].objectForKey("img0") as! NSString
        var img1 = dreamStepArray[view.tag - 10].objectForKey("img1") as! NSString
        var yPoint = sender.view!.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!)
        var w = CGFloat(img0.floatValue)
        var h = CGFloat(img1.floatValue)
        if w != 0 {
            h = h * globalWidth / w
            var rect = CGRectMake(-yPoint.x, -yPoint.y, globalWidth, h)
            if let v = sender.view as? UIImageView {
                v.showImage(V.urlStepImage(img, tag: .Large), rect: rect)
            }
        }
    }
    
    func findTableCell(view: UIView?) -> UIView? {
        for var v = view; v != nil; v = v!.superview {
            if v! is UITableViewCell {
                return v
            }
        }
        return nil
    }
    
    func onCommentClick(sender:UIGestureRecognizer){
        var view  = self.findTableCell(sender.view)!
        var dream = dreamStepArray[view.tag - 10].objectForKey("dream") as! String
        var tag = sender.view!.tag
        var DreamCommentVC = DreamCommentViewController()
        var totalComment = SAReplace(( sender.view! as! UILabel ).text!, " 评论", "") as String
        DreamCommentVC.dreamID = dream.toInt()!
        DreamCommentVC.stepID = tag
        DreamCommentVC.dreamowner = 0
        self.navigationController!.pushViewController(DreamCommentVC, animated: true)
    }
    
    func likeclick(sender:UITapGestureRecognizer){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func onFollowClick(sender: UIButton) {
        var tag = sender.tag
        var sid = String((sender.superview as! SAStepCell).sid)
        if tag == 100 {     //没有关注
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(sid, follow: "1", callback: {
                    String in
                    if String == "fo" {
                    } else {
                    }
                })
                
            })
        }else if tag == 200 {   //正在关注
            sender.tag = 100
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(sid, follow: "0", callback: {
                    String in
                    if String == " " {
                    } else {
                    }
                })
            })
        }
        
    }

    
}

