//
//  VVImageView.swift
//  Nian iOS
//
//  Created by WebosterBob on 12/2/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

typealias VVImageViewHandle = (info: String) -> Void

public let VVDownloadImagesInitiationNotification = "VVDownloadImagesInitiationNotification"
public let VVDownloadImagesComplectionNotification = "VVDownloadImagesCompletionNotification"

@objc protocol VVImageViewDelegate {
    
    
    
}



class VVImageView: UIImageView {
    
    typealias DownloadedSingleImage = (image: UIImage) -> Void
    
    var imagesDataSource = NSMutableArray()
    
    var imagesNumberInPerLine = 3
    
    var sid: String = ""
    
    let placeholderImage = UIImage(named: "")
    
    var containImages: [UIImage] = []
    
    var backgroundImage = UIImage()
    
    var minimumInteritemSpacing: CGFloat = 2.0
    
    var minimumLineSpacing: CGFloat = 2.0
    
    var viewInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    
    private var imagesRectInfo = [Int: CGRect]()
    
    private var _imagesBaseURL = NSURL(string: "http://img.nian.so/step/")!
    
    var imagesBaseURL: NSURL {
        set(newValue) {
            self._imagesBaseURL = newValue
        }
        
        get {
            return self._imagesBaseURL
        }
        
    }
    
    
    private var _imagesDownloadFramework = "SDWebImage"
    
    var imagesDownloadFramework: String {
        set(newValue) {
            self._imagesDownloadFramework = newValue
        }
        
        get {
            return self._imagesDownloadFramework
        }
        
    }
    
    private var _userInteractionEnabled: Bool = true
    
    override var userInteractionEnabled: Bool {
        set (newValue) {
            self._userInteractionEnabled = newValue
        }
        
        get {
            return  self._userInteractionEnabled
        }
    }
    
    private var downloadedImagesCount = 0
    
    
    let sd_manager = SDWebImageManager.sharedManager()
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.userInteractionEnabled = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
    }
    
    override func setImage(urlString: String, radius: CGFloat = 0) {
        
        if self.imagesDataSource.count == 1 {
            
            let _imagePath = (self.imagesDataSource[0] as! NSDictionary)["path"] as! String
            let _imageURLString = "http://img.nian.so/step/\(_imagePath)!large"
            
            SDImageCache.sharedImageCache().diskImageExistsWithKey(_imageURLString,
                completion: { (isInCache) -> Void in
                    if isInCache {
                        self.image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(_imageURLString)
                    } else {
                        self.sd_manager.downloadImageWithURL(NSURL(string: _imageURLString)!,
                            options: SDWebImageOptions(rawValue: 0),
                            progress: { (receivedSize, expectedSize) -> Void in
                                
                            }, completed: { (image, error, cacheType, finished, imageURL) -> Void in
                                self.image = image
                        })
                    }
            })
            
        } else if self.imagesDataSource.count > 1 {
            let isInCache = SDImageCache.sharedImageCache().diskImageExistsWithKey("http://localhost/\(self.sid)")
           
            if isInCache {
                self.image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("http://localhost/\(self.sid)")
            } else {
                let _tmp = self.imagesDataSource.count / self.imagesNumberInPerLine + ( self.imagesDataSource.count % self.imagesNumberInPerLine == 0 ? 0 : 1 )
                let cellWidth = floor((self.frame.size.width - self.viewInsets.left - self.viewInsets.right) / CGFloat(self.imagesNumberInPerLine))
                let cellHeigh = floor((self.frame.size.height - self.viewInsets.top - self.viewInsets.bottom) / CGFloat(_tmp))
                
                self.calculateFrameForEachImage(rect: (cellWidth, cellHeigh))
                
                self.downloadImages(self.imagesDataSource, callback: { (image) -> Void in
                    self.drawContentImageInView(image, indexInContainer: self.containImages.count)
                    self.containImages.append(image)
                })
                
                
                // TODO: delegate
                
            }
        }
        
    }
    
    
    func downloadImages(urls: NSArray, callback: DownloadedSingleImage) {
        
        for dict: NSDictionary in urls as! [NSDictionary] {
            let _imageURLString = dict["path"] as! String
            let _imageURL = NSURL(string: _imageURLString, relativeToURL: self._imagesBaseURL)


            sd_manager.downloadImageWithURL(_imageURL,
                options: SDWebImageOptions(rawValue: 0),
                progress: { (receivedSize, expectedSize) -> Void in
                    
                }, completed: { (image, error, cacheType, finished, imageURL) -> Void in
                    
                    if let _ = error {
                        callback(image: self.placeholderImage!)
                    }
                    
                    callback(image: image)
            })
        }
        
    }
    
    
    func drawContentImageInView(image: UIImage, indexInContainer: Int) {
        
        let _rect = self.imagesRectInfo[indexInContainer]
        let imageRect = CGRectMake(_rect!.origin.x, _rect!.origin.y, _rect!.width, _rect!.height)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, UIScreen.mainScreen().scale)
        image.drawInRect(imageRect)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    func calculateFrameForEachImage(rect rect: (CGFloat, CGFloat)) {
        var tmp = 0
        
        for(; tmp < self.imagesDataSource.count; tmp++) {
            
            let tmp1 = tmp % imagesNumberInPerLine
            let tmp2 = tmp / imagesNumberInPerLine
            
            let x = self.viewInsets.left + rect.0 + minimumInteritemSpacing * CGFloat(tmp1 - 1)
            let y = self.viewInsets.top + rect.1 + minimumLineSpacing * CGFloat(tmp2 - 1)
            
            self.imagesRectInfo[tmp] = CGRectMake(x, y, rect.0, rect.1)
        }
    }
    
}



extension VVImageView {
    
    func touchPoint(point: CGPoint) -> Bool {
        
        
        
        return false
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        self.alpha = 1.0
    }
    
}































