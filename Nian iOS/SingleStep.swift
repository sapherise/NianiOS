//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SingleStepViewController: VVeboViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate {
    
    var tableView: VVeboTableView!
    var dataArray = NSMutableArray()
    var Id:String = "1"
    var navView:UIView!
    var name: String?   // 从消息进入后自动@
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func setupViews() {
        self.viewBack()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView = VVeboTableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.tableView)
        
        currenTableView = tableView
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "进展"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    
    func SAReloadData(){
        Api.getSingleStep(self.Id) { json in
            if json != nil {
                self.tableView.clearVisibleCell()
                self.dataArray.removeAllObjects()
                let data = json!.objectForKey("data") as! NSDictionary
                let hidden = data.stringAttributeForKey("hidden")
                if hidden == "1" {
                    self.tableView?.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableView?.tableHeaderView?.addGhost("这条进展\n不见了")
                } else {
                    let d = VVeboCell.SACellDataRecode(data)
                    self.dataArray.addObject(d)
                }
                self.currentDataArray = self.dataArray
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getCell(indexPath, dataArray: dataArray, type: 1)
    }
    
    func onComment(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            let data = dataArray[tag] as! NSDictionary
            let id = data.stringAttributeForKey("dream")
            let sid = data.stringAttributeForKey("sid")
            let uid = data.stringAttributeForKey("uid")
            let vc = DreamCommentViewController()
            vc.dreamID = Int(id)!
            vc.stepID = Int(sid)!
            vc.dreamowner = uid == SAUid() ? 1 : 0
            vc.name = name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return getHeight(indexPath, dataArray: dataArray)
    }
    
    func Editstep() {
        self.SAReloadData()
    }
   
    func countUp(coin: String, isfirst: String){
        self.SAReloadData()
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
}



