//
//  NI_InCellImageView.swift
//  Nian iOS
//
//  Created by WebosterBob on 9/2/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class NI_InCellImageView: UIImageView {


    private var shouldReloadImage: Bool = true
    
    override var image: UIImage? {
        didSet {
            //do your stuff (add effects, layers, ...)
            if shouldReloadImage {
                self.setNeedsDisplay()
            }
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        if image != nil {
            if shouldReloadImage {
                shouldReloadImage = false
                //
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
                
                let aPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 6.0)
                let aColor = UIColor.colorWithHex("#E6E6E6")
                aColor.set()
                
                aPath.lineWidth = 0.5
                aPath.lineCapStyle = .Round
                aPath.lineJoinStyle = .Round
                aPath.stroke()
                aPath.addClip()
                
                image!.drawInRect(self.bounds)
                image = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}
