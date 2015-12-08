//
//  AddStepCollectionCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/27/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class AddStepCollectionCell: UICollectionViewCell {

    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        constrain(self.imageView) { imageView in
            imageView.top    == imageView.superview!.top
            imageView.bottom == imageView.superview!.bottom
            imageView.left   == imageView.superview!.left
            imageView.right  == imageView.superview!.right
        }
        
        self.imageView.contentMode = .ScaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
