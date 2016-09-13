//
//  ImageViewer.swift
//  Nian iOS
//
//  Created by Sa on 16/2/19.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    /* 
        images 为 path/width/height 的字典的组，
        index 为点进来时该图片的 index，
        exten 是原图片的拓展，
        folder 是该图片在又拍云上的路径 
        注意：path 不带完整路径，只带文件名；width/height 为文本
    */
    func open(_ images: NSArray, index: Int, exten: String, folder: String = "step") {
        let v = ImageViewer(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight))
        v.images = images
        v.index = index
        v.exten = exten
        v.imageOriginal = self
        v.folder = folder
        v.setup()
        self.window?.addSubview(v)
    }
    
    func getPointFromWindow() -> CGPoint {
        let _point = self.convert(CGPoint.zero, from: self.window)
        let point = CGPoint(x: -_point.x, y: -_point.y)
        return point
    }
}

class ImageViewer: UIScrollView, UIScrollViewDelegate {
    var images: NSArray!
    var index: Int!
    var exten = ""
    var current = 0
    var imageOriginal: UIImageView!
    var folder = "step"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.isUserInteractionEnabled = true
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView != self {
            return scrollView.subviews.first
        }
        return nil
    }
    
    /* 当放大时，确保图片居中 */
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let view = scrollView.subviews.first as? UIImageView {
            let x = scrollView.width() > scrollView.contentSize.width ? (scrollView.width() - scrollView.contentSize.width) / 2 : 0
            let y = scrollView.height() > scrollView.contentSize.height ? (scrollView.height() - scrollView.contentSize.height) / 2 : 0
            view.center = CGPoint(x: scrollView.contentSize.width/2 + x, y: scrollView.contentSize.height/2 + y)
        }
    }
    
    /*
    当停止滚动时
    设置所有 scrollView 的缩放为 1
    同时设置 current
    */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self {
            let x = self.contentOffset.x
            current = Int(x / globalWidth)
            if self.subviews.count > 0 {
                for i in 0...(self.subviews.count - 1) {
                    if i != current {
                        if let v = self.subviews[i] as? UIScrollView {
                            v.zoomScale = 1
                        }
                    }
                }
            }
        }
    }
    
    /* 当多图滑动时，需要重新计算偏移的位置，
    该函数能返回需要向右和向下移动多远
    */
    func getPoint(_ before: Int, after: Int) -> [CGFloat] {
        let x = after % 3 - before % 3
        let y = after / 3 - before / 3
        
        /* 小图的宽度 */
        let w = imageOriginal.width()
        
        /* 小图的宽度，加上之间的距离 */
        let padding = (globalWidth - w  * 3 - SIZE_PADDING * 2) / 2 + w
        return [CGFloat(x) * padding, CGFloat(y) * padding]
    }
    
    /* 单击移除 */
    func onTap(_ sender: UIGestureRecognizer) {
        if let views = sender.view?.subviews {
            if views.count > current {
                if let v = views[current] as? UIScrollView {
                    var imageView: UIImageView?
                    for view in v.subviews {
                        if let _view = view as? UIImageView {
                            _view.contentMode = UIViewContentMode.scaleAspectFill
                            _view.layer.masksToBounds = true
                            imageView = _view
                            break
                        }
                    }
                    if imageView != nil {
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            v.frame.origin.y = self.imageOriginal.getPointFromWindow().y + self.getPoint(self.index, after: self.current)[1]
                            v.frame.origin.x = self.imageOriginal.getPointFromWindow().x + globalWidth * CGFloat(self.current) + self.getPoint(self.index, after: self.current)[0]
                            v.frame.size = self.imageOriginal.frame.size
                            v.contentSize = self.imageOriginal.frame.size
                            imageView?.frame.size = self.imageOriginal.frame.size
                            imageView?.setY(0)
                            sender.view?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                            }, completion: { (Bool) -> Void in
                                sender.view?.removeFromSuperview()
                        }) 
                    }
                }
            }
        }
    }
    
    /* 长按图片 */
    func onLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            if let data = images[current] as? NSDictionary {
                let path = data.stringAttributeForKey("path")
                if let image = getCacheImage("http://img.nian.so/\(folder)/\(path)!large") {
                    let avc = SAActivityViewController.shareSheetInView(["喜欢念上这张照片！" as AnyObject, image, URL(string: "http://nian.so/app")! as AnyObject], applicationActivities: [], isStep: true)
                    imageOriginal.findRootViewController()?.present(avc, animated: true, completion: nil)
                } else if let image = getCacheImage("http://img.nian.so/\(folder)/\(path)") {
                    let avc = SAActivityViewController.shareSheetInView(["喜欢念上这张动图！" as AnyObject, image, URL(string: "http://nian.so/app")! as AnyObject], applicationActivities: [], isStep: true)
                    imageOriginal.findRootViewController()?.present(avc, animated: true, completion: nil)
                }
            }
        }
    }
    
    /* 双击 */
    func onDoubleTap(_ sender: UIGestureRecognizer) {
        if sender.view == self {
            if self.subviews.count > current {
                if let scrollView = self.subviews[current] as? UIScrollView {
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        scrollView.zoomScale = scrollView.zoomScale != 1 ? 1 : 1.2
                    })
                }
            }
        }
    }
    
    /* 下载 gif 图片 */
    func loadGif(_ v: UIImageView, imageURLAfter: String, viewProgress: UIProgressView) {
        if let _v = v as? FLAnimatedImageView {
            var a = imageURLAfter.components(separatedBy: "!")
            if getCacheImage(a[0]) != nil {
            } else {
                _v.addSubview(viewProgress)
                viewProgress.center = _v.center
                viewProgress.setY((_v.height() - viewProgress.height())/2)
            }
            _v.qs_setGifImageWithURL(URL(string: a[0])!, progress: { (recSize, totalSize) -> Void in
                let percent = Float(recSize) / Float(totalSize)
                viewProgress.progress = percent
                }, completed: { (image, data, error, finished) -> Void in
                    viewProgress.removeFromSuperview()
            })
        }
    }
    
    func setup() {
        current = index
        self.contentSize.width = globalWidth * CGFloat(images.count)
        self.isPagingEnabled = true
        self.contentOffset.x = globalWidth * CGFloat(index)
        
        /* 绑定动作 */
        let tap = UITapGestureRecognizer(target: self, action: #selector(ImageViewer.onTap(_:)))
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ImageViewer.onLongPress(_:))))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewer.onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        tap.require(toFail: doubleTap)
        self.addGestureRecognizer(doubleTap)
        
        if images.count > 0 {
            for i in 0...(images.count - 1) {
                if let data = images[i] as? NSDictionary {
                    var width = data.stringAttributeForKey("width").toCGFloat()
                    let height = data.stringAttributeForKey("height").toCGFloat()
                    let path = data.stringAttributeForKey("path")
                    var heightNew: CGFloat = 320
                    if width == 0 {
                        width = 320
                    } else {
                        heightNew = globalWidth * height / width
                    }
                    // todo: 测试图片功能
                    let y = (globalHeight - heightNew)/2
                    var v = UIImageView()
                    
                    if path.hasSuffix(".gif") {
                        v = FLAnimatedImageView()
                    }
                    v.isUserInteractionEnabled = true
                    
                    /* 图片加载的进度条 */
                    let viewProgress = UIProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
                    viewProgress.progressTintColor = UIColor.HighlightColor()
                    viewProgress.trackTintColor = UIColor.GreyColor1()
                    viewProgress.center = v.center
                    viewProgress.isHidden = true
                    
                    /* 将传入的图片作为 placeHolder */
                    let imageURLBefore = "http://img.nian.so/\(folder)/\(path)\(exten)"
                    let imageBefore = SDImageCache.shared().imageFromDiskCache(forKey: imageURLBefore)
                    let imageURLAfter = "http://img.nian.so/\(folder)/\(path)!large"
                    
                    /* 设置新的滚动视图 */
                    let scrollView = UIScrollView(frame: CGRect(x: globalWidth * CGFloat(i), y: 0, width: globalWidth, height: globalHeight))
                    scrollView.delegate = self
                    scrollView.maximumZoomScale = 3
                    scrollView.minimumZoomScale = 0.9
                    scrollView.addSubview(v)
                    self.addSubview(scrollView)
                    
                    /* 显示小图 */
                    v.image = imageBefore
                    v.contentMode = UIViewContentMode.scaleAspectFit
                    
                    /* 动画：小图到大图 */
                    if i == index {
                        v.frame.origin.y = self.imageOriginal.getPointFromWindow().y
                        v.frame.origin.x = self.imageOriginal.getPointFromWindow().x
                        v.frame.size = self.imageOriginal.frame.size
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            v.frame = CGRect(x: 0, y: y, width: globalWidth, height: heightNew)
                            }, completion: { (Bool) -> Void in
                                viewProgress.isHidden = false
                        })
                    } else {
                        viewProgress.isHidden = false
                        v.frame = CGRect(x: 0, y: y, width: globalWidth, height: heightNew)
                    }
                    
                    if y > 0 {
                        /* 显示大图 */
                        if path.hasSuffix(".gif") {
                            loadGif(v, imageURLAfter: imageURLAfter, viewProgress: viewProgress)
                        } else {
                            v.sd_setImage(with: URL(string: imageURLAfter)!, placeholderImage: imageBefore, options: SDWebImageOptions(), using: viewProgress)
                        }
                    } else {
                        /* 当图片很长时 */
                        scrollView.contentSize.height = heightNew
                        /* 显示大图 */
                        if path.hasSuffix(".gif") {
                            loadGif(v, imageURLAfter: imageURLAfter, viewProgress: viewProgress)
                        } else {
                            v.sd_setImage(with: URL(string: imageURLAfter)!, placeholderImage: imageBefore, options: SDWebImageOptions(), progress: { (a, b) -> Void in
                                }, completed: { (image, err, type, url) -> Void in
                                    v.setY(0)
                                }, using: viewProgress)
                        }
                    }
                }
            }
        }
    }
}
