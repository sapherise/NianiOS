//
//  ImageViewer.swift
//  Nian iOS
//
//  Created by Sa on 16/2/19.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ImageViewer: UIScrollView, UIScrollViewDelegate {
    var images: NSArray!
    var index: Int!
    var exten = ""
    var current = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.userInteractionEnabled = true
        self.delegate = self
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTap"))
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onLongPress"))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
//        
//        var y: CGFloat = 0
//        var x: CGFloat = 0
//        if (self.contentSize.width < self.bounds.size.width) {
//            x = (self.bounds.size.width - self.contentSize.width) * 0.5
//        }
//        if (self.contentSize.height < self.bounds.size.height) {
//            y = (self.bounds.size.height - self.contentSize.height) * 0.5
//        }
//        self.imageView.setX(x)
//        self.imageView.setY(y)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self {
            let x = self.contentOffset.x
            current = Int(x / globalWidth)
        }
    }
    
    func onLongPress() {
        if let data = images[current] as? NSDictionary {
            var path = data.stringAttributeForKey("path")
            path = "http://img.nian.so/step/\(path)!large"
            if let image = getCacheImage(path) {
                let avc = SAActivityViewController.shareSheetInView(["喜欢念上这张照片！", image, NSURL(string: "http://nian.so/app")!], applicationActivities: [], isStep: true)
                self.findRootViewController()?.presentViewController(avc, animated: true, completion: nil)
            }
        }
    }
    
    func onTap() {
        self.removeFromSuperview()
    }
    
    func setup() {
        self.contentSize.width = globalWidth * CGFloat(images.count)
        self.pagingEnabled = true
        self.contentOffset.x = globalWidth * CGFloat(index)
        if images.count > 0 {
            for i in 0...(images.count - 1) {
                if let data = images[i] as? NSDictionary {
                    print(data)
                    let width = CGFloat((data.stringAttributeForKey("width") as NSString).floatValue)
                    let height = CGFloat((data.stringAttributeForKey("height") as NSString).floatValue)
                    let heightNew = globalWidth * height / width
                    let y = (globalHeight - heightNew)/2
                    let v = UIImageView(frame: CGRectMake(globalWidth * CGFloat(i), y, globalWidth, heightNew))
                    v.backgroundColor = i % 2 == 0 ? UIColor.redColor() : UIColor.yellowColor()
                    let path = data.stringAttributeForKey("path")
                    v.setImage("http://img.nian.so/step/\(path)\(exten)")
                    
                    /* 不滚动 */
                    if y > 0 {
                        self.addSubview(v)
                    } else {
                        let scrollView = UIScrollView(frame: CGRectMake(globalWidth * CGFloat(i), 0, globalWidth, globalHeight))
                        print(globalWidth * CGFloat(i), 0, globalWidth, globalHeight)
                        scrollView.contentSize.height = heightNew
                        v.frame.origin = CGPointZero
                        scrollView.addSubview(v)
                        self.addSubview(scrollView)
                    }
                }
            }
        }
    }
}