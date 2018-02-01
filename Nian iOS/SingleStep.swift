//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SingleStepViewController: VVeboViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate {
    
    var tableView: VVeboTableView!
    var dataArray = NSMutableArray()
    var Id:String = "1"
    var navView:UIView!
    var name: String?   // 从消息进入后自动@
    
    var newEditStepRow: Int = 0
    var newEditStepData: NSDictionary?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func setupViews() {
        self.viewBack()
        
        self.navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.white
        
        self.tableView = VVeboTableView(frame:CGRect(x: 0, y: 64, width: globalWidth,height: globalHeight - 64))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(self.tableView)
        
        currenTableView = tableView
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.white
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.text = "进展"
        titleLabel.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLabel
    }
    
    
    func SAReloadData(){
        Api.getSingleStep(self.Id) { json in
            if json != nil {
                if let j = json as? NSDictionary {
                    self.dataArray.removeAllObjects()
                    let arr = j.object(forKey: "data")
                    let error = j.stringAttributeForKey("error")
                    if error == "0" {
                        let data = (arr! as AnyObject).object(forKey: "step") as! NSDictionary
                        let hidden = data.stringAttributeForKey("hidden")
                        if hidden == "0" {
                            let d = VVeboCell.SACellDataRecode(data)
                            self.dataArray.add(d)
                        } else {
                            self.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 49 - 64))
                            self.tableView?.tableHeaderView?.addGhost("这条进展\n不见了")
                        }
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView!.reloadData()
                    self.tableView!.headerEndRefreshing()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = getCell(indexPath, dataArray: dataArray, type: 1)
        (c as VVeboCell).labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SingleStepViewController.onComment)))
        return c
    }
    
    func onComment() {
        if dataArray.count > 0 {
            let data = dataArray[0] as! NSDictionary
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeight(indexPath, dataArray: dataArray)
    }

    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
}

//extension SingleStepViewController: NewAddStepDelegate {
//    
//    func newEditstep() {
//        self.SAReloadData()
//    }
//    
//    func newCountUp(coin: String, isfirst: String) {
//        self.SAReloadData()
//    }
//    
//}



