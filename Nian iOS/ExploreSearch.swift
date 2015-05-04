//
//  ExploreSearch.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

    class DreamSearchData {
        var id: String!
        var title: String!
        var lastdate: String!
        var content: String!
        var img: String!
        var sid: String!
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
    }
    
    
    class NITextfield: UITextField {
        override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectMake(bounds.origin.x, bounds.origin.y, 25 , 25)
        }
        
        override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectMake(bounds.size.width - 19, (bounds.size.height - 12)/2, 12, 12)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var indiView: UIView!
    @IBOutlet weak var dreamButton: UIButton!
    @IBOutlet weak var userButton: UIButton!

    @IBOutlet weak var floatView: UIView!
    
    var searchText = NITextfield()
    var index: Int = 0
    var dreamPage: Int = 0
    var userPage: Int = 0
    var dreamSearchDataSource = [DreamSearchData]()
    var dreamStepDataSource = [DreamStepData]()
    var userSearchDataSource = [UserSearchData]()
    var netResult: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "DreamSearchStepCell", bundle: nil), forCellReuseIdentifier: "dreamSearchStepCell")
        setupView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        searchText.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.addSubview(searchText)
    }

    func load(index: Int, clear: Bool, callback: Bool -> Void) {
        if index == 0 {
            self.dreamSearch(clear, callback: callback)
        } else {
            self.userSearch(clear, callback: callback)
        }
    }
    
    func onRefresh() {
        load(index, clear: true) {
            success in
            self.tableView.headerBeginRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func onLoad() {
        load(index, clear: false) {
            success in
            
            if success {
                self.tableView.footerBeginRefreshing()
                self.tableView.reloadData()
            } else {
                self.view.showTipText("已经到底啦", delay: 1)
                self.tableView.footerEndRefreshing(animated: true)
            }
        }
    }
    
    func onPullDown() {
//        if !netResult {
//            self.onRefresh()
//        } else {
//            self.tableView.headerEndRefreshing(animated: true)
//        }
        self.onRefresh()
    }
    
    func onPullUp() {
        self.onLoad()
    }
    
    func setupView() {
        viewBack()
        
        setupButtonColor(index)
        
        tableView.setHeight(globalHeight - 104)
        navView.setWidth(globalWidth)
        indiView.setWidth(globalWidth)
        dreamButton.setX(globalWidth/2 - 85)
        userButton.setX(globalWidth/2 + 5)
        floatView.setX(globalWidth/2 - 70)
        //globalWidth/2 + 49
        
        searchText = NITextfield(frame: CGRectMake(44, 8, globalWidth-60, 25))
        var color = UIColor(red: 0xd8/255, green: 0xd8/255, blue: 0xd8/255, alpha: 1)
        searchText.layer.cornerRadius = 12.5
        searchText.layer.masksToBounds = true
        searchText.backgroundColor = UIColor(red: 0x3b/255, green: 0x40/255, blue: 0x44/255, alpha: 1.0)
        searchText.leftViewMode = .Always
        searchText.leftView  = UIImageView(image: UIImage(named: "search"))
        searchText.leftView?.contentMode = .Center
        searchText.rightViewMode = .WhileEditing
        searchText.rightView = UIImageView(image: UIImage(named: "close-1"))
        searchText.rightView!.contentMode = .Center
        searchText.rightView!.userInteractionEnabled = true
        searchText.rightView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clearText:"))
        searchText.attributedPlaceholder = NSAttributedString(string: "点此搜索梦想、用户", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFontOfSize(12.0)])
        searchText.contentVerticalAlignment = .Center
        searchText.font = UIFont.systemFontOfSize(12.0)
        searchText.textColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1)
        searchText.returnKeyType = .Search
        searchText.clearsOnBeginEditing = true
        searchText.clearButtonMode = .WhileEditing
        self.navigationController?.navigationBar.addSubview(searchText)
        
        searchText.delegate = self
        
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
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
    
    @IBAction func dream(sender: AnyObject) {
        index = 0
        setupButtonColor(index)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 70)
        })

        if count(searchText.text) > 0 {
            self.onPullDown()
        }
    }
    
    @IBAction func user(sender: AnyObject) {
        index = 1
        setupButtonColor(index)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 20)
        })

        if count(searchText.text) > 0 {
           self.onPullDown()
        }
        
    }
    
    func clearText(sender: UITapGestureRecognizer) {
        searchText.text = ""
    }
    
    // MARK: several abstract method
    
    func clearAll() {
        
    }
    
    func userSearch(clear: Bool, callback: Bool -> Void) {
        Api.getSearchUsers(searchText.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, page: userPage++) {
//        Api.getSearchUsers() {
            json in
            var success = false
            
            if json != nil {
                var items = json!["users"] as? NSArray
                
                if (items != nil && items!.count != 0) {
                    if clear {
                        self.userSearchDataSource.removeAll(keepCapacity: true)
                    }
                    
                    success = true
                    
                    for item in items! {
                        var userSearchData = UserSearchData()
                        userSearchData.uid = item["uid"] as! String
                        userSearchData.user = item["user"] as! String
                        userSearchData.follow = item["follow"] as! String
                        
                        self.userSearchDataSource.append(userSearchData)
                    }
                }
                callback(success)
                self.netResult = true
                self.tableView.headerEndRefreshing(animated: true)
                self.tableView.footerEndRefreshing(animated: true)
                self.tableView.reloadData()
            }
            
        }
    }
    
    func dreamSearch(clear: Bool, callback: Bool -> Void) {
        Api.getSearchDream(searchText.text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, page: dreamPage++) {
//        Api.getSearchDream() {
            json in
            var success = false
            
            if json != nil {
                var items = json!["dreams"] as? NSArray
                var stepItems = json!["steps"] as? NSArray
                
                if (items != nil && items?.count != 0) {
//                    if clear {
                        self.dreamSearchDataSource.removeAll(keepCapacity: true)
//                    }
                    
                    for item in items! {
                        var dreamSearchData = DreamSearchData()
//                        dreamSearchData.sid = item["sid"] as! String
                        dreamSearchData.id = item["id"] as? String
                        dreamSearchData.title = item["title"] as? String
//                        dreamSearchData.content = item["content"] as! String
                        dreamSearchData.lastdate = item["lastdate"] as? String
                        dreamSearchData.img = item["img"] as? String
                        
                        self.dreamSearchDataSource.append(dreamSearchData)
                    }
                }
                
                if (stepItems != nil && stepItems?.count != 0) {
                    if clear {
                        self.dreamStepDataSource.removeAll(keepCapacity: true)
                    }
                    
                    for item in stepItems! {
                        var stepdata = DreamStepData()
                        stepdata.sid = item["sid"] as? String
                        stepdata.uid = item["uid"] as? String
                        stepdata.user = item["user"] as? String
                        stepdata.content = item["content"] as? String
                        stepdata.lastdate = item["lastdate"] as? String
//                        stepdata.title = item["title"] as! String
                        stepdata.img = item["img"] as? String
                        stepdata.img0 = (item["img0"] as? NSString)?.floatValue
                        stepdata.img1 = (item["img1"] as? NSString)?.floatValue
                        stepdata.like = (item["like"] as? String)?.toInt()
                        stepdata.liked = (item["liked"] as? String)?.toInt()
                        stepdata.comment = (item["comment"] as? String)?.toInt()
                        
                        self.dreamStepDataSource.append(stepdata)
                    }
                }
                
                success = (items?.count != 0 && stepItems?.count != 0)
                
                callback(success)
                self.netResult = true
                self.tableView.headerEndRefreshing(animated: true)
                self.tableView.footerEndRefreshing(animated: true)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: table view delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if netResult {
            if index == 0 {
                return 2
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if !netResult {
            cell = UITableViewCell()
        } else {
            if index == 0 {
                if indexPath.section == 0 {
                    var dreamCell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! searchResultCell
                    dreamCell.bindData(dreamSearchDataSource[indexPath.row], tableView: tableView)
                    cell = dreamCell
                } else if indexPath.section == 1 {
                    var stepCell = tableView.dequeueReusableCellWithIdentifier("dreamSearchStepCell", forIndexPath: indexPath) as! dreamSearchStepCell
                    stepCell.bindData(dreamStepDataSource[indexPath.row], tableview: tableView)
                    cell = stepCell
                } else {
                    cell = UITableViewCell()
                }
            } else {
                var userCell = tableView.dequeueReusableCellWithIdentifier("searchUserResultCell", forIndexPath: indexPath) as! searchUserResultCell
                userCell.bindData(userSearchDataSource[indexPath.row], tableview: tableView)
                userCell.userData = self.userSearchDataSource[indexPath.row] as ExploreSearch.UserSearchData   
                cell = userCell
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
                    var tmpData = dreamStepDataSource[indexPath.row]
                    var height = dreamSearchStepCell.heightWithData(tmpData.content, w: tmpData.img0, h: tmpData.img1)
                    
                    return height
                }
            } else {
                return 71
            }
        }
        
        return 71
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if index == 0 {
            
            
            
        } else {
            var playerViewController = PlayerViewController()
            playerViewController.Id = userSearchDataSource[indexPath.row].uid
            var data = userSearchDataSource[indexPath.row]
            self.navigationController?.pushViewController(playerViewController, animated: true)
        }
    }
    
    // MARK: text field delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.userSearchDataSource.removeAll(keepCapacity: false)
        self.dreamSearchDataSource.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        
        self.netResult = false
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if searchText.text != "" {
            self.tableView.headerBeginRefreshing()
            self.onPullDown()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        
        return true
    }
}

