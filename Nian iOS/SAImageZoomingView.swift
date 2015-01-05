//
//  SAImageZoomingView
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-7.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SAImageZoomingView: UIScrollView, UIScrollViewDelegate {
    
    var imageView:UIImageView?
    var imageURL:String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView!.contentMode = .ScaleAspectFit
        self.addSubview(self.imageView!)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.minimumZoomScale = 0.9;
        self.maximumZoomScale = 3;
    }
    
    init(frame: CGRect, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        super.init(frame: frame)
        self.delegate = self
        self.imageView = UIImageView(frame: CGRectMake(0, 0, w, h))
        self.contentInset = UIEdgeInsetsMake(y, x, y, x)
        self.imageView!.contentMode = .ScaleAspectFit
        self.addSubview(self.imageView!)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.minimumZoomScale = 0.9;
        self.maximumZoomScale = 3;
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView {
        return self.imageView!
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        var y: CGFloat = 0
        var x: CGFloat = 0
        if (self.contentSize.width < self.bounds.size.width) {
            x = (self.bounds.size.width - self.contentSize.width) * 0.5
        }
        if (self.contentSize.height < self.bounds.size.height) {
            y = (self.bounds.size.height - self.contentSize.height) * 0.5
        }
        self.contentInset = UIEdgeInsetsMake(y, x, y, x)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView!.setImage(self.imageURL, placeHolder: IconColor, ignore: true)
    }
}
