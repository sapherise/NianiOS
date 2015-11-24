//
//  MyLikeNoteViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/16/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class MyLikeNoteViewController: SAViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionDataSource = NSMutableArray()
    var page = 1
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self._setTitle("我赞过的记本")
        self.setupCollectionViewLayout()
        
        collectionView.addHeaderWithCallback { self.load() }
        collectionView.addFooterWithCallback { self.load(false) }
        
        collectionView.headerBeginRefreshing()
    }

    func setupCollectionViewLayout() {
        let x = (globalWidth - 240.0) / 8
        let y = x + x
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = x
        flowLayout.minimumLineSpacing = y
        flowLayout.itemSize = CGSize(width: 80, height: 120)
        flowLayout.sectionInset = UIEdgeInsetsMake(y, y, y, y)
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    func load(clear: Bool = true) {
        if !isLoading {
            isLoading = true
            
            if clear {
                page = 1
            }
            
            ActivitiesSummaryModel.getMyLikeNote(page: "\(page)", callback: {
                (task, responseObject, error) -> Void in
                
                if let _ = error {
                    self.view.showTipText("网络有点问题，等一会儿再试")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["error"] != 0 {
                        
                    } else {
                        if clear {
                            self.collectionDataSource.removeAllObjects()
                        }
                        
                        self.collectionDataSource.addObjectsFromArray(json["data"].arrayObject!)
                        self.collectionView.reloadData()
                        
                        clear ? self.collectionView.headerEndRefreshing() : self.collectionView.footerEndRefreshing()
                        
                        self.page++
                        self.isLoading = false
                    }
                }
                
            })
        }
    }
}


extension MyLikeNoteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("noteCell", forIndexPath: indexPath) as! noteCell
        
        if Float(UIDevice.currentDevice().systemVersion) < 8.0 {
            let _dataSource = self.collectionDataSource[indexPath.row] as! NSDictionary
            
            cell.noteImageView.setImage("http://img.nian.so/dream/\(_dataSource["img"] as! String)!dream", radius: 8.0)
            cell.noteLabel.text = (_dataSource["title"] as? String)?.decode()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let _dataSource = self.collectionDataSource[indexPath.row] as! NSDictionary
        
        (cell as! noteCell).noteImageView.setImage("http://img.nian.so/dream/\(_dataSource["img"] as! String)!dream", radius: 8.0)
        (cell as! noteCell).noteLabel.text = (_dataSource["title"] as? String)?.decode()
        
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! noteCell).noteImageView.cancelImageRequestOperation()
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let DreamVC = DreamViewController()
        let data = collectionDataSource[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        var lastdate = data.stringAttributeForKey("lastdate")
        lastdate = V.relativeTime(lastdate)
        if id != "0" && id != "" {
            DreamVC.Id = id

            self.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }
    
    
}

/*=========================================================================================================================================*/


class noteCell: UICollectionViewCell {
    
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.noteImageView.layer.borderColor = lineColor.CGColor
        self.noteImageView.layer.borderWidth = 0.5
        self.noteImageView.layer.cornerRadius = 8.0
        self.noteImageView.layer.masksToBounds = true
        
        self.noteLabel.sizeToFit()
    }
    
}


