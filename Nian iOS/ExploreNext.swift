//
//  ExploreNext.swift
//  Nian iOS
//
//  Created by Sa on 15/9/21.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

protocol DreamSelectedDelegate {
    func dreamSelected(_ id: String, title: String, content: String, image: String)
}

class ExploreNext: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    var type = 0    // 0 为
    var arrType = ["推荐", "最新", "插入记本", "赞过的记本", "关注的记本"]
    var dataArray = NSMutableArray()
    var collectionView: UICollectionView!
    var page = 1
    var delegate: DreamSelectedDelegate?
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle(arrType[type])
        
        let flowLayout = UICollectionViewFlowLayout()
        
        let Q = 3
        let x = (globalWidth - CGFloat(80 * Q))/CGFloat(2 * (Q + 1))
        let y = x + x
        
        flowLayout.minimumInteritemSpacing = x
        flowLayout.minimumLineSpacing = y
        flowLayout.itemSize = CGSize(width: 80, height: 120)
        flowLayout.sectionInset = UIEdgeInsets(top: y, left: y, bottom: y, right: y)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        self.collectionView.register(UINib(nibName: "ExploreMoreCell", bundle: nil), forCellWithReuseIdentifier: "ExploreMoreCell")
        collectionView.addHeaderWithCallback { () -> Void in
            self.load()
        }
        collectionView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
        collectionView.headerBeginRefreshing()
    }
    
    func load(_ clear: Bool = true) {
        if !isLoading {
            isLoading = true
            if clear {
                page = 1
            }
            // 推荐
            if type == 0 {
                Api.getDiscoverEditorRecom("\(page)") { json in
                    if json != nil {
                        if let j = json as? NSDictionary {
                            let error = j.stringAttributeForKey("error")
                            if error == "0" {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                let arr = json!.object(forKey: "data") as! NSArray
                                for d in arr {
                                    let data = self.getDataEncode(d as AnyObject)
                                    self.dataArray.add(data!)
                                }
                                self.collectionView.reloadData()
                                self.collectionView.headerEndRefreshing()
                                self.collectionView.footerEndRefreshing()
                                self.page += 1
                                self.isLoading = false
                            }
                        }
                    }
                }
            } else if type == 1 {
                Api.getDiscoverLatest("\(page)") { json in
                    if json != nil {
                        if let j = json as? NSDictionary {
                            let error = j.stringAttributeForKey("error")
                            if error == "0" {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                let arr = json!.object(forKey: "data") as! NSArray
                                for d in arr {
                                    let data = self.getDataEncode(d as AnyObject)
                                    self.dataArray.add(data!)
                                }
                                self.collectionView.reloadData()
                                self.collectionView.headerEndRefreshing()
                                self.collectionView.footerEndRefreshing()
                                self.page += 1
                                self.isLoading = false
                            }
                        }
                    }
                }
            } else if type == 2 {
                if let NianDreams = Cookies.get("NianDreams") as? NSMutableArray {
                    for data in NianDreams {
                        let d = data as! NSDictionary
                        let image = d.stringAttributeForKey("img")
                        let _private = d.stringAttributeForKey("private")
                        if _private == "0" {
                            let mutableData = NSMutableDictionary(dictionary: d)
                            mutableData.setValue(image, forKey: "image")
                            let _mutableData = self.getDataEncode(mutableData)
                            dataArray.add(_mutableData!)
                        }
                    }
                }
                self.collectionView.headerEndRefreshing()
                self.collectionView.footerEndRefreshing()
                self.collectionView.reloadData()
                isLoading = false
            } else if type == 3 {
                Api.getMyLikeDreams("\(page)") { json in
                    if json != nil {
                        if let j = json as? NSDictionary {
                            let error = j.stringAttributeForKey("error")
                            if error == "0" {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                let arr = json!.object(forKey: "data") as! NSArray
                                for d in arr {
                                    let data = self.getDataEncode(d as AnyObject)
                                    self.dataArray.add(data!)
                                }
                                self.collectionView.reloadData()
                                self.collectionView.headerEndRefreshing()
                                self.collectionView.footerEndRefreshing()
                                self.page += 1
                                self.isLoading = false
                            }
                        }
                    }
                }
            } else if type == 4 {
                Api.getMyFollowDreams("\(page)") { json in
                    if json != nil {
                        if let j = json as? NSDictionary {
                            let error = j.stringAttributeForKey("error")
                            if error == "0" {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                let arr = json!.object(forKey: "data") as! NSArray
                                for d in arr {
                                    let data = self.getDataEncode(d as AnyObject)
                                    self.dataArray.add(data!)
                                }
                                self.collectionView.reloadData()
                                self.collectionView.headerEndRefreshing()
                                self.collectionView.footerEndRefreshing()
                                self.page += 1
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreMoreCell", for: indexPath) as! ExploreMoreCell
        c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let DreamVC = DreamViewController()
        let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let title = data.stringAttributeForKey("title")
        var lastdate = data.stringAttributeForKey("lastdate")
        let image = data.stringAttributeForKey("image")
        lastdate = V.relativeTime(lastdate)
        if id != "0" && id != "" {
            DreamVC.Id = id
            if type == 2 {
                delegate?.dreamSelected(id, title: title, content: lastdate, image: image)
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                _ = self.navigationController?.pushViewController(DreamVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView && type == 1 {
            let a = scrollView.contentOffset.y + globalHeight - 64
            let b = scrollView.contentSize.height
            if a + 400 > b {
                collectionView.footerBeginRefreshing()
            }
        }
    }
    
    func getDataEncode(_ d: AnyObject) -> NSMutableDictionary? {
        if let _d = d as? NSDictionary {
            let data = NSMutableDictionary(dictionary: _d)
            let title = _d.stringAttributeForKey("title").decode()
            let heightTitle = title.stringHeightWith(14, width: 80)
            data["title"] = title
            data["heightTitle"] = heightTitle
            return data
        }
        return nil
    }
}
