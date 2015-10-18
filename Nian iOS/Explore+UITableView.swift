//
//  Explore+UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/10/18.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension ExploreViewController {
    
    func setupTables() {
        
        // 关注
        tableView = VVeboTableView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 49), style: .Plain)
        scrollView.addSubview(tableView)
        currenTableView = tableView
        
        // 动态
        tableViewDynamic = VVeboTableView(frame: CGRectMake(globalWidth, 0, globalWidth, globalHeight - 64 - 49), style: .Plain)
        tableViewDynamic.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        scrollView.addSubview(tableViewDynamic)
        
        // 热门
        tableViewHot = UITableView(frame: CGRectMake(globalWidth * 2, 0, globalWidth, globalHeight - 64 - 49))
        tableViewHot.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
        tableViewHot.separatorStyle = .None
        let SIZE_EDITOR_TOTAL = SIZE_EDITOR + SIZE_EDITOR_TOP + SIZE_EDITOR_BOTTOM
        tableViewHot.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, SIZE_EDITOR_TOTAL * 2))
        scrollView.addSubview(tableViewHot)
        
        // 热门添加推荐
        let labelEditor = UILabel(frame: CGRectMake(16, 24, 100, 21))
        labelEditor.textColor = UIColor.C33()
        labelEditor.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelEditor.text = "推荐"
        tableViewHot.addSubview(labelEditor)
        
        // 热门添加最新
        let labelNewest = UILabel(frame: CGRectMake(16, 24 + SIZE_EDITOR_TOTAL, 100, 21))
        labelNewest.textColor = UIColor.C33()
        labelNewest.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelNewest.text = "最新"
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
        imageMoreEditor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onEditor"))
        imageMoreEditor.userInteractionEnabled = true
        tableViewHot.addSubview(imageMoreEditor)
        let imageMoreNewest = UIImageView(frame: CGRectMake(globalWidth - 48 - 16, 8 + SIZE_EDITOR_TOTAL, 48, 48))
        imageMoreNewest.image = UIImage(named: "discover_more_48")
        imageMoreNewest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onNewest"))
        imageMoreNewest.userInteractionEnabled = true
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
        
        tableView.dataSource = self
        tableView.delegate = self
        tableViewDynamic.dataSource = self
        tableViewDynamic.delegate = self
        tableViewHot.dataSource = self
        tableViewHot.delegate = self
        
        scrollView.scrollsToTop = false
        tableView.scrollsToTop = true
        tableViewDynamic.scrollsToTop = false
        tableViewHot.scrollsToTop = false
        tableViewEditor.scrollsToTop = false
        tableViewNewest.scrollsToTop = false
        
        tableView.addHeaderWithCallback { () -> Void in
            self.load(true)
        }
        tableView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
        tableViewDynamic.addHeaderWithCallback { () -> Void in
            self.loadDynamic(true)
        }
        tableViewDynamic.addFooterWithCallback { () -> Void in
            self.loadDynamic(false)
        }
        
        tableViewHot.addHeaderWithCallback { () -> Void in
            self.loadHot(true)
        }
        tableViewHot.addFooterWithCallback { () -> Void in
            self.loadHot(false)
        }
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreFollow("\(page++)", callback: {
            json in
            if json != nil {
                globalTabhasLoaded[0] = true
                if clear {
                    self.tableView.clearVisibleCell()
                    self.dataArray.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    for item in items {
                        let data = SACell.SACellDataRecode(item as! NSDictionary)
                        self.dataArray.addObject(data)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.tableHeaderView = nil
                } else if clear {
                    self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableView.tableHeaderView?.addGhost("这是关注页面！\n当你关注了一些人或记本时\n这里会发生微妙变化")
                }
                if self.current == 0 {
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func loadDynamic(clear: Bool) {
        if clear {
            pageDynamic = 1
        }
        Api.getExploreDynamic("\(pageDynamic++)", callback: {
            json in
            if json != nil {
                globalTabhasLoaded[1] = true
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    if clear {
                        self.tableViewDynamic.clearVisibleCell()
                        self.dataArrayDynamic.removeAllObjects()
                    }
                    for item in items {
                        let data = SACell.SACellDataRecode(item as! NSDictionary)
                        self.dataArrayDynamic.addObject(data)
                    }
                    self.currentDataArray = self.dataArrayDynamic
                    self.tableViewDynamic.tableHeaderView = nil
                } else if clear {
                    self.tableViewDynamic.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableViewDynamic.tableHeaderView?.addGhost("这是动态页面！\n你关注的人赞过的内容\n都会出现在这里")
                }
                if self.current == 1 {
                    self.tableViewDynamic.headerEndRefreshing()
                    self.tableViewDynamic.footerEndRefreshing()
                    self.tableViewDynamic.reloadData()
                }
            }
        })
    }
    
    func loadHot(clear: Bool) {
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
            Api.getExploreNewHot(page: "\(pageHot++)", callback: { json in
                if json != nil {
                    globalTabhasLoaded[2] = true
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
                    //                if self.bindViewController?.current == 2 {
                    //                    self.bindViewController?.recomTableView.headerEndRefreshing()
                    //                    self.bindViewController?.recomTableView.footerEndRefreshing()
                    //
                    //                    if self.page == 1 || self.page == 2 {
                    //                        self.bindViewController?.recomTableView.beginUpdates()
                    //                        self.bindViewController?.recomTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
                    //                        self.bindViewController?.recomTableView.endUpdates()
                    //                    } else {
                    //                        self.bindViewController?.recomTableView.reloadData()
                    //                    }
                    //                }
                }
            })
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