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
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
    }
    
    func setupView() {
        self.coverImageView?.layer.cornerRadius = 6.0
        self.coverImageView?.layer.borderWidth = 0.5
        self.coverImageView?.layer.borderColor = UIColor.colorWithHex("#E6E6E6").CGColor
        self.coverImageView?.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coverImageView.cancelImageRequestOperation()
        self.coverImageView.image = nil
    }
    
}
