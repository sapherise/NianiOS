//
//  CollectionViewCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/18/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: CellLabel!

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

class CellLabel: UILabel {
   
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines)
        rect.origin.y = bounds.origin.y
        
        return rect
    }
    
    override func drawTextInRect(rect: CGRect) {
        let _rect = self.textRectForBounds(rect, limitedToNumberOfLines: self.numberOfLines)
        
        super.drawTextInRect(_rect)
    }
    
}