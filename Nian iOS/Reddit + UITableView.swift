//
//  Reddit + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
extension RedditViewController {
    
    func setupTable() {
        
        // 热门
        tableViewHot = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        tableViewHot.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
        tableViewHot.separatorStyle = .None
        let SIZE_EDITOR_TOTAL = SIZE_EDITOR + SIZE_EDITOR_TOP + SIZE_EDITOR_BOTTOM
        tableViewHot.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, SIZE_EDITOR_TOTAL * 2))
        self.view.addSubview(tableViewHot)
        
        // 热门添加推荐
        let labelEditor = UILabel(frame: CGRectMake(16, 24, 100, 21))
        labelEditor.textColor = UIColor.C33()
        labelEditor.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelEditor.text = "推荐"
        labelEditor.backgroundColor = UIColor.whiteColor()
        tableViewHot.addSubview(labelEditor)
        
        // 热门添加最新
        let labelNewest = UILabel(frame: CGRectMake(16, 24 + SIZE_EDITOR_TOTAL, 100, 21))
        labelNewest.textColor = UIColor.C33()
        labelNewest.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelNewest.text = "最新"
        labelNewest.backgroundColor = UIColor.whiteColor()
        tableViewHot.addSubview(labelNewest)

        // 热门添加分割线
        let viewLineEditor = UIView(frame: CGRectMake(16, SIZE_EDITOR_TOTAL - globalHalf, globalWidth - 32, globalHalf))
        viewLineEditor.backgroundColor = UIColor.e6()
        tableViewHot.addSubview(viewLineEditor)
        let viewLineNewest = UIView(frame: CGRectMake(16, SIZE_EDITOR_TOTAL * 2 - globalHalf, globalWidth - 32, globalHalf))
        viewLineNewest.backgroundColor = UIColor.e6()
        tableViewHot.addSubview(viewLineNewest)
        
        // 热门添加更多按钮
        let imageMoreEditor = UIImageView(frame: CGRectMake(globalWidth - 48 - 16, 8, 48, 48))
        imageMoreEditor.image = UIImage(named: "discover_more_48")
        imageMoreEditor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RedditViewController.onEditor)))
        imageMoreEditor.userInteractionEnabled = true
        imageMoreEditor.backgroundColor = UIColor.whiteColor()
        tableViewHot.addSubview(imageMoreEditor)
        let imageMoreNewest = UIImageView(frame: CGRectMake(globalWidth - 48 - 16, 8 + SIZE_EDITOR_TOTAL, 48, 48))
        imageMoreNewest.image = UIImage(named: "discover_more_48")
        imageMoreNewest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RedditViewController.onNewest)))
        imageMoreNewest.userInteractionEnabled = true
        imageMoreNewest.backgroundColor = UIColor.whiteColor()
        tableViewHot.addSubview(imageMoreNewest)

        // 推荐
        tableViewEditor = UITableView()
        tableViewEditor.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tableViewEditor.frame = CGRectMake(0, SIZE_EDITOR_TOP, globalWidth, SIZE_EDITOR)
        tableViewEditor.separatorStyle = .None
        tableViewEditor.delegate = self
        tableViewEditor.dataSource = self
        tableViewEditor.showsVerticalScrollIndicator = false
        tableViewEditor.tableHeaderView = UIView(frame: CGRectMake(0, 0, 1, 16))
        tableViewHot.addSubview(tableViewEditor)

        // 最新
        tableViewNewest = UITableView()
        tableViewNewest.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tableViewNewest.frame = CGRectMake(0, SIZE_EDITOR + SIZE_EDITOR_TOP * 2 + SIZE_EDITOR_BOTTOM, globalWidth, SIZE_EDITOR)
        tableViewNewest.separatorStyle = .None
        tableViewNewest.delegate = self
        tableViewNewest.dataSource = self
        tableViewNewest.showsVerticalScrollIndicator = false
        tableViewNewest.tableHeaderView = UIView(frame: CGRectMake(0, 0, 1, 16))
        tableViewHot.addSubview(tableViewNewest)
        
        tableViewHot.dataSource = self
        tableViewHot.delegate = self
        
        tableViewHot.scrollsToTop = true
        tableViewEditor.scrollsToTop = false
        tableViewNewest.scrollsToTop = false

        tableViewHot.addHeaderWithCallback { () -> Void in
            self.load(true)
        }
        tableViewHot.addFooterWithCallback { () -> Void in
            self.load(false)
        }
    }
    
    func load(clear: Bool = true) {
        if !isLoadingHot {
            isLoadingHot = true
            if clear {
                pageHot = 1
            }
            
            if pageHot == 1 {
                dataArrayEditor.removeAllObjects()
                dataArrayNewest.removeAllObjects()
                Api.getDiscoverTop() { json in
                    if json != nil {
                        let err = json!.objectForKey("error") as? NSNumber
                        if err == 0 {
                            let data = json!.objectForKey("data") as? NSDictionary
                            if data != nil {
                                let d1 = data!.objectForKey("recommend") as? NSMutableArray
                                for i in d1! {
                                    self.dataArrayEditor.addObject(i)
                                }
                                let d2 = data!.objectForKey("newest")
                                let items = d2!.objectForKey("items") as! NSMutableArray
                                let promo = d2!.objectForKey("promo") as! NSMutableArray
                                for i in promo {
                                    self.dataArrayNewest.addObject(i)
                                }
                                for i in items {
                                    self.dataArrayNewest.addObject(i)
                                }
                                self.tableViewEditor.reloadData()
                                self.tableViewNewest.reloadData()
                            }
                        }
                    }
                }
            }
            Api.getExploreNewHot(page: "\(pageHot)", callback: { json in
                if json != nil {
                    let arr = json!.objectForKey("data") as! NSArray
                    if clear {
                        self.dataArrayHot.removeAllObjects()
                    }
                    for data: AnyObject in arr {
                        let dBefore = data as! NSDictionary
                        let d = NSMutableDictionary(dictionary: data as! NSDictionary)
                        let content = dBefore.stringAttributeForKey("content").decode()
                        let title = dBefore.stringAttributeForKey("title").decode()
                        let hTitle = title.stringHeightBoldWith(18, width: 248)
                        var hContent = content.stringHeightWith(12, width: 248)
                        hContent = min(hContent, 43)
                        var height = hContent + 204.5 + hTitle
                        if content == "" {
                            height = hTitle + 204.5 - 8
                        }
                        d["heightCell"] = height
                        d["heightContent"] = hContent
                        d["heightTitle"] = hTitle
                        d["content"] = content
                        d["title"] = title
                        self.dataArrayHot.addObject(d)
                    }
                    self.tableViewHot.headerEndRefreshing()
                    self.tableViewHot.footerEndRefreshing()
                    self.tableViewHot.reloadData()
                    self.isLoadingHot = false
                    self.pageHot += 1
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableViewHot {
            let data = dataArrayHot[indexPath.row] as! NSDictionary
            let heightCell = data.objectForKey("heightCell") as! CGFloat
            return heightCell
        } else {
            return 96
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var d = dataArrayHot
        if tableView == self.tableViewHot {
            d = dataArrayHot
        } else if tableView == self.tableViewEditor {
            d = dataArrayEditor
            if dataArrayEditor.count == 0 {
                return 6
            }
        } else if tableView == self.tableViewNewest {
            d = dataArrayNewest
            if dataArrayNewest.count == 0 {
                return 6
            }
        }
        return d.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableViewHot {
            let c = tableView.dequeueReusableCellWithIdentifier("ExploreNewHotCell", forIndexPath: indexPath) as? ExploreNewHotCell
            c!.data = self.dataArrayHot[indexPath.row] as! NSDictionary
            c!.indexPath = indexPath
            c!._layoutSubviews()
            return c!
        } else if tableView == self.tableViewEditor {
            var c = tableViewEditor.dequeueReusableCellWithIdentifier("NewestCell") as? NewestCell
            if c == nil {
                c = NewestCell(style: .Default, reuseIdentifier: "NewestCell")
            }
            if dataArrayEditor.count == 0 {
                c?.data = NSDictionary()
            } else {
                c?.data = dataArrayEditor[indexPath.row] as! NSDictionary
            }
            c!.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            return c!
        } else {
            var c = tableViewNewest.dequeueReusableCellWithIdentifier("NewestCell") as? NewestCell
            if c == nil {
                c = NewestCell(style: .Default, reuseIdentifier: "NewestCell")
            }
            if dataArrayNewest.count == 0 {
                c?.data = NSDictionary()
            } else {
                c?.data = dataArrayNewest[indexPath.row] as! NSDictionary
            }
            c!.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            return c!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = DreamViewController()
        if tableView == self.tableViewHot {
            let data = dataArrayHot[indexPath.row] as! NSDictionary
            vc.Id = tableView != tableViewHot ? data.stringAttributeForKey("dream") : data.stringAttributeForKey("id")
            self.navigationController?.pushViewController(vc, animated: true)
        } else if tableView == self.tableViewEditor || tableView == self.tableViewNewest {
            if dataArrayEditor.count == 0 || dataArrayNewest.count == 0 {
                return
            }
            let d = tableView == self.tableViewEditor ? dataArrayEditor : dataArrayNewest
            let data = d[indexPath.row] as! NSDictionary
            vc.Id = data.stringAttributeForKey("id")
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    func updateData(index: Int, key: String, value: String, section: Int) {
        let d = dataArrayHot
        let t = tableViewHot
        SAUpdate(d, index: index, key: key, value: value, tableView: t)
    }
    
    func updateTable() {
        tableViewHot.reloadData()
    }
    
    func deleteCellInTable(index: Int) {
        let d = dataArrayHot
        d.removeObjectAtIndex(index)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableViewHot {
            let y = tableViewHot.contentOffset.y + tableViewHot.height()
            let height = tableViewHot.contentSize.height
            if y + 400 > height && dataArrayHot.count > 0 {
                tableViewHot.footerBeginRefreshing()
            }
        }
    }
    
    func onEditor() {
        let vc = ExploreNext()
        vc.type = 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onNewest() {
        let vc = ExploreNext()
        vc.type = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}