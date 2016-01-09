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
    
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data :NSDictionary!
    var total: Int = 0
    var index = 0
    
    func setup() {
        self.imageCover.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        let lock = Cookies.get("Lock") as? String
        if globaliOS >= 8.0 && globalhasLaunched == 0 && lock == nil {
            self.imageCover.alpha = 0
            let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 1, 0, 0)
            self.imageCover.layer.transform = CATransform3DPerspect(rotate, center: CGPointZero, disZ: 300)
            delay(Double(index) * 0.2, closure: {
                UIView.animateWithDuration(0.6, animations: {
                    self.imageCover.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0)
                })
                UIView.animateWithDuration(0.2, animations: {
                    self.imageCover.alpha = 1
                })
            })
        }
        
        if SAUid() == "171264" {
            self.imageCover.layer.cornerRadius = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageCover.layer.cornerRadius = 6
        self.imageCover.layer.masksToBounds = true
        self.imageCover.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.imageCover.layer.borderWidth = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCover.image = nil
    }
}

func CATransform3DMakePerspective(center: CGPoint, disZ: CGFloat) -> CATransform3D {
    let transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0)
    let transBack = CATransform3DMakeTranslation(center.x, center.y, 0)
    var scale = CATransform3DIdentity
    scale.m34 = CGFloat(-1) / disZ
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack)
}

func CATransform3DPerspect(t: CATransform3D, center: CGPoint, disZ: CGFloat) -> CATransform3D {
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ: disZ))
}
