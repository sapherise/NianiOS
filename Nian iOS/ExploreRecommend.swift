//
//  ExploreRecommend.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/17/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreRecommend: ExploreProvider {
    
    weak var bindViewController: ExploreViewController?
    var listDataArray = NSMutableArray()
    var page = 1
    var lastID = "0"
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.recomTableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
    }
   
}


extension ExploreRecommend: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        
        return self.listDataArray.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        return cell
    }
}
