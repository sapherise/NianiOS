//
//  FLAnimatedImageView+Cached.swift
//  SDWebImageGifWithFLAnimatedImageDemo
//
//  Created by zhangping on 15/12/12.
//  Copyright © 2015年 zhangping. All rights reserved.
//

extension FLAnimatedImageView {
    
    public typealias QSProgressBlock = (Int, Int) -> Void
    
    public typealias QSCompletedBlock = (UIImage?, Data?, NSError?, Bool) -> Void
    
    func qs_setGifImageWithURL(_ url: URL!, progress progressBlock: QSProgressBlock?, completed completedBlock: QSCompletedBlock?) {
        
        let imageData = imageDataFromDiskCacheForKey(url.absoluteString)
        
        if let data = imageData {
            /* 本地已有 gif 图片 */
            let image = FLAnimatedImage(animatedGIFData: data)
            self.animatedImage = image
            return
        }
        
        /* 本地无 gif 图片 */
        SDWebImageDownloader.shared().downloadImage(with: url,
            options: SDWebImageDownloaderOptions(rawValue: 0),
            progress: { (recvSize, totalSize) -> Void in
                progressBlock?(recvSize, totalSize)
            }) { (image, gifData, error, finished) -> Void in
                //on image loaded
                if finished {
                    SDWebImageManager.shared().imageCache.store(image, recalculateFromImage: false,
                        imageData: gifData, forKey: url.absoluteString, toDisk: true)
                    /* 将图片添加到本地缓存 */
                    let gifImage = FLAnimatedImage(animatedGIFData: gifData)
                    back {
                        self.animatedImage = gifImage
                    }
                }
                completedBlock?(image, gifData, error as NSError!, finished)
        }
    }
    
    fileprivate func imageDataFromDiskCacheForKey(_ key: String) -> Data? {
        let defaultPath = SDWebImageManager.shared().imageCache.defaultCachePath(forKey: key)
        let data = try? Data(contentsOf: URL(fileURLWithPath: defaultPath!))
        
        return data
    }
}
