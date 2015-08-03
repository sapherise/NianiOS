//
//  ExploreSearch.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit
import Foundation

class ExploreSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, delegateSAStepCell{
    var dataArrayUser = NSMutableArray()
    var dataArrayDream = NSMutableArray()
    var dataArrayStep = NSMutableArray()
    
    var preSetSearch: String = ""
    var shouldPerformSearch: Bool = false
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.dreamTableView.hidden = !(index == 0)
        self.tableView.hidden = !self.dreamTableView.hidden
        self.viewBackFix()
        
        
        if count(preSetSearch) > 0 {
            searchText.text = preSetSearch
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.addSubview(searchText)
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            if self.searchText.text != "" {
                self.searchText.rightViewMode = .Always
            } else {
                self.searchText.rightViewMode = .Never
            }
        }
        
        if (count(preSetSearch) > 0 && shouldPerformSearch) {
            if index == 0 {
                self.dreamTableView.headerBeginRefreshing()
            } else {
                self.tableView.headerBeginRefreshing()
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        searchText.removeFromSuperview()
        shouldPerformSearch = false
    }
    
    func load(index: Int, clear: Bool) {
        if index == 0 {
            self.dreamSearch(clear)
        } else {
            self.userSearch(clear)
        }
    }
    
    func onRefresh() {
        load(index, clear: true)
    }
    
    func onLoad() {
        load(index, clear: false)
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
        floatView.backgroundColor = SeaColor
        
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
        searchText.attributedPlaceholder = NSAttributedString(string: "搜索", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFontOfSize(12.0)])
        searchText.contentVerticalAlignment = .Center
        searchText.font = UIFont.systemFontOfSize(12.0)
        searchText.textColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1)
        searchText.returnKeyType = .Search
        searchText.clearsOnBeginEditing = false
        searchText.delegate = self
//        self.navigationController?.navigationBar.addSubview(searchText)
        
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
        dreamTableView.addHeaderWithCallback(onPullDown)
        dreamTableView.addFooterWithCallback(onPullUp)
    }
    
    func setupButtonColor(index: Int) {
        if index == 0 {
            dreamButton.setTitleColor(SeaColor, forState: .Normal)
            userButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        } else {
            userButton.setTitleColor(SeaColor, forState: .Normal)
            dreamButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchText.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text != "" {
            searchText.rightViewMode = .Always
        }
    }
    
    func clearText(sender: UITapGestureRecognizer) {
        searchText.text = ""
        searchText.rightViewMode = .Never
        searchText.becomeFirstResponder()
    }
    
    @IBAction func dream(sender: AnyObject) {
        var tmp = index
        index = 0
        setupButtonColor(index)
        self.dreamTableView.hidden = false
        self.tableView.hidden =  true
        self.tableView.headerEndRefreshing()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 70)
        })
        
        if searchText.text != "" && (dataArrayDream.count + dataArrayStep.count == 0) {
            self.dreamTableView.headerBeginRefreshing()
        } else if tmp == 0 {
            self.dreamTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func user(sender: AnyObject) {
        var tmp = index
        index = 1
        setupButtonColor(1)
        self.tableView.hidden = false
        self.dreamTableView.hidden = true
        self.dreamTableView.headerEndRefreshing()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 20)
        })
        
        if searchText.text != "" && dataArrayUser.count == 0 {
            self.tableView.headerBeginRefreshing()
        } else if tmp == 1 {
            self.tableView.headerBeginRefreshing()
        }
    }
    
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
                var items = json!.objectForKey("users") as? NSArray
                if items != nil {
                    for item in items! {
                        self.dataArrayUser.addObject(item)
                    }
                    if items!.count < 30 {
                        self.tableView.setFooterHidden(true)
                    }
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
                var data: AnyObject? = json!.objectForKey("data")
                var itemsDream = data!.objectForKey("dreams") as? NSArray
                if itemsDream != nil {
                    for item in itemsDream! {
                        self.dataArrayDream.addObject(item)
                    }
                }
                var itemsStep = data!.objectForKey("steps") as? NSArray
                if itemsStep != nil {
                    for item in itemsStep! {
                        self.dataArrayStep.addObject(item)
                    }
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
                var c = dreamTableView.dequeueReusableCellWithIdentifier("SADoubleCell", forIndexPath: indexPath) as! SADoubleCell
                var data = self.dataArrayDream[indexPath.row] as! NSDictionary
                c.data = data
                c.btnMain.tag = indexPath.row
                c.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toDream:"))
                c.btnMain.addTarget(self, action: "onFollowDream:", forControlEvents: UIControlEvents.TouchUpInside)
                if indexPath.row == dataArrayDream.count - 1 {
                    c.viewLine.hidden = true
                }
                return c
            } else {
                var c = dreamTableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
                c.delegate = self
                c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
                c.index = indexPath.row
                if indexPath.row == self.dataArrayStep.count - 1 {
                    c.viewLine.hidden = true
                } else {
                    c.viewLine.hidden = false
                }
                c._layoutSubviews()
                return c
            }
        } else {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("SAUserCell", forIndexPath: indexPath) as? SAUserCell
            var data = self.dataArrayUser[indexPath.row] as! NSDictionary
            cell?.data = data
            cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser:"))
            cell?.btnMain.tag = indexPath.row
            cell?.btnMain.addTarget(self, action: "onFollow:", forControlEvents: UIControlEvents.TouchUpInside)
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if index == 0 {
            if indexPath.section == 1 {
                var index = indexPath.row
                var data = self.dataArrayStep[index] as! NSDictionary
                var dream = data.stringAttributeForKey("dream")
                SADream(dream)
            }
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
        if index == 0 {
            if indexPath.section == 0 {
                return 81
            } else {
                var data = self.dataArrayStep[indexPath.row] as! NSDictionary
                
                return tableView.fd_heightForCellWithIdentifier("SAStepCell", cacheByIndexPath: indexPath, configuration: { cell in
                    (cell as! SAStepCell).celldataSource = self
                    (cell as! SAStepCell).fd_enforceFrameLayout = true
                    (cell as! SAStepCell).data  = data
                    (cell as! SAStepCell).indexPath = indexPath
                })
            }
        } else {
            return 71
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        if searchText.text != "" {
            searchText.rightViewMode = .Always
            if index == 0 {
                self.dreamTableView.headerBeginRefreshing()
            } else {
                self.tableView.headerBeginRefreshing()
            }
        }
        return true
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArrayStep, index, key, value, self.dreamTableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 1, self.dreamTableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.dreamTableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArrayStep, index, self.dreamTableView, 1)
    }
}

extension ExploreSearch: SAStepCellDatasource {
    func saStepCell(indexPath: NSIndexPath, content: String, contentHeight: CGFloat) {
        if index == 0 {
            var _tmpDict = NSMutableDictionary(dictionary: self.dataArrayDream[indexPath.row] as! NSDictionary)
            _tmpDict.setObject(content as NSString, forKey: "content")
            
            #if CGFLOAT_IS_DOUBLE
                _tmpDict.setObject(NSNumber(double: Double(contentHeight)), forKey: "contentHeight")
                #else
                _tmpDict.setObject(NSNumber(float: Float(contentHeight)), forKey: "contentHeight")
            #endif
            
            self.dataArrayDream.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
        }
    }
}



