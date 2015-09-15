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
    var latestDict = NSMutableDictionary()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.recomTableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        
        if page == 1 {
            Api.getDiscoverTop() {
                json in
                
                if json != nil {
                    let err = json!.objectForKey("error") as? NSNumber
                    if err == 0 {
                        let data = json!.objectForKey("data") as? NSDictionary
                        if data != nil {
                            
                            if let _editorArray = data!.objectForKey("recommend") as? NSMutableArray {
                                self.editorRecommArray = _editorArray
                                
                                if self.editorRecommArray.count > 0 {
                                    self.bindViewController?.recomTableView.beginUpdates()
                                    self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                                    self.bindViewController?.recomTableView.endUpdates()
                                }
                            }
                            
                            if let _latestDict = data!.objectForKey("newest") as? NSMutableDictionary {
                                self.latestDict = _latestDict
                                
                                if self.latestDict.count > 0 {
                                    self.bindViewController?.recomTableView.beginUpdates()
                                    self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                                    self.bindViewController?.recomTableView.endUpdates()
                                    
                                }
                            }
                        }

                    }  // if err != nil
                }  // if json != nil
            }
        } // if page == 1
        
        Api.getExploreNewHot(page: "\(page++)", callback: {
            json in
            if json != nil {
                globalTab[2] = false
                let arr = json!.objectForKey("data") as! NSArray
                if clear {
                    self.listDataArray.removeAllObjects()
                }
                for data: AnyObject in arr {
                    self.listDataArray.addObject(data)
                }
                if self.bindViewController?.current == 2 {
                    self.bindViewController?.recomTableView.headerEndRefreshing()
                    self.bindViewController?.recomTableView.footerEndRefreshing()
                    
                    if self.page == 1 || self.page == 2 {
                        self.bindViewController?.recomTableView.beginUpdates()
                        self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
                        self.bindViewController?.recomTableView.endUpdates()
                    } else {
                        self.bindViewController?.recomTableView.reloadData()
                    }
                }
                let count = self.listDataArray.count
                if count >= 1 {
                    let data = self.listDataArray[count - 1] as! NSDictionary
                    self.lastID = data.stringAttributeForKey("sid")
                }
            }
        })
    }
    
    
    override func onHide() {
        bindViewController!.recomTableView.headerEndRefreshing(false)
    }
    
    override func onShow(loading: Bool) {
//        bindViewController!.recomTableView.reloadData()
        
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
        if section == 2 {
            return self.listDataArray.count
        }else if section == 0 || section == 1 {
            return 1
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            let index = indexPath.row
            let data = self.listDataArray[index] as! NSDictionary
            
            return tableView.fd_heightForCellWithIdentifier("ExploreNewHotCell", cacheByIndexPath: indexPath, configuration: {
                cell in
                (cell as! ExploreNewHotCell).cellDataSource = self
                (cell as! ExploreNewHotCell).fd_enforceFrameLayout = true
                (cell as! ExploreNewHotCell).data = data
                (cell as! ExploreNewHotCell).indexPath = indexPath
            })
            
        } else if indexPath.section == 0 || indexPath.section == 1 {
            if isiPhone6 || isiPhone6P {
                return 202
            }
            return 185
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            logVerbose("&&&&&&&&&&&&&&&&&&&& \(indexPath.row) ++++++++++++")
            return 364
        } else {
            if isiPhone6 || isiPhone6P {
                return 202
            }
            return 185
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ExploreNewHotCell", forIndexPath: indexPath) as? ExploreNewHotCell
            cell!.data = self.listDataArray[indexPath.row] as! NSDictionary
            
            logInfo("========================= \(indexPath.row) ")
            
            if indexPath.row == self.listDataArray.count - 1 {
                cell!.viewLine.hidden = true
            } else {
                cell!.viewLine.hidden = false
            }
            cell!._layoutSubviews()
            
            return cell!
        } else if indexPath.section == 0 {
            let recomCell = tableView.dequeueReusableCellWithIdentifier("EditorRecomCell", forIndexPath: indexPath) as! EditorRecomCell
            recomCell.data = self.editorRecommArray
            recomCell.collectionView.setContentOffset(CGPointMake(0, 0), animated: false)
            recomCell._layoutSubview()
            
            return recomCell
        } else if indexPath.section == 1 {
            let latestCell = tableView.dequeueReusableCellWithIdentifier("LatestNoteCell", forIndexPath: indexPath) as! LatestNoteCell
            latestCell.data = self.latestDict
            latestCell._layoutSubview()
            
            return latestCell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 || indexPath.section == 1 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let DreamVC = DreamViewController()
            DreamVC.Id = (self.listDataArray[indexPath.row] as! NSDictionary)["id"] as! String
            
            self.bindViewController?.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }
    
}

extension ExploreRecommend: ENHCDataSource {
    func enhcDataCell(indexPath: NSIndexPath, content: String, title: String) {
        let _tmpDict = NSMutableDictionary(dictionary: self.listDataArray[indexPath.row] as! NSDictionary)
        _tmpDict.setObject(content, forKey: "content")
        _tmpDict.setObject(title, forKey: "title")

        self.listDataArray.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
    }
    
    func enhcDataCell(indexPath: NSIndexPath, contentHeight: CGFloat, titleHeight: CGFloat) {
        let _tmpDict = NSMutableDictionary(dictionary: self.listDataArray[indexPath.row] as! NSDictionary)
        
        #if CGFLOAT_IS_DOUBLE
        _tmpDict.setObject(NSNumber(double: Double(titleHeight)), forKey: "titleHeight")
        _tmpDict.setObject(NSNumber(double: Double(contentHeight)), forKey: "contentHeight")
        #else
        _tmpDict.setObject(NSNumber(float: Float(titleHeight)), forKey: "titleHeight")
        _tmpDict.setObject(NSNumber(float: Float(contentHeight)), forKey: "contentHeight")
        #endif
        
        self.listDataArray.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
    }
}
















