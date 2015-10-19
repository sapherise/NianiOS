//
//  ExploreNext.swift
//  Nian iOS
//
//  Created by Sa on 15/9/21.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

protocol DreamSelectedDelegate {
    func dreamSelected(id: String, title: String, content: String, image: String)
}

class ExploreNext: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    var type = 0    // 0 为
    var arrType = ["推荐", "最新", "插入记本"]
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
        
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        self.collectionView.registerNib(UINib(nibName: "ExploreMoreCell", bundle: nil), forCellWithReuseIdentifier: "ExploreMoreCell")
        collectionView.addHeaderWithCallback { () -> Void in
            self.load()
        }
        collectionView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
        collectionView.headerBeginRefreshing()
    }
    
    func load(clear: Bool = true) {
        if !isLoading {
            isLoading = true
            if clear {
                page = 1
            }
            // 推荐
            if type == 0 {
                Api.getDiscoverEditorRecom("\(page)") { json in
                    if json != nil {
                        let error = json!.objectForKey("error") as! NSNumber
                        if error == 0 {
                            if clear {
                                self.dataArray.removeAllObjects()
                            }
                            let arr = json!.objectForKey("data") as! NSArray
                            for d in arr {
                                let data = self.getDataEncode(d)
                                self.dataArray.addObject(data!)
                            }
                            self.collectionView.reloadData()
                            self.collectionView.headerEndRefreshing()
                            self.collectionView.footerEndRefreshing()
                            self.page++
                            self.isLoading = false
                        }
                    }
                }
            } else if type == 1 {
                Api.getDiscoverLatest("\(page)") { json in
                    if json != nil {
                        let error = json!.objectForKey("error") as! NSNumber
                        if error == 0 {
                            if clear {
                                self.dataArray.removeAllObjects()
                            }
                            let arr = json!.objectForKey("data") as! NSArray
                            for d in arr {
                                let data = self.getDataEncode(d)
                                self.dataArray.addObject(data!)
                            }
                            self.collectionView.reloadData()
                            self.collectionView.headerEndRefreshing()
                            self.collectionView.footerEndRefreshing()
                            self.page++
                            self.isLoading = false
                        }
                    }
                }
            } else if type == 2 {
                if let NianDream = Cookies.get("NianDream") as? NSMutableArray {
                    for data in NianDream {
                        let d = data as! NSDictionary
                        let image = d.stringAttributeForKey("img")
                        let _private = d.stringAttributeForKey("private")
                        if _private == "0" {
                            let mutableData = NSMutableDictionary(dictionary: d)
                            mutableData.setValue(image, forKey: "image")
                            let _mutableData = self.getDataEncode(mutableData)
                            dataArray.addObject(_mutableData!)
                        }
                    }
                }
                self.collectionView.headerEndRefreshing()
                self.collectionView.footerEndRefreshing()
                self.collectionView.reloadData()
                isLoading = false
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreMoreCell", forIndexPath: indexPath) as! ExploreMoreCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        return c
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let DreamVC = DreamViewController()
        let data = dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let title = data.stringAttributeForKey("title")
        var lastdate = data.stringAttributeForKey("lastdate")
        let image = data.stringAttributeForKey("image")
        lastdate = V.relativeTime(lastdate)
        if id != "0" && id != "" {
            DreamVC.Id = id
            if type == 2 {
                delegate?.dreamSelected(id, title: title, content: lastdate, image: image)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.navigationController?.pushViewController(DreamVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == collectionView {
            let a = scrollView.contentOffset.y + globalHeight - 64
            let b = scrollView.contentSize.height
            if a + 400 > b && type != 2 {
                collectionView.footerBeginRefreshing()
            }
        }
    }
    
    func getDataEncode(d: AnyObject) -> NSMutableDictionary? {
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