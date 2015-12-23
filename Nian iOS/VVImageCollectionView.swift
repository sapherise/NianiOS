//
//  VVImageCollectionView.swift
//  Nian iOS
//
//  Created by WebosterBob on 12/6/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

let DEFAULT_IMAGE_WIDTH = globalWidth > 750 ? "!300xx" : "!200xx"

class VVImageCollectionView: UICollectionView {

    typealias DownloadedSingleImage = (image: UIImage, url: NSURL?) -> Void
    typealias ImageSelectedHandler = (path: String, indexPath: NSIndexPath) -> Void
    
    let placeholderImage = UIImage(named: "drop")

    var imageSelectedHandler: ImageSelectedHandler?
    var imagesDataSource = NSMutableArray()
    var sid: String = ""
    
    var containImages = [String: UIImage]()
    
    private var _imagesBaseURL = NSURL(string: "http://img.nian.so/step/")!
    
    var imagesBaseURL: NSURL {
        set(newValue) {
            self._imagesBaseURL = newValue
        }
        get {
            return self._imagesBaseURL
        }
    }

    let sd_manager = SDWebImageManager.sharedManager()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        
        self.registerClass(VVImageViewCell.self, forCellWithReuseIdentifier: "VVImageViewCell")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    func setImage() {
        self.downloadImages(self.imagesDataSource, callback: { (image, url) -> Void in
            if let _url = url {
                let _string = _url.absoluteString
                let _arr = _string.characters.split{ $0 == "/" }.map(String.init)
                let __arr = _arr.last!.characters.split{ $0 == "!" }.map(String.init)
                self.containImages[__arr.first!] = image
                
                for (var tmp = 0; tmp < self.imagesDataSource.count; tmp++) {
                    if ((self.imagesDataSource[tmp] as! NSDictionary)["path"] as! String) == __arr.first! {
                        self.reloadData()
                    }
                }
            }
        })
    }
    

    func downloadImages(urls: NSArray, callback: DownloadedSingleImage) {
        for (var tmp = 0; tmp < urls.count; tmp++) {
            let dict = self.imagesDataSource[tmp] as! NSDictionary
            let _imageURLString = dict["path"] as! String
            var _imageURL = NSURL(string: _imageURLString + DEFAULT_IMAGE_WIDTH, relativeToURL: self._imagesBaseURL)!
            
            if urls.count == 1 {
                _imageURL = NSURL(string: _imageURLString + "!large", relativeToURL: self._imagesBaseURL)!
            }
            
            sd_manager.downloadImageWithURL(_imageURL,
                options: SDWebImageOptions(rawValue: 0),
                progress: { (receivedSize, expectedSize) -> Void in
                    
                }, completed: { (image, error, cacheType, finished, imageURL) -> Void in
                    if let _ = error {
                        callback(image: self.placeholderImage!, url: NSURL())
                    } else {
                        callback(image: image, url: imageURL)
                    }
            })
        }
    }
    
    func cancelImageRequestOperation() {
        self.sd_manager.cancelAll()
        self.containImages.removeAll(keepCapacity: false)
        self.imagesDataSource.removeAllObjects()
    }
}

extension VVImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesDataSource.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VVImageViewCell", forIndexPath: indexPath) as! VVImageViewCell
        
        if indexPath.row < self.containImages.count {
            cell.imageView.image = self.containImages[(self.imagesDataSource[indexPath.row] as! NSDictionary)["path"] as! String]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.imagesDataSource.count > indexPath.row {
            imageSelectedHandler!(path: (self.imagesDataSource[indexPath.row] as! NSDictionary)["path"] as! String, indexPath: indexPath)
        }
    }
    
}

extension VVImageCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let tmpCount = self.imagesDataSource.count
        
        if tmpCount == 1 {
            return CGSizeMake(globalWidth - 32, globalWidth - 32)
        } else if tmpCount == 2 || tmpCount == 4 {
            let _tmp = floor((globalWidth - 32 - 2)/2)
            return CGSizeMake(_tmp, _tmp)
        } else if tmpCount > 0 {
            let _tmp = floor((globalWidth - 32 - 4) / 3)
            
            if tmpCount == 5 || tmpCount == 8 {
                if indexPath.row == tmpCount - 1 {
                    return CGSizeMake(_tmp * 2 + 2, _tmp)
                }
            } else if tmpCount == 7 {
                if indexPath.row == tmpCount - 1 {
                    return CGSizeMake(globalWidth - 32, _tmp)
                }
            }
            
            return CGSizeMake(_tmp, _tmp)
        }
        
        return CGSizeZero
    }
}

class VVImageViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let _imageview = UIImageView()
        _imageview.contentMode = .ScaleAspectFill
        _imageview.clipsToBounds = true
        return _imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView)
        constrain(self.imageView) { imageView in
            imageView.top    == imageView.superview!.top
            imageView.bottom == imageView.superview!.bottom
            imageView.left   == imageView.superview!.left
            imageView.right  == imageView.superview!.right
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}











































