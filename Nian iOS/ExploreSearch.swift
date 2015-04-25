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
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var dreamButton: UIButton!
    
    @IBOutlet weak var verticalLine: UIView!
    @IBOutlet weak var seperateLine: UIView!
    
    var index: Int = 0
    var dataSource = [Data]()
    var netResult: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        self.searchText.delegate = self
    }

    func load(clear: Bool, callback: Bool -> Void) {
    
        
        
    
    }

    
    
    func setupView() {
        setupButtonColor(index)
        
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
        self.searchText.placeholder = "search dream"
        
        self.tableView.reloadData()
    }
    
    @IBAction func user(sender: AnyObject) {
        index = 1
        setupButtonColor(index)
        self.searchText.placeholder = "search user"
        
        self.tableView.reloadData()
    }
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchText.resignFirstResponder()
        searchText.text = ""
    }
    
    func clearAll() {
        
       println("干活")
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
//            button.titleLabel!.text = "全部清空"
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
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("searchHistoryCell", forIndexPath: indexPath) as! searchHistoryCell
            }
        } else {
            if index == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! searchResultCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("searchUserResultCell", forIndexPath: indexPath) as! searchUserResultCell
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
