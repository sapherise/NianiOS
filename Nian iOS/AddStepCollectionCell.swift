//
//  AddStepCollectionCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/27/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class AddStepCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    
    var image: UIImage?
    
    var thumbnailImage: UIImage? 
    
    override var selected: Bool {
        set {
            super.selected = selected
            self.overlayView.hidden = !selected 
        }
        
        get {
            return super.selected
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.overlayView.hidden = true
    }

}
