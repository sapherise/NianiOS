//
//  CircleList2.swift
//  Nian iOS
//
//  Created by Sa on 15/6/5.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class CircleListController2: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var dataArray = NSMutableArray()
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        setupViews()
        setupRefresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        navHide()
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        load()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll", name: "Poll", object: nil)
    }
    
    func Poll() {
        load()
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "梦境"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        var rightBarButton = UILabel(frame: CGRectMake(0, 20, 80, 44))
        rightBarButton.text = "发现梦境"
        rightBarButton.setX(globalWidth-80)
        rightBarButton.userInteractionEnabled = true
        rightBarButton.textColor = UIColor.whiteColor()
        rightBarButton.font = UIFont.systemFontOfSize(14)
        rightBarButton.textAlignment = NSTextAlignment.Center
        rightBarButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "addCircleButton"))
        navView.addSubview(labelNav)
        navView.addSubview(rightBarButton)
        self.view.addSubview(navView)
        
        collectionView = UICollectionView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = BGColor
        
        var nib = UINib(nibName:"CircleCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "CircleCell")
        self.view.addSubview(collectionView)
    }
    
    func setupRefresh() {
        collectionView.addHeaderWithCallback {
            self.load()
        }
    }
    
    func addCircleButton(){
        var vc = CircleExploreController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func load() {
        println("加载")
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
//                self.collectionView.tableHeaderView = viewTop
            }else{
//                self.collectionView.tableHeaderView = nil
            }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
}