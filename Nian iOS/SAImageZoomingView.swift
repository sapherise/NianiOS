//
//  SAImageZoomingView
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-7.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SAImageZoomingView: UIScrollView,UIScrollViewDelegate {
    
    
    var imageView:UIImageView?
    var imageURL:String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        
        self.imageView = UIImageView(frame:self.bounds)
        self.imageView!.contentMode = .ScaleAspectFit
        self.addSubview(self.imageView!)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.minimumZoomScale = 0.618;
        self.maximumZoomScale = 3;
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView
    {
        return self.imageView!
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.imageView!.setImage(self.imageURL, placeHolder: BGColor)
    }
}
