//
//  ExploreProvide.swift
//  Nian iOS
//
//  Created by vizee on 14/11/11.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

@objc protocol ExploreProviderDelegate {
    
    func show()
    func refreshData()
    func loadData()
}

class ExploreFollowProvider: NSObject, UITableViewDelegate, UITableViewDataSource, ExploreProviderDelegate {
    
    class Data {
        
        var id: String!
        var head: String!
        var name: String!
        var dream: String!
        var date: String!
        var image: String!
        var content: String!
        var commentCount: Int!
        var likeCount: Int!
        
        var imageWidth: Float!
        var imageHeight: Float!
        
        var liked = false
    }
    
    weak var bindView: UITableView?
    var page = 0
    var dataSource = [Data]()
    
    init(bindView: UITableView) {
        self.bindView = bindView
    }
    
    func load(callback: () -> Void) {
        Api.getExploreFollow("\(page++)", callback: { json in
            if json != nil {
                var items = json!["items"] as NSArray
                for item in items {
                    var data = Data()
                    data.id = item["id"] as String
                    
                }
                callback()
            }
        })
    }
    
    func show() {
        if dataSource.isEmpty {
            self.refreshData()
        } else {
            self.bindView!.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func refreshData() {
        page = 0
        dataSource.removeAll(keepCapacity: true)
        load({
            if (self.isEqual(self.bindView!.delegate)) {
                self.bindView!.headerEndRefreshing()
                self.bindView!.reloadData()
            }
        })
    }
    
    func loadData() {
        load({
            if (self.isEqual(self.bindView!.delegate)) {
                self.bindView!.footerEndRefreshing()
                self.bindView!.reloadData()
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var data = dataSource[indexPath.row]
        return ExploreDynamicCell.heightWithData(data.content, w: data.imageWidth, h: data.imageHeight)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExploreDynamicCell", forIndexPath: indexPath) as? ExploreDynamicCell
        var data = dataSource[indexPath.row]
        
        return cell!
    }
}

class ExploreDynamicProvider: NSObject, UITableViewDelegate, UITableViewDataSource, ExploreProviderDelegate {
    
    class Data {
        var id: String!
        var head: String!
        var name: String!
        var dream: String!
        var date: String!
        var image: String!
        var content: String!
        var commentCount: Int!
        var likeCount: Int!
        
        var liked = false
    }
    
    weak var bindView: UITableView?
    var page = 0
    var dataSource = [Data]()
    
    init(bindView: UITableView) {
        self.bindView = bindView
    }
    
    func show() {
        if dataSource.isEmpty {
            self.refreshData()
        } else {
            self.bindView!.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func refreshData() {
        page = 0
        dataSource.removeAll(keepCapacity: true)
        loadData()
    }
    
    func loadData() {
        Api.getExploreFollow("\(page++)", callback: { json in
            
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

class ExploreHotProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, ExploreProviderDelegate {
    
    class Data {
        var id: String!
        var head: String!
        var name: String!
        var dream: String!
        var date: String!
        var image: String!
        var content: String!
        var commentCount: Int!
        var likeCount: Int!
    }
    
    weak var bindView: UICollectionView?
    var page = 0
    var dataSource = [Data]()
    
    init(bindView: UICollectionView) {
        self.bindView = bindView
    }
    
    func show() {
        if dataSource.isEmpty {
            self.refreshData()
        } else {
            self.bindView!.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func refreshData() {
        page = 0
        dataSource.removeAll(keepCapacity: true)
        loadData()
    }
    
    func loadData() {
        Api.getExploreFollow("\(page++)", callback: { json in
            
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

class ExploreNewProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, ExploreProviderDelegate {
    
    class Data {
        var id: String!
        var head: String!
        var name: String!
        var dream: String!
        var date: String!
        var image: String!
        var content: String!
        var commentCount: Int!
        var likeCount: Int!
    }
    
    weak var bindView: UICollectionView?
    var page = 0
    var dataSource = [Data]()
    
    init(bindView: UICollectionView) {
        self.bindView = bindView
    }
    
    func show() {
        if dataSource.isEmpty {
            self.refreshData()
        } else {
            self.bindView!.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func refreshData() {
        page = 0
        dataSource.removeAll(keepCapacity: true)
        loadData()
    }
    
    func loadData() {
        Api.getExploreFollow("\(page++)", callback: { json in
            
        })
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}