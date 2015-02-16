//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleListController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "circle"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll:", name: "Poll", object: nil)
        self.SALoadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Poll", object: nil)
    }
    
    func Poll(noti: NSNotification) {
        self.SALoadData()
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "梦境"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = BGColor
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"CircleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView)
    }
    
    func onBBSClick(){
        var BBSVC = ExploreController()
        self.navigationController?.pushViewController(BBSVC, animated: true)
    }
    
    func SALoadData() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        let (resultCircle, errCircle) = SD.executeQuery("SELECT circle FROM `circle` where owner = '\(safeuid)' GROUP BY circle ORDER BY lastdate DESC")
        self.dataArray.removeAllObjects()
        for row in resultCircle {
            var id = (row["circle"]?.asString())!
            var img = ""
            var title = "梦境 #\(id)"
            let (resultDes, err) = SD.executeQuery("select * from circlelist where circleid = '\(id)' and owner = '\(safeuid)' limit 1")
            if resultDes.count > 0 {
                for row in resultDes {
                    img = (row["image"]?.asString())!
                    title = (row["title"]?.asString())!
                }
            }else{
                Api.getCircleTitle(id) { json in
                    if json != nil {
                        img = json!["img"] as String
                        title = json!["title"] as String
                        SD.executeChange("insert into circlelist(id, circleid, title, image, postdate, owner) values (null, ?, ?, ?, '0', ?)", withArgs: [id, title, img, safeuid])
                        delay(0.2, { () -> () in
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        })
                    }
                }
            }
            var data = NSDictionary(objects: [id, img, title], forKeys: ["id", "img", "title"])
            self.dataArray.addObject(data)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            if self.dataArray.count == 0 {
                var NibCircleCell = NSBundle.mainBundle().loadNibNamed("CircleCell", owner: self, options: nil) as NSArray
                var viewTop = NibCircleCell.objectAtIndex(0) as CircleCell
                viewTop.labelTitle.text = "发现梦境"
                viewTop.labelContent.text = "和大家一起组队造梦"
                viewTop.labelCount.hidden = true
                viewTop.lastdate?.hidden = true
                viewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBtnGoClick"))
                viewTop.userInteractionEnabled = true
                viewTop.imageHead.setImage("http://img.nian.so/dream/1_1420533592.png!dream", placeHolder: IconColor)
                self.tableView.tableHeaderView = viewTop
            }else{
                self.tableView.tableHeaderView = UIView()
            }
            // 预设广场
            var NibCircleCell = NSBundle.mainBundle().loadNibNamed("CircleCell", owner: self, options: nil) as NSArray
            var viewBottom = NibCircleCell.objectAtIndex(0) as CircleCell
            viewBottom.setHeight(81 + 50)
            viewBottom.labelTitle.text = "广场"
            viewBottom.labelContent.text = "念的留言板"
            viewBottom.labelCount.hidden = true
            viewBottom.lastdate?.hidden = true
            viewBottom.imageHead.setImage("http://img.nian.so/dream/1_1420533664.png!dream", placeHolder: IconColor)
            viewBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBBSClick"))
            viewBottom.userInteractionEnabled = true
            self.tableView.tableFooterView = viewBottom
        })
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
        var data = self.dataArray[index] as NSDictionary
        c!.data = data
        cell = c!
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return  81
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var data = self.dataArray[indexPath.row] as NSDictionary
        self.tableView.reloadData()
        var id = data.objectForKey("id") as String
        var title = data.objectForKey("title") as String
        var CircleVC = CircleController()
        CircleVC.ID = id.toInt()!
        CircleVC.circleTitle = title
        self.navigationController?.pushViewController(CircleVC, animated: true)
    }
}