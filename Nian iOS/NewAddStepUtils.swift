//
//  NewAddStepUtils.swift
//  Nian iOS
//
//  Created by WebosterBob on 12/12/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import Foundation
import UIKit 


class yy_collectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        self.minimumLineSpacing = 2.0
        self.minimumInteritemSpacing = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.minimumInteritemSpacing = 2.0
        self.minimumLineSpacing = 2.0
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        let _count = self.collectionView?.numberOfItemsInSection(0)
        
        let _index = _count! / 3
        let _tmpIndex = _count! % 3
        let __index = _tmpIndex == 0 ? _index : _index + 1
        
        let collectionViewHeight = CGFloat(__index) * ceil((globalWidth - 32 - 4)/3) + CGFloat(_index * 2)
        let size = CGSizeMake(self.collectionView!.frame.width, collectionViewHeight)
        
        self.collectionView?.contentSize = size
        
        return size
    }
    
}


class AddStepNoteCell: UICollectionViewCell {

    let imageView = UIImageView()
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        constrain(self.imageView) { (imageView) -> () in
            imageView.top    == imageView.superview!.top
            imageView.bottom == imageView.superview!.bottom - 40
            imageView.left   == imageView.superview!.left
            imageView.right  == imageView.superview!.right
        }
        
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.layer.cornerRadius = 6
        self.imageView.layer.masksToBounds = true
        
        self.addSubview(label)
        label.textColor = UIColor.colorWithHex("#333333")
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
 
        constrain(self.label, self.imageView) { (view1, view2) -> () in
            view1.top   == view2.bottom + 6
            view1.left  == view1.superview!.left
            view1.right == view1.superview!.right
        }
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}


























