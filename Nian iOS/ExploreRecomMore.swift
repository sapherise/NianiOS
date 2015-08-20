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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewBack()
        navHide()
        
        self.titleLabel.text = titleOn
        self.collectionView.registerNib(UINib(nibName: "ExploreNewCell", bundle: nil), forCellWithReuseIdentifier: "ExploreNewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        var Q = isiPhone6P ? 4 : 3
        
        var x = (globalWidth + CGFloat(80 * Q))/CGFloat(2 * (Q + 1))
        var y = x
        
        var width = (self.view.bounds.width - 2*y) / 2
        flowLayout.minimumInteritemSpacing = 2 * x
        flowLayout.minimumLineSpacing = 2 * x
        flowLayout.itemSize = CGSize(width: 80, height: 120)
        flowLayout.sectionInset = UIEdgeInsets(top: y, left: y, bottom: y, right: y)
        
        self.collectionView.collectionViewLayout = flowLayout
    }

}
