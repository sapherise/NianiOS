//
//  Reddit + RedditDelegate.swift
//  Nian iOS
//
//  Created by Sa on 15/8/29.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

extension RedditViewController: RedditDelegate {
    func updateData(index: Int, key: String, value: String) {
        var d = current == 0 ? dataArrayLeft : dataArrayRight
        var t = current == 0 ? tableViewLeft : tableViewRight
        SAUpdate(d, index, key, value, t)
    }
    
    func updateTable() {
        var t = current == 0 ? tableViewLeft : tableViewRight
        t.reloadData()
    }
}