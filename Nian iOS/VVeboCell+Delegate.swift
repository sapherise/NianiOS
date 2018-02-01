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
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c: VVeboCollectionViewCell!  = collectionView.dequeueReusableCell(withReuseIdentifier: "VVeboCollectionViewCell", for: indexPath) as? VVeboCollectionViewCell
        if let images = data.object(forKey: "images") as? NSArray {
            c.image = images[(indexPath as NSIndexPath).row] as? NSDictionary
            c.index = (indexPath as NSIndexPath).row
            c.images = images
            c.setup()
        }
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = data.object(forKey: "images") as? NSArray {
            return images.count
        }
        return 0
    }
}
