//
//  ExploreMoreCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/21/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreMoreCell: UICollectionViewCell {
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    var data: NSDictionary! {
        didSet {
            let image = data.stringAttributeForKey("image")
            let title = data.stringAttributeForKey("title")
            coverImageView.setImage("http://img.nian.so/dream/\(image)!dream")
            let height = data["heightTitle"] as! CGFloat
            titleLabel.text = title
            if height < 34 {
                titleLabel.text = "\(title)\n"
            } else {
                titleLabel.text = title
            }
        }
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.cancelImageRequestOperation()
//        coverImageView.image = nil
    }
    
}