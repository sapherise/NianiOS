//
//  Topic.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class TopicViewController: SAViewController {
    var tableView: UITableView!
    var id: String = ""
    var page: Int = 1
    var dataArray = NSMutableArray()
    var dataArrayTop: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViews()
    }
    
    func setupViews() {
        _setTitle("话题")
    }
}