//
//  NianCell.swift
//  Nian iOS
//
//  Created by Sa on 14/11/18.
//  Copyright (c) 2014年 Sa. All rights reserved.
//


import UIKit

var globalNianCount: Int = 0

class NianCell: UICollectionViewCell{
    
     struct inner {
        static var counter = 0
    }
    
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data :NSDictionary!
    var total: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageCover.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        if inner.counter == self.total {
            globalhasLaunched = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageCover.layer.cornerRadius = 6
        self.imageCover.layer.masksToBounds = true
        self.imageCover.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.imageCover.layer.borderWidth = 0.5
        
        if globaliOS >= 8.0 && globalhasLaunched == 0 {
            self.imageCover.alpha = 0
            var rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 1, 0, 0)
            self.imageCover.layer.transform = CATransform3DPerspect(rotate, CGPointZero, 300)
            delay(Double(inner.counter) * 0.2, {
                UIView.animateWithDuration(0.6, animations: {
                    self.imageCover.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0)
                })
                UIView.animateWithDuration(0.2, animations: {
                    self.imageCover.alpha = 1
                })
            })
            inner.counter++
        }
    }
}

func CATransform3DMakePerspective(center: CGPoint, disZ: CGFloat) -> CATransform3D {
    var transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0)
    var transBack = CATransform3DMakeTranslation(center.x, center.y, 0)
    var scale = CATransform3DIdentity
    scale.m34 = CGFloat(-1) / disZ
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack)
}

func CATransform3DPerspect(t: CATransform3D, center: CGPoint, disZ: CGFloat) -> CATransform3D {
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ))
}
