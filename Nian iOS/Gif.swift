//
//  FLAnimatedImageView+Cached.swift
//  SDWebImageGifWithFLAnimatedImageDemo
//
//  Created by zhangping on 15/12/12.
//  Copyright © 2015年 zhangping. All rights reserved.
//

extension FLAnimatedImageView {
    
    public typealias QSProgressBlock = (Int, Int) -> Void
    
    public typealias QSCompletedBlock = (UIImage!, NSData!, NSError!, Bool) -> Void
    
    func qs_setGifImageWithURL(url: NSURL!, progress progressBlock: QSProgressBlock?, completed completedBlock: QSCompletedBlock?) {
        
        let imageData = imageDataFromDiskCacheForKey(url.absoluteString)
        
        if let data = imageData {
            /* 本地已有 gif 图片 */
            let image = FLAnimatedImage(animatedGIFData: data)
            self.animatedImage = image
            return
        }
        
        /* 本地无 gif 图片 */
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(url,
            options: SDWebImageDownloaderOptions(rawValue: 0),
            progress: { (recvSize, totalSize) -> Void in
                progressBlock?(recvSize, totalSize)
            }) { (image, gifData, error, finished) -> Void in
                //on image loaded
                if finished {
                    SDWebImageManager.sharedManager().imageCache.storeImage(image, recalculateFromImage: false,
                        imageData: gifData, forKey: url.absoluteString, toDisk: true)
                    /* 将图片添加到本地缓存 */
                    let gifImage = FLAnimatedImage(animatedGIFData: gifData)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.animatedImage = gifImage
                    })
                }
                completedBlock?(image, gifData, error, finished)
        }
    }
    
    private func imageDataFromDiskCacheForKey(key: String) -> NSData? {
        let defaultPath = SDWebImageManager.sharedManager().imageCache.defaultCachePathForKey(key)
        let data = NSData(contentsOfFile: defaultPath)
        
        return data
    }
}
