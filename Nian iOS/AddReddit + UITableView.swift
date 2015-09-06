////
////  AddReddit + UITableView.swift
////  Nian iOS
////
////  Created by Sa on 15/9/1.
////  Copyright © 2015年 Sa. All rights reserved.
////
//
//import Foundation
//extension AddReddit: UITableViewDelegate, UITableViewDataSource {
//    func setupTableView() {
//        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64 - 44))
//        tableView.backgroundColor = SeaColor
//        tableView.delegate = self
//        tableView.dataSource = self
////        tableView.separatorStyle = .None
//        tableView.registerNib(UINib(nibName: "AddRedditCell", bundle: nil), forCellReuseIdentifier: "AddRedditCell")
//        self.view.addSubview(tableView)
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let c = tableView.dequeueReusableCellWithIdentifier("AddRedditCell", forIndexPath: indexPath)
//        return c
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return globalHeight - 64 - 44
//    }
//}