//
//  CollectionViewCell-XL.swift
//  Nian iOS
//
//  Created by WebosterBob on 9/1/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class CollectionViewCell_XL: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: CellLabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.cancelImageRequestOperation()
        self.imageView.image = nil
    }
    
    
}
