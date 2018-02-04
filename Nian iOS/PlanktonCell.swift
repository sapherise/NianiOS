//
//  PlanktonCell.swift
//  Nian iOS
//
//  Created by Sa on 15/11/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class PlanktonCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
