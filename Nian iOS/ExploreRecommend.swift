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
    
    //
    var listDataArray = NSMutableArray()
    var page = 1
    var lastID = "0"
    
    // 编辑推荐数据源
    var editorRecommArray = NSMutableArray()
    // 最新的数据源
    var latestArray = NSMutableArray()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.recomTableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        
        Api.getDiscoverTop() {
            json in
            
            if json != nil {
                var err = json!.objectForKey("error") as? NSNumber
                if err == 0 {
                    var data = json!.objectForKey("data") as? NSDictionary
                    if data != nil {
                        if let _editorArray = data!.objectForKey("recommend") as? NSMutableArray {
                            self.editorRecommArray = _editorArray
                            
                            if self.editorRecommArray.count > 0 {
                                self.bindViewController?.recomTableView.beginUpdates()
                                self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                                self.bindViewController?.recomTableView.endUpdates()
                            }
                        }
                        
                        if let _latestArray = data!.objectForKey("newest") as? NSMutableArray {
                            self.latestArray = _latestArray
                            
                            if self.latestArray.count > 0 {
                                self.bindViewController?.recomTableView.beginUpdates()
                                self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                                self.bindViewController?.recomTableView.endUpdates()
                                
                            }
                        }
                    }

                }  // if err != nil
            }  // if json != nil
        }
        
        
        Api.getExploreNewHot("\(lastID)", page: "\(page++)", callback: {
            json in
            if json != nil {
                globalTab[2] = false
                var arr = json!.objectForKey("items") as! NSArray
                if clear {
                    self.listDataArray.removeAllObjects()
                }
                for data: AnyObject in arr {
                    self.listDataArray.addObject(data)
                }
                if self.bindViewController?.current == 2 {
                    self.bindViewController?.recomTableView.headerEndRefreshing()
                    self.bindViewController?.recomTableView.footerEndRefreshing()
                    
                    self.bindViewController?.recomTableView.beginUpdates()
                    self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
                    self.bindViewController?.recomTableView.endUpdates()
                    
//                    self.bindViewController?.recomTableView.reloadData()
                }
                var count = self.listDataArray.count
                if count >= 1 {
                    var data = self.listDataArray[count - 1] as! NSDictionary
                    self.lastID = data.stringAttributeForKey("sid")
                }
            }
        })
    }
    
    
    override func onHide() {
        bindViewController!.recomTableView.headerEndRefreshing(animated: false)
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.recomTableView.reloadData()
        
        if listDataArray.count == 0 {
            bindViewController!.recomTableView.headerBeginRefreshing()
        } else {
            if loading {
                UIView.animateWithDuration(0.2,
                    animations: { () -> Void in
                        self.bindViewController!.recomTableView.setContentOffset(CGPointZero, animated: false)
                    }, completion: { (Bool) -> Void in
                        self.bindViewController!.recomTableView.headerBeginRefreshing()
                })
            }
        }
    }
    
    override func onRefresh() {
        page = 1
        self.lastID = "0"
        load(true)
    }
    
    override func onLoad() {
        load(false)
    }
    
   
}


extension ExploreRecommend: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        
        return self.listDataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return 185
        }
        
        return 200
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            
            
        } else if indexPath.section == 0 {
            var recomCell = tableView.dequeueReusableCellWithIdentifier("EditorRecomCell", forIndexPath: indexPath) as! EditorRecomCell
            recomCell.data = self.editorRecommArray
            recomCell._layoutSubview()
            
            return recomCell
        } else if indexPath.section == 1 {
            var latestCell = tableView.dequeueReusableCellWithIdentifier("LatestNoteCell", forIndexPath: indexPath) as! LatestNoteCell
            latestCell.data = self.latestArray
            latestCell._layoutSubview()
            
            return latestCell
        }
        
        var cell = UITableViewCell()
        
        return cell
    }
}
