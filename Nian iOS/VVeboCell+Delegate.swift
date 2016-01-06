//
//  VVeboCell+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 16/1/4.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension VVeboCell {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: VVeboCollectionViewCell!  = collectionView.dequeueReusableCellWithReuseIdentifier("VVeboCollectionViewCell", forIndexPath: indexPath) as? VVeboCollectionViewCell
        if let images = data.objectForKey("images") as? NSArray {
            c.image = images[indexPath.row] as? NSDictionary
            c.setup()
        }
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = data.objectForKey("images") as? NSArray {
            return images.count
        }
        return 0
    }
}