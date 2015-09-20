//
//  ExploreRecomMore.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/19/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

protocol DreamSelectedDelegate {
    func dreamSelected(id: String, title: String, content: String, image: String)
}

class ExploreRecomMore: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// 显示在 Nav Bar 上的 title， 为了避免和 UIViewController 的 title 冲突
    var titleOn: String!
    var dataArray = NSMutableArray()
    var delegate: DreamSelectedDelegate?
    
    var page = 0
    var lastID = ""
    
    // 设置一个滚动时的 target rect, 目的是为了判断要不要加载图片
    var targetRect: NSValue?
    
    /* 用队列下载图片，减轻 mainQueue 的压力 */
    var currentQueue = NSOperationQueue.mainQueue()
    
    var cellImageDict = Dictionary<NSIndexPath, NSBlockOperation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewBack()
        setupView()
        
        self.titleLabel.text = titleOn
        self.collectionView.registerNib(UINib(nibName: "ExploreMoreCell", bundle: nil), forCellWithReuseIdentifier: "ExploreMoreCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self 
        
        /* 设置同时请求图片的并发数  = 3 */
        currentQueue.maxConcurrentOperationCount = 3

        self.collectionView.headerBeginRefreshing()
    }

    func setupView() {
        let flowLayout = UICollectionViewFlowLayout()
        
//        let Q = isiPhone6P ? 4 : 3
        let Q = 3
        let x = (globalWidth - CGFloat(80 * Q))/CGFloat(2 * (Q + 1))
        let y = x + x
        
        flowLayout.minimumInteritemSpacing = x
        flowLayout.minimumLineSpacing = y
        flowLayout.itemSize = CGSize(width: 80, height: 120)
        flowLayout.sectionInset = UIEdgeInsets(top: y, left: y, bottom: y, right: y)
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.addHeaderWithCallback(onPullDown)
        self.collectionView.addFooterWithCallback(onPullUp)

    }
    
    func onPullDown() {
        page = 1
        self.lastID = "0"
        load(true)
    }
    
    func onPullUp() {
        load(false)
    }
    
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        
        if titleOn == "编辑推荐" {
            Api.getDiscoverEditorRecom("\(page++)", callback: {
                json in
                if json != nil {
                    let err = json!.objectForKey("error") as? NSNumber
                    if err == 0 {
                        if clear {
                            self.dataArray.removeAllObjects()
                        }
                        let count = self.dataArray.count
                        
                        let data = json!.objectForKey("data") as? NSArray
                        if data != nil {
                            for item: AnyObject in data! {
                                self.dataArray.addObject(item)
                            }
                            
                            self.collectionView.headerEndRefreshing()
                            self.collectionView.footerEndRefreshing()
                            self.collectionView.reloadData()
                        }
                    }
                }
            })
        } else if titleOn == "最新" {
            Api.getDiscoverLatest("\(page++)", callback: {
                json in
                if json != nil {
                    let err = json!.objectForKey("error") as? NSNumber
                    if err == 0 {
                        if clear {
                            self.dataArray.removeAllObjects()
                        }
                        let data = json!.objectForKey("data") as? NSArray
                        let count = self.dataArray.count
                        
                        if data != nil {
                            /* 去掉所有封面是默认的记本 */
                            for item: AnyObject in data! {
                                let _img = (item as! NSDictionary).objectForKey("image") as! String
                                let _imgSplit = _img.componentsSeparatedByString(".")
                                
                                if let _ = Int(_imgSplit[0]) {
                                } else {
                                    self.dataArray.addObject(item)
                                }
                            }
                            
                            self.collectionView.headerEndRefreshing()
                            self.collectionView.footerEndRefreshing()
                            self.collectionView.reloadData()
                        }
                    }
                }
            })
        } else if titleOn == "插入记本" {
            if let NianDream = Cookies.get("NianDream") as? NSMutableArray {
                for data in NianDream {
                    let d = data as! NSDictionary
                    
                    let image = d.stringAttributeForKey("img")
                    let _private = d.stringAttributeForKey("private")
                    if _private == "0" {
                        let mutableData = NSMutableDictionary(dictionary: d)
                        mutableData.setValue(image, forKey: "image")
                        dataArray.addObject(mutableData)
                    }
                }
            }
            self.collectionView.headerEndRefreshing()
            self.collectionView.footerEndRefreshing()
            self.collectionView.reloadData()
        }
    }
}

extension ExploreRecomMore : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreMoreCell", forIndexPath: indexPath) as! ExploreMoreCell
        let _tmpData = self.dataArray.objectAtIndex(indexPath.row) as! NSDictionary
        if let _img = _tmpData.objectForKey("image") as? String {
            let imgOp = NSBlockOperation(block: {
                if SAUid() == "171264" {
                    cell.coverImageView.setImageWithRounded(0, urlString: "http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                } else {
                    cell.coverImageView.setImageWithRounded(6.0, urlString: "http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                }
            })
            cellImageDict[indexPath] = imgOp
            currentQueue.addOperations([imgOp], waitUntilFinished: false)
        }
        cell.titleLabel?.text = (_tmpData.objectForKey("title") as! String).decode()
        return cell
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
            if titleOn == "插入记本" {
                delegate?.dreamSelected(id, title: title, content: lastdate, image: image)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.navigationController?.pushViewController(DreamVC, animated: true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let op = cellImageDict[indexPath]
        
        if let _op = op {
            if _op.ready || _op.executing {
                cellImageDict[indexPath]?.cancel()
                cellImageDict[indexPath] = nil
            }
        }
    }
    
}
