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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func setupView() {
        self.imageView?.layer.cornerRadius = 6.0
        self.imageView?.layer.borderWidth = 0.5
        self.imageView?.layer.borderColor = UIColor.colorWithHex("#E6E6E6").CGColor
        self.imageView?.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
         
        self.imageView.cancelImageRequestOperation()
        self.imageView.image = nil
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