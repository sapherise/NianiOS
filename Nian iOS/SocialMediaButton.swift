//
//  SocialMediaButton.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

/// 欢迎页面上的 “微信” “QQ” “微博”
class SocialMediaButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // 将 UIButton 本来的“左图右字”，改成“上图下字”
    convenience init(type buttonType: UIButtonType) {
        self.init(type: buttonType)
        
        let imageSize = self.imageView?.frame.size
        let titleSize = self.titleLabel?.frame.size
        
        /* image 和 title 的上下间距 */
        let padding: CGFloat = 4.0
        
        let totalHeight = imageSize!.height + titleSize!.height + padding
        
        self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize!.height), 0, 0, -titleSize!.width)
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize!.width, -(totalHeight - titleSize!.height), 0.0)
    }
}
