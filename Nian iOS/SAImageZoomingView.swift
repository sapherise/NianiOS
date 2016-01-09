//
//  SAImageZoomingView
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-7.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SAImageZoomingView: UIScrollView, UIScrollViewDelegate {
    var imageView: UIImageView!
    var imageURL: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.imageView = UIImageView()
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.backgroundColor = UIColor.blackColor()
        self.addSubview(self.imageView)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.minimumZoomScale = 0.9
        self.maximumZoomScale = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView)->UIView? {
        return self.imageView
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
        self.imageView.setX(x)
        self.imageView.setY(y)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let v = UIProgressView(frame: CGRectMake(0, 0, 100, 200))
        v.progressTintColor = SeaColor
        v.trackTintColor = IconColor
        v.center = imageView.center
        v.hidden = true
        
        delay(0.3) { () -> () in
            v.hidden = false
        }
        
        /* placeHolder 就是缓存的小图
        ** 然后加载 !large 的大图
        */
        let imageCache = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(imageURL)
        self.imageView.sd_setImageWithURL(NSURL(string: explode(imageURL)), placeholderImage: imageCache, usingProgressView: v)
    }
    
    /* 把 url 的后缀改为 !large
    */
    func explode(content: String) -> String {
        let arr = content.componentsSeparatedByString("!")
        var after = ""
        if arr.count > 0 {
            for i in 0...(arr.count - 1) {
                if i == 0 {
                    after = arr[i]
                } else if i == arr.count - 1 {
                    after = "\(after)!large"
                } else {
                    after = "\(after)!\(arr[i])"
                }
            }
        }
        return after
    }
    
    func getImageUrlLarge() -> String {
        return explode(imageURL)
    }
}
