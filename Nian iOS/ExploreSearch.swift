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
    var dataArrayUser = NSMutableArray()
    var dataArrayDream = NSMutableArray()
    var dataArrayStep = NSMutableArray()
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
    var dreamStepArray = NSMutableArray()
    var dreamLastSearch: String = ""
    var userLastSearch: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        searchText.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //index = 0, dream table view 应该显示
        self.dreamTableView.hidden = !(index == 0)
        self.tableView.hidden = !self.dreamTableView.hidden
        self.viewBackFix()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.navigationController?.navigationBar.addSubview(searchText)
    }
    
    func load(index: Int, clear: Bool) {
        if index == 0 {
            self.dreamSearch(clear)
        } else {
            self.userSearch(clear)
        }
    }
    
    func onRefresh() {
        if self.index == 0 {
            load(index, clear: true)
        } else {
            load(index, clear: true)
        }
    }
    
    func onLoad() {
        if index == 0 {
            load(index, clear: false)
        } else {
            load(index, clear: false)
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
        self.dreamTableView.registerNib(UINib(nibName: "SADoubleCell", bundle: nil), forCellReuseIdentifier: "SADoubleCell")
        self.dreamTableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        
        self.tableView.registerNib(UINib(nibName: "SAUserCell", bundle: nil), forCellReuseIdentifier: "SAUserCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.dreamTableView.delegate = self
        self.dreamTableView.dataSource = self
        
        tableView.setHeight(globalHeight - 104)
        tableView.setWidth(globalWidth)
        dreamTableView.setHeight(globalHeight - 104)
        dreamTableView.setWidth(globalWidth)
        navView.setWidth(globalWidth)
        indiView.setWidth(globalWidth)
        dreamButton.setX(globalWidth/2 - 85)
        userButton.setX(globalWidth/2 + 5)
        floatView.setX(globalWidth/2 - 70)
        
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchText.resignFirstResponder()
    }
    
    func dismissKbd(sender: UITapGestureRecognizer) { //点击界面收键盘
        if !searchText.exclusiveTouch {
            searchText.resignFirstResponder()
        }
    }
    
    @IBAction func dream(sender: AnyObject) {
        index = 0
        setupButtonColor(index)
        self.dreamTableView.hidden = false
        self.tableView.hidden =  true
        self.tableView.headerEndRefreshing()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 70)
        })
        
        if (self.dataArrayDream.count == 0 && self.dataArrayStep.count == 0) || searchText.text != dreamLastSearch {
            if count(searchText.text) > 0 {
                dreamLastSearch = searchText.text
                self.dreamTableView.headerBeginRefreshing()
            }
        }
    }
    
    @IBAction func user(sender: AnyObject) {
        index = 1
        setupButtonColor(index)
        self.tableView.hidden = false
        self.dreamTableView.hidden = true
        self.dreamTableView.headerEndRefreshing()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 20)
        })
        
        if self.dataArrayUser.count == 0 || searchText.text != userLastSearch {
            if count(searchText.text) > 0 {
                userLastSearch = searchText.text
                self.tableView.headerBeginRefreshing()
            }
        }
    }
    
    func clearText(sender: UITapGestureRecognizer) {
        searchText.text = ""
        searchText.rightViewMode = .Never
    }
    
    // MARK: several abstract method
    
    func userSearch(clear: Bool) {
        if clear {
            userPage = 1
        }
        Api.getSearchUsers(searchText.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, page: userPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayUser.removeAllObjects()
                }
                var items = json!["users"] as! NSArray
                for item in items {
                    self.dataArrayUser.addObject(item)
                }
                if items.count < 30 {
                    self.tableView.setFooterHidden(true)
                }
            }
            self.tableView.reloadData()
            self.tableView.headerEndRefreshing()
            self.tableView.footerEndRefreshing()
        })
    }
    
    func dreamSearch(clear: Bool) {
        if clear {
            dreamPage = 1
        }
        Api.getSearchDream(searchText.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, page: dreamPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayDream.removeAllObjects()
                    self.dataArrayStep.removeAllObjects()
                }
                var itemsDream = json!["dreams"] as! NSArray
                var itemsStep = json!["steps"] as! NSArray
                for item in itemsDream {
                    self.dataArrayDream.addObject(item)
                }
                for item in itemsStep {
                    self.dataArrayStep.addObject(item)
                }
            }
            self.dreamTableView.reloadData()
            self.dreamTableView.headerEndRefreshing()
            self.dreamTableView.footerEndRefreshing()
        })
    }
    
    // MARK: table view delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if index == 0 {
            if self.dataArrayDream.count != 0 && self.dataArrayStep.count != 0 {
                return 2
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if index == 0{
            if section == 0 {
                return self.dataArrayDream.count
            } else if section == 1 {
                return self.dataArrayStep.count
            } else {
                return 0
            }
        } else {
            return self.dataArrayUser.count
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if index == 0 {
            if section == 0 {
                if self.dataArrayDream.count != 0 {
                    var viewFooter = UIView(frame: CGRectMake(0, 0, globalWidth, 15))
                    viewFooter.backgroundColor = IconColor
                    return viewFooter
                }
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if index == 0 {
            if section == 0 {
                if self.dataArrayDream.count != 0 {
                    return 15
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if index == 0 {
            if indexPath.section == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("SADoubleCell", forIndexPath: indexPath) as? SADoubleCell
                var data = self.dataArrayDream[indexPath.row] as! NSDictionary
                cell?.data = data
                cell?.btnMain.tag = indexPath.row
                cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toDream:"))
                cell?.btnMain.addTarget(self, action: "onFollowDream:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell!
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as? SAStepCell
                var index = indexPath.row
                cell?.data = self.dataArrayStep[index] as! NSDictionary
                cell?.tag = index + 10
                cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser:"))
                cell?.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser:"))
                cell?.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toLike:"))
                cell?.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toComment:"))
                cell?.btnLike.addTarget(self, action: "onLikeTap:", forControlEvents: UIControlEvents.TouchUpInside)
                cell?.btnUnLike.addTarget(self, action: "onUnLikeTap:", forControlEvents: UIControlEvents.TouchUpInside)
                cell?.labelComment.tag = index
                cell?.btnLike.tag = index + 10
                cell?.btnUnLike.tag = index + 10
                if index == self.dataArrayStep.count - 1 {
                    cell?.viewLine.hidden = true
                } else {
                    cell?.viewLine.hidden = false
                }
                return cell!
            }
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("SAUserCell", forIndexPath: indexPath) as? SAUserCell
            var data = self.dataArrayUser[indexPath.row] as! NSDictionary
            cell?.data = data
            cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser:"))
            cell?.btnMain.tag = indexPath.row
            cell?.btnMain.addTarget(self, action: "onFollow:", forControlEvents: UIControlEvents.TouchUpInside)
            return cell!
        }
    }
    
    func toLike(sender: UIGestureRecognizer) {
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(LikeVC, animated: true)
    }
    
    func toComment(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            var data = self.dataArrayStep[tag] as! NSDictionary
            println(data)
            var id = data.stringAttributeForKey("dream")
            var sid = data.stringAttributeForKey("sid")
            var uid = data.stringAttributeForKey("uid")
            var dreamCommentVC = DreamCommentViewController()
            dreamCommentVC.dreamID = id.toInt()!
            dreamCommentVC.stepID = sid.toInt()!
            var UserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = UserDefaults.objectForKey("uid") as! String
            dreamCommentVC.dreamowner = uid == safeuid ? 1 : 0
            self.navigationController?.pushViewController(dreamCommentVC, animated: true)
        }
    }
    
    func toUser(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            SAUser("\(tag)")
        }
    }
    
    func toDream(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            SADream("\(tag)")
        }
    }
    
    func onFollowDream(sender: UIButton) {
        var tag = sender.tag
        var data = self.dataArrayDream[tag] as! NSDictionary
        var id = data.stringAttributeForKey("id")
        var follow = data.stringAttributeForKey("follow")
        var newFollow = follow == "0" ? "1" : "0"
        var mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(newFollow, forKey: "follow")
        self.dataArrayDream[tag] = mutableData
        self.dreamTableView.reloadData()
        //todo
        Api.postFollowDream(id, follow: newFollow) { json in
        }
    }
    
    func onFollow(sender: UIButton) {
        var tag = sender.tag
        var data = self.dataArrayUser[tag] as! NSDictionary
        var uid = data.stringAttributeForKey("uid")
        var follow = data.stringAttributeForKey("follow")
        var newFollow = follow == "0" ? "1" : "0"
        var mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(newFollow, forKey: "follow")
        self.dataArrayUser[tag] = mutableData
        self.tableView.reloadData()
        if follow == "1" {
            Api.postUnfollow(uid) { string in
            }
        } else {
            Api.postFollow(uid, follow: 1) { string in
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if index == 0{
            if indexPath.section == 0 {
                return 81
            } else {
                var data = self.dataArrayStep[indexPath.row] as! NSDictionary
                var height = SAStepCell.cellHeightByData(data)
                return height
            }
        } else {
            return 71
        }
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
        if count(textField.text) > 0 {
            searchText.rightViewMode = .Always
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        
        if searchText.text != "" {
            if index == 0 {
                self.dreamTableView.headerBeginRefreshing()
                dreamLastSearch = searchText.text
            } else {
                self.tableView.headerBeginRefreshing()
                userLastSearch = searchText.text
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

