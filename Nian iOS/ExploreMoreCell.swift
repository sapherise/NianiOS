//
//  ExploreMoreCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/21/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreMoreCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: CellLabel!
    
    var imgString: String?
    var _title: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coverImageView.cancelImageRequestOperation()
        self.coverImageView.image = nil
    }
    
}
