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
    let placeHolder:UIImage = UIImage(named:"back")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        
        self.imageView = UIImageView(frame:self.bounds)
        self.imageView!.contentMode = .ScaleAspectFit
        self.addSubview(self.imageView!)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 3;
        
        var doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapped:")
        doubleTap.numberOfTapsRequired = 2;
        
        self.addGestureRecognizer(doubleTap);
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doubleTapped(sender:UITapGestureRecognizer){
        if self.zoomScale > 1.0{
            self.setZoomScale(1.0, animated:true);
        }else{
            var point = sender.locationInView(self);
            self.zoomToRect(CGRectMake(point.x-50, point.y-50, 100, 100), animated:true)
        }
    }
    
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView
    {
        return self.imageView!
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.imageView!.setImage(self.imageURL,placeHolder:placeHolder)
    }
}
