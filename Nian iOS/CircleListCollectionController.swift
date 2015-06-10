//
//  CircleListCollectionController.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/9/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CircleListCollectionController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionViewLayout()
        self.collectionView.addHeaderWithCallback{
            self.load()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll", name: "Poll", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        load()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Poll", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

//    func addCircleButton() {
//        var vc = CircleExploreController()
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func Poll() {
        load()
    }
    
    func load() {
        var safeuid = SAUid()
        let (resultCircle, errCircle) = SD.executeQuery("SELECT circle FROM `circle` where owner = '\(safeuid)' GROUP BY circle ORDER BY lastdate DESC")
        
        if errCircle != nil {
            self.collectionView.headerEndRefreshing()
            return
        }
        
        self.dataArray.removeAllObjects()
        for row in resultCircle {
            var id = (row["circle"]?.asString())!
            var img = ""
            var title = "梦境"
            let (resultDes, err) = SD.executeQuery("select * from circlelist where circleid = '\(id)' and owner = '\(safeuid)' limit 1")
            if resultDes.count > 0 {
                for row in resultDes {
                    img = (row["image"]?.asString())!
                    title = (row["title"]?.asString())!
                }
            }
            var data = NSDictionary(objects: [id, img, title], forKeys: ["id", "img", "title"])
            self.dataArray.addObject(data)
        }
        
        var dataBBS = NSDictionary(objects: ["0", "0", "0"], forKeys: ["id", "img", "title"])
        self.dataArray.addObject(dataBBS)
        self.collectionView.reloadData()
        self.collectionView.headerEndRefreshing()
        
        if self.dataArray.count == 1 {
            var NibCircleCell = NSBundle.mainBundle().loadNibNamed("CircleCell", owner: self, options: nil) as NSArray
            var viewTop = NibCircleCell.objectAtIndex(0) as! CircleCell
            viewTop.labelTitle.text = "发现梦境"
            viewTop.labelContent.text = "和大家一起组队造梦"
            viewTop.labelCount.hidden = true
            viewTop.lastdate?.hidden = true
            viewTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBtnGoClick"))
            viewTop.userInteractionEnabled = true
            viewTop.imageHead.setImage("http://img.nian.so/dream/1_1420533592.png!dream", placeHolder: IconColor)
            viewTop.tag = 1
            viewTop.editing = false
//            self.collectionView.tableHeaderView = viewTop
        } else {
//            self.collectionView.tableHeaderView = nil
        }
        
    }
    
    func setupCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        var width = (self.view.bounds.width - 48) / 2
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 16.0
        flowLayout.itemSize = CGSize(width: width, height: 182)
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.collectionView.collectionViewLayout = flowLayout
        
    }
    

}

extension CircleListCollectionController: UICollectionViewDataSource, UICollectionViewDelegate  {
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier = "CircleCollectionCell"
        var circleCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! CircleCollectionCell
        circleCollectionCell.data = (self.dataArray[indexPath.row] as! NSDictionary)
        

        return circleCollectionCell
    }
    
    
}






















