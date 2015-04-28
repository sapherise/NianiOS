//
//  ExploreSearch.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    class DreamSearchData {
        var id: String!
        var title: String!
        var lastdate: String!
        var img: String!
        var sid: String!
    }
    
    class UserSearchData  {
        var uid: String!
        var user: String!
        var follow: String!
    }
    
    class NITextfield: UITextField {
        override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
            return CGRectMake(bounds.origin.x, bounds.origin.y, 25 , 25)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var indiView: UIView!
    @IBOutlet weak var dreamButton: UIButton!
    @IBOutlet weak var userButton: UIButton!

    @IBOutlet weak var floatView: UIView!
    
    var searchText = UITextField()
    var index: Int = 0
    var dreamSearchDataSource = [DreamSearchData]()
    var userSearchDataSource = [UserSearchData]()
    var netResult: Bool = false
    
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
        
        self.navigationController?.navigationBar.addSubview(searchText)
    }

    func load(index: Int, clear: Bool, callback: Bool -> Void) {
        if index == 0 {
            
        } else {
            self.userSearch(callback)
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
                self.tableView.headerBeginRefreshing()
                self.tableView.reloadData()
            } else {
                self.view.showTipText("已经到底了", delay: 1)
            }
        }
    }
    
    func onPullDown() {
        if !netResult {
            self.onRefresh()
        } else {
            self.tableView.headerEndRefreshing(animated: true)
        }
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
        dreamButton.setX(globalWidth/2 - 104)
        userButton.setX(globalWidth/2 + 24)
        floatView.setX(globalWidth/2 - 89)
        //globalWidth/2 + 49
        
        searchText = NITextfield(frame: CGRectMake(30, 10, globalWidth-45, 25))
        searchText.layer.cornerRadius = 12.5
        searchText.layer.masksToBounds = true
        searchText.backgroundColor = UIColor(red: 0x3b/255, green: 0x40/255, blue: 0x44/255, alpha: 1.0)
        searchText.leftViewMode = .Always
        searchText.leftView  = UIImageView(image: UIImage(named: "search"))
        searchText.leftView?.contentMode = .Center
        searchText.placeholder = "点此搜索梦想、用户"
        searchText.font.fontWithSize(24)
        searchText.returnKeyType = .Search
        searchText.clearsOnBeginEditing = true  
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
            self.floatView.setX(globalWidth/2 - 89)
        })
        
        self.tableView.reloadData()
    }
    
    @IBAction func user(sender: AnyObject) {
        index = 1
        setupButtonColor(index)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 39)
        })
        
        self.tableView.reloadData()
    }
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchText.resignFirstResponder()
        searchText.text = ""
    }
    
    func clearAll() {
        
    }
    
    func userSearch(callback: Bool -> Void) {
        Api.getSearchUsers() {
            json in
            var success = false
            
            if json != nil {
                var items = json!["user"] as! NSArray
                
                if items.count != 0 {
                    success = true
                    
                    for item in items {
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
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if index == 0{
            return dreamSearchDataSource.count
        } else {
            return userSearchDataSource.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if !netResult {
            cell = UITableViewCell()
        } else {
            if index == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! searchResultCell
            } else {
                var userCell = tableView.dequeueReusableCellWithIdentifier("searchUserResultCell", forIndexPath: indexPath) as! searchUserResultCell
                userCell.bindData(userSearchDataSource[indexPath.row], tableview: tableView)
                cell = userCell
                
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 71
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.pushViewController(PlayerViewController(), animated: true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.netResult = false
    }

    func textFieldDidEndEditing(textField: UITextField) {
        self.tableView.headerBeginRefreshing()
        self.onPullDown()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        
        return true
    }
}

