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
        
        let imageSize = self.imageView?.frame.size
        let titleSize = self.titleLabel?.frame.size
        
        /* image 和 title 的上下间距 */
        let padding: CGFloat = 4.0
        
        let totalHeight = imageSize!.height + titleSize!.height + padding
        
        // 调整 image 的位置和大小
        self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize!.height), 0, 0, -titleSize!.width)
        // 调整 title 的位置和大小
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize!.width, -(totalHeight - titleSize!.height), 0.0)
    }

}
