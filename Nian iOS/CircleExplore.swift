//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleExploreController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "circleexplore"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page: Int = 1
    var Id:String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    func setupViews() {
        self.viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"CircleExploreCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "发现梦境"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func load(clear: Bool = true){
        if clear {
            self.tableView!.setFooterHidden(false)
            self.page = 1
        }
        Api.getCircleExplore(page){ json in
            if json != nil {
                var arr = json!.objectForKey("data") as! NSArray
                if clear {
                    self.dataArray.removeAllObjects()
                }
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
                self.tableView.footerEndRefreshing()
                self.page++
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? CircleExploreCell
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        c!.data = data
        if indexPath.row == self.dataArray.count - 1 {
            c!.viewLine.hidden = true
        }else{
            c!.viewLine.hidden = false
        }
        cell = c!
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        return CircleExploreCell.cellHeightByData(data)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var data = self.dataArray[indexPath.row] as! NSDictionary
        var id = data.objectForKey("id") as! String
        var circledetailVC = CircleDetailController()
        circledetailVC.Id = id
        self.navigationController?.pushViewController(circledetailVC, animated: true)
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.load()
        })
        self.tableView!.addFooterWithCallback({
            self.load(clear: false)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
}
