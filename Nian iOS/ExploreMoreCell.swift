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
    @IBOutlet weak var titleLabel: UILabel!
    
    var imgString: String?
    var _title: String?
    
    var data: NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.layer.borderColor = lineColor.CGColor
        coverImageView.layer.borderWidth = 0.5
        if SAUid() == "171264" {
            coverImageView.layer.cornerRadius = 0
        } else {
            coverImageView.layer.cornerRadius = 6.0
        }
        
        coverImageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let image = data.stringAttributeForKey("image")
            let title = data.stringAttributeForKey("title").decode()
            coverImageView.setImage("http://img.nian.so/dream/\(image)!dream")
            titleLabel.text = title
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverImageView.cancelImageRequestOperation()
        coverImageView.image = nil
    }
    
}
