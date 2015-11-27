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
    
    override var selected: Bool {
        set {
            self.overlayView.hidden = false
        }
        
        get {
            return self.selected
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.overlayView.hidden = true
    }

}
