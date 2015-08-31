//
//  ExploreRecomMore.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/19/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreRecomMore: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var titleOn: String!
    var dataArray = NSMutableArray()
    
    var page = 0
    var lastID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewBack()
        setupView()
        
        self.titleLabel.text = titleOn
        self.collectionView.registerNib(UINib(nibName: "ExploreMoreCell", bundle: nil), forCellWithReuseIdentifier: "ExploreMoreCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self 
        
        self.collectionView.headerBeginRefreshing()
        load(false)
    }

    func setupView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        let Q = isiPhone6P ? 4 : 3
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
            cell.coverImageView?.setImage("http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
        }
        cell.titleLabel?.text = SADecode(_tmpData.objectForKey("title") as! String)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let DreamVC = DreamViewController()
        DreamVC.Id = (self.dataArray.objectAtIndex(indexPath.row) as! NSDictionary)["id"] as! String
        
        if DreamVC.Id != "0" && DreamVC.Id != "" {
            self.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }
    
}





