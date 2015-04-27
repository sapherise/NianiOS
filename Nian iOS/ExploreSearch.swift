//
//  ExploreSearch.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    class Data {
    
    }
   
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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navView: UIView!
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var dreamButton: UIButton!
    
    @IBOutlet weak var verticalLine: UIView!
    @IBOutlet weak var seperateLine: UIView!
    
    var index: Int = 0
    var dataSource = [Data]()
    var dreamSearchDataSource = [DreamSearchData]()
    var userSearchDataSource = [UserSearchData]()
    var netResult: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        self.searchText.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navView.hidden = false
    }

    func load(clear: Bool, callback: Bool -> Void) {
        
    }
    
    func load(index: Int, clear: Bool, callback: Bool -> Void) {
        if index == 0 {
            
        } else {
            Api.getSearchUsers() {
                json in
                var success = false
                
                if json != nil {
                    var items = json!["user"] as! NSArray
                    
                    if items.count != 0 {
                        if clear {
                            self.userSearchDataSource.removeAll(keepCapacity: true)
                        }
                        success = true
                        
                        for item in items {
                            var userSearchData = UserSearchData()
                            userSearchData.uid = item["uid"] as! String
                            userSearchData.user = item["user"] as! String
                            userSearchData.follow = item["follow"] as! String
                        }
                        
                    }
                    
                }
                
                
            }
        }
        
    }

    
    
    func setupView() {
        setupButtonColor(index)
        
//        self.navView.setX(globalWidth)
        self.searchText.setWidth(globalWidth - 98)
        self.searchText.leftViewMode = .Always
        self.searchText.leftView = UIImageView(image: UIImage(named: "search"))
        self.seperateLine.setWidth(globalWidth)
        self.verticalLine.setX(globalWidth/2)
        self.dreamButton.setX(globalWidth/4 - dreamButton.width()/2)
        self.userButton.setX(globalWidth/4*3 - userButton.width()/2)
        self.cancelButton.setX(globalWidth - 52)
    }
    
    func setupButtonColor(index: Int) {
        if index != 0 {
            userButton.setTitleColor(nil, forState:.Normal)
            dreamButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        } else  {
            dreamButton.setTitleColor(nil, forState:.Normal)
            userButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
    }
    
    @IBAction func dream(sender: AnyObject) {
        index = 0
        setupButtonColor(index)
        self.searchText.placeholder = "搜索梦想"
        
        self.tableView.reloadData()
    }
    
    @IBAction func user(sender: AnyObject) {
        index = 1
        setupButtonColor(index)
        self.searchText.placeholder = "搜索用户"
        
        self.tableView.reloadData()
    }
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchText.resignFirstResponder()
        searchText.text = ""
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func clearAll() {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView
        headerView = UIView(frame: CGRectMake(0, 0, globalWidth, 22))
        headerView.backgroundColor = UIColor.lightGrayColor()
        
        if index == 0 {
            if section == 0 {
                var label = UILabel()
                label.text = "标签"
                label.frame = CGRectMake(10, 0, 100, 22)
                headerView.addSubview(label)
                
                var result = UILabel(frame: CGRectMake(globalWidth - 110, 0, 100, 22))
                result.text = "多少条"
                headerView.addSubview(result)
            } else {
            }
        } else {
            var label = UILabel(frame: CGRectMake(10, 0, 100, 22))
            label.text = "历史记录"
            headerView.addSubview(label)
            
            var button = UIButton(frame: CGRectMake(globalWidth - 110, 0, 100, 22))
            button.setTitle("全部清空", forState: .Normal)
            button.addTarget(self, action: "clearAll", forControlEvents: .TouchUpInside)
            headerView.addSubview(button)
        }
        
       return headerView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if !netResult {
            if index == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as! searchCell
                
//                cell = dreamCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("searchHistoryCell", forIndexPath: indexPath) as! searchHistoryCell
            }
        } else {
            if index == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! searchResultCell
                
        
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("searchUserResultCell", forIndexPath: indexPath) as! searchUserResultCell
//                userCell.bindData(userSearchDataSource[indexPath.row], tableview: tableView)
                
                
//                cell = userCell
                
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
//        self.searchText.becomeFirstResponder()
        //取消原来的联网查询
        
    }

    func textFieldDidEndEditing(textField: UITextField) {
//        self.searchText.resignFirstResponder()
        //查询
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        
        return true
    }
}
