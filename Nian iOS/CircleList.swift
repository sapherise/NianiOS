//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

var sql_error = ""

class CircleListController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "circle"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var toggle: Bool = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        self.SALoadData()
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll:", name: "Poll", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.setupRefresh()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Poll", object: nil)
    }
    
    func Poll(noti: NSNotification) {
        self.SALoadData()
    }
    
    func addCircleButton(){
        var circleexploreVC = CircleExploreController()
        self.navigationController?.pushViewController(circleexploreVC, animated: true)
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "梦境"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        var rightBarButton = UILabel(frame: CGRectMake(0, 20, 80, 44))
        rightBarButton.text = "发现梦境"
        rightBarButton.setX(globalWidth-80)
        rightBarButton.userInteractionEnabled = true
        rightBarButton.textColor = UIColor.whiteColor()
        rightBarButton.font = UIFont.systemFontOfSize(14)
        rightBarButton.textAlignment = NSTextAlignment.Center
        rightBarButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addCircleButton"))
        navView.addSubview(labelNav)
        navView.addSubview(rightBarButton)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = BGColor
        self.tableView.separatorStyle = .None
        
        var nib = UINib(nibName:"CircleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  81
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var data = self.dataArray[indexPath.row] as! NSDictionary
        var id = data.stringAttributeForKey("id")
        if  id == "0" {
            onBBSClick()
        }else{
            SQLCircleListDelete(id)
            delay(0.2, { () -> () in
                self.SALoadData()
            })
        }
    }
    
    func onBBSClick(){
        var BBSVC = ExploreController()
        self.navigationController?.pushViewController(BBSVC, animated: true)
    }
    
    func SALoadData() {
        if toggle {
            toggle = false
            go {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                sql_error = "内存错误，重启应用试试"
                let (resultCircle, errCircle) = SD.executeQuery("SELECT circle FROM `circle` where owner = '\(safeuid)' GROUP BY circle ORDER BY lastdate DESC")
                if errCircle != nil {
                    back {
//                        self.view.showTipText(sql_error, delay: 3)
                        self.tableView.headerEndRefreshing()
                    }
                    return
                }
                self.dataArray.removeAllObjects()
                for row in resultCircle {
                    var id = (row["circle"]?.asString())!
                    var img = ""
                    var title = "梦境"
                    let (resultDes, err) = SD.executeQuery("select * from circlelist where circleid = '\(id)' and owner = '\(safeuid)' limit 1")
                    if resultDes.count > 0 {
                        for row in resultDes {
                            img = (row["image"]?.asString())!
                            title = (row["title"]?.asString())!
                        }
                    }
                    var data = NSDictionary(objects: [id, img, title], forKeys: ["id", "img", "title"])
                    self.dataArray.addObject(data)
                }
                var dataBBS = NSDictionary(objects: ["0", "0", "0"], forKeys: ["id", "img", "title"])
                self.dataArray.addObject(dataBBS)
                back {
                    self.tableView.reloadData()
                    self.tableView.headerEndRefreshing()
                    if self.dataArray.count == 1 {
                        var NibCircleCell = NSBundle.mainBundle().loadNibNamed("CircleCell", owner: self, options: nil) as NSArray
                        var viewTop = NibCircleCell.objectAtIndex(0) as! CircleCell
                        viewTop.labelTitle.text = "发现梦境"
                        viewTop.labelContent.text = "和大家一起组队造梦"
                        viewTop.labelCount.hidden = true
                        viewTop.lastdate?.hidden = true
                        viewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBtnGoClick"))
                        viewTop.userInteractionEnabled = true
                        viewTop.imageHead.setImage("http://img.nian.so/dream/1_1420533592.png!dream", placeHolder: IconColor)
                        viewTop.tag = 1
                        viewTop.editing = false
                        self.tableView.tableHeaderView = viewTop
                    }else{
                        self.tableView.tableHeaderView = nil
                    }
                    self.toggle = true
                }
            }
        }
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback {
            self.SALoadData()
        }
    }
    
    func onBtnGoClick() {
        var circleexploreVC = CircleExploreController()
        self.navigationController?.pushViewController(circleexploreVC, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? CircleCell
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        c!.data = data
        cell = c!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var data = self.dataArray[indexPath.row] as! NSDictionary
        var id = data.objectForKey("id") as! String
        var title = data.objectForKey("title") as! String
        var CircleVC = CircleController()
        if id != "0" {
            var theID = id.toInt()!
            CircleVC.ID = theID
            CircleVC.circleTitle = title
            self.navigationController?.pushViewController(CircleVC, animated: true)
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            SD.executeChange("update circle set isread = 1 where circle = \(theID) and isread = 0 and owner = \(safeuid)")
            self.SALoadData()
        }else{
            onBBSClick()
        }
    }
}