//
//  CollectionViewCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/18/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView?
    var label: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    
    func setupView() {
        self.imageView?.frame = CGRectMake(0, 0, 64, 64)
        self.label?.frame = CGRectMake(0, 72, 64, 32)
    }
    
    
    override func prepareForReuse() {
        self.imageView?.cancelImageRequestOperation()
        self.imageView?.image = nil
    }
    
}
