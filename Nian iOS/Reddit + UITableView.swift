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
        tableViewHot = UITableView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64 - 49))
        tableViewHot.register(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
        tableViewHot.separatorStyle = .none
        let SIZE_EDITOR_TOTAL = SIZE_EDITOR + SIZE_EDITOR_TOP + SIZE_EDITOR_BOTTOM
        tableViewHot.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: SIZE_EDITOR_TOTAL * 2))
        self.view.addSubview(tableViewHot)
        
        // 热门添加推荐
        let labelEditor = UILabel(frame: CGRect(x: 16, y: 24, width: 100, height: 21))
        labelEditor.textColor = UIColor.C33()
        labelEditor.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelEditor.text = "推荐"
        labelEditor.backgroundColor = UIColor.white
        tableViewHot.addSubview(labelEditor)
        
        // 热门添加最新
        let labelNewest = UILabel(frame: CGRect(x: 16, y: 24 + SIZE_EDITOR_TOTAL, width: 100, height: 21))
        labelNewest.textColor = UIColor.C33()
        labelNewest.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelNewest.text = "最新"
        labelNewest.backgroundColor = UIColor.white
        tableViewHot.addSubview(labelNewest)

        // 热门添加分割线
        let viewLineEditor = UIView(frame: CGRect(x: 16, y: SIZE_EDITOR_TOTAL - globalHalf, width: globalWidth - 32, height: globalHalf))
        viewLineEditor.backgroundColor = UIColor.e6()
        tableViewHot.addSubview(viewLineEditor)
        let viewLineNewest = UIView(frame: CGRect(x: 16, y: SIZE_EDITOR_TOTAL * 2 - globalHalf, width: globalWidth - 32, height: globalHalf))
        viewLineNewest.backgroundColor = UIColor.e6()
        tableViewHot.addSubview(viewLineNewest)
        
        // 热门添加更多按钮
        let imageMoreEditor = UIImageView(frame: CGRect(x: globalWidth - 48 - 16, y: 8, width: 48, height: 48))
        imageMoreEditor.image = UIImage(named: "discover_more_48")
        imageMoreEditor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RedditViewController.onEditor)))
        imageMoreEditor.isUserInteractionEnabled = true
        imageMoreEditor.backgroundColor = UIColor.white
        tableViewHot.addSubview(imageMoreEditor)
        let imageMoreNewest = UIImageView(frame: CGRect(x: globalWidth - 48 - 16, y: 8 + SIZE_EDITOR_TOTAL, width: 48, height: 48))
        imageMoreNewest.image = UIImage(named: "discover_more_48")
        imageMoreNewest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RedditViewController.onNewest)))
        imageMoreNewest.isUserInteractionEnabled = true
        imageMoreNewest.backgroundColor = UIColor.white
        tableViewHot.addSubview(imageMoreNewest)

        // 推荐
        tableViewEditor = UITableView()
        tableViewEditor.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI/2))
        tableViewEditor.frame = CGRect(x: 0, y: SIZE_EDITOR_TOP, width: globalWidth, height: SIZE_EDITOR)
        tableViewEditor.separatorStyle = .none
        tableViewEditor.delegate = self
        tableViewEditor.dataSource = self
        tableViewEditor.showsVerticalScrollIndicator = false
        tableViewEditor.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 16))
        tableViewHot.addSubview(tableViewEditor)

        // 最新
        tableViewNewest = UITableView()
        tableViewNewest.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI/2))
        tableViewNewest.frame = CGRect(x: 0, y: SIZE_EDITOR + SIZE_EDITOR_TOP * 2 + SIZE_EDITOR_BOTTOM, width: globalWidth, height: SIZE_EDITOR)
        tableViewNewest.separatorStyle = .none
        tableViewNewest.delegate = self
        tableViewNewest.dataSource = self
        tableViewNewest.showsVerticalScrollIndicator = false
        tableViewNewest.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 16))
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
    
    func load(_ clear: Bool = true) {
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
                        let err = json!.object(forKey: "error") as? NSNumber
                        if err == 0 {
                            let data = json!.object(forKey: "data") as? NSDictionary
                            if data != nil {
                                let d1 = data!.object(forKey: "recommend") as? NSMutableArray
                                for i in d1! {
                                    self.dataArrayEditor.add(i)
                                }
                                let d2 = data!.object(forKey: "newest")
                                let items = (d2! as AnyObject).object(forKey: "items") as! NSMutableArray
                                let promo = (d2! as AnyObject).object(forKey: "promo") as! NSMutableArray
                                for i in promo {
                                    self.dataArrayNewest.add(i)
                                }
                                for i in items {
                                    self.dataArrayNewest.add(i)
                                }
                                self.tableViewEditor.reloadData()
                                self.tableViewNewest.reloadData()
                            }
                        }
                    }
                }
            }
            Api.getExploreNewHot("\(pageHot)", callback: { json in
                if json != nil {
                    let arr = json!.object("data") as! NSArray
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
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewHot {
            let data = dataArrayHot[(indexPath as NSIndexPath).row] as! NSDictionary
            let heightCell = data.object(forKey: "heightCell") as! CGFloat
            return heightCell
        } else {
            return 96
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewHot {
            let c = tableView.dequeueReusableCell(withIdentifier: "ExploreNewHotCell", for: indexPath) as? ExploreNewHotCell
            c!.data = self.dataArrayHot[(indexPath as NSIndexPath).row] as! NSDictionary
            c!.indexPath = indexPath
            c!._layoutSubviews()
            return c!
        } else if tableView == self.tableViewEditor {
            var c = tableViewEditor.dequeueReusableCell(withIdentifier: "NewestCell") as? NewestCell
            if c == nil {
                c = NewestCell(style: .default, reuseIdentifier: "NewestCell")
            }
            if dataArrayEditor.count == 0 {
                c?.data = NSDictionary()
            } else {
                c?.data = dataArrayEditor[(indexPath as NSIndexPath).row] as! NSDictionary
            }
            c!.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2))
            return c!
        } else {
            var c = tableViewNewest.dequeueReusableCell(withIdentifier: "NewestCell") as? NewestCell
            if c == nil {
                c = NewestCell(style: .default, reuseIdentifier: "NewestCell")
            }
            if dataArrayNewest.count == 0 {
                c?.data = NSDictionary()
            } else {
                c?.data = dataArrayNewest[(indexPath as NSIndexPath).row] as! NSDictionary
            }
            c!.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2))
            return c!
        }
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DreamViewController()
        if tableView == self.tableViewHot {
            let data = dataArrayHot[(indexPath as NSIndexPath).row] as! NSDictionary
            vc.Id = tableView != tableViewHot ? data.stringAttributeForKey("dream") : data.stringAttributeForKey("id")
            self.navigationController?.pushViewController(vc, animated: true)
        } else if tableView == self.tableViewEditor || tableView == self.tableViewNewest {
            if dataArrayEditor.count == 0 || dataArrayNewest.count == 0 {
                return
            }
            let d = tableView == self.tableViewEditor ? dataArrayEditor : dataArrayNewest
            let data = d[(indexPath as NSIndexPath).row] as! NSDictionary
            vc.Id = data.stringAttributeForKey("id")
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    func updateData(_ index: Int, key: String, value: String, section: Int) {
        let d = dataArrayHot
        let t = tableViewHot
        SAUpdate(d, index: index, key: key, value: value as AnyObject, tableView: t)
    }
    
    func updateTable() {
        tableViewHot.reloadData()
    }
    
    func deleteCellInTable(_ index: Int) {
        let d = dataArrayHot
        d.removeObject(at: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
