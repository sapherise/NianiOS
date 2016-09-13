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

    typealias DownloadedSingleImage = (_ image: UIImage, _ url: URL?) -> Void
    typealias ImageSelectedHandler = (_ path: String, _ indexPath: IndexPath) -> Void
    
    let placeholderImage = UIImage(named: "drop")

    var imageSelectedHandler: ImageSelectedHandler?
    var imagesDataSource = NSMutableArray()
    var sid: String = ""
    
    var containImages = [String: UIImage]()
    
    fileprivate var _imagesBaseURL = URL(string: "http://img.nian.so/step/")!
    
    var imagesBaseURL: URL {
        set(newValue) {
            self._imagesBaseURL = newValue
        }
        get {
            return self._imagesBaseURL
        }
    }

    let sd_manager = SDWebImageManager.shared()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        
        self.register(VVImageViewCell.self, forCellWithReuseIdentifier: "VVImageViewCell")
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
                
                for tmp in 0 ..< self.imagesDataSource.count {
                    if ((self.imagesDataSource[tmp] as! NSDictionary)["path"] as! String) == __arr.first! {
                        self.reloadData()
                    }
                }
            }
        })
    }
    

    func downloadImages(_ urls: NSArray, callback: @escaping DownloadedSingleImage) {
        for tmp in 0 ..< urls.count {
            let dict = self.imagesDataSource[tmp] as! NSDictionary
            let _imageURLString = dict["path"] as! String
            var _imageURL = URL(string: _imageURLString + DEFAULT_IMAGE_WIDTH, relativeTo: self._imagesBaseURL)!
            
            if urls.count == 1 {
                _imageURL = URL(string: _imageURLString + "!large", relativeTo: self._imagesBaseURL)!
            }
            
            sd_manager.downloadImage(with: _imageURL,
                options: SDWebImageOptions(rawValue: 0),
                progress: { (receivedSize, expectedSize) -> Void in
                    
                }, completed: { (image, error, cacheType, finished, imageURL) -> Void in
                    if let _ = error {
                        callback(image: self.placeholderImage!, url: URL())
                    } else {
                        callback(image: image, url: imageURL)
                    }
            })
        }
    }
    
    func cancelImageRequestOperation() {
        self.sd_manager?.cancelAll()
        self.containImages.removeAll(keepingCapacity: false)
        
        self.reloadData()
    }
}

extension VVImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesDataSource.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VVImageViewCell", for: indexPath) as! VVImageViewCell
        
        if (indexPath as NSIndexPath).row < self.containImages.count {
            cell.imageView.image = self.containImages[(self.imagesDataSource[(indexPath as NSIndexPath).row] as! NSDictionary)["path"] as! String]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.imagesDataSource.count > (indexPath as NSIndexPath).row {
            imageSelectedHandler!((self.imagesDataSource[(indexPath as NSIndexPath).row] as! NSDictionary)["path"] as! String, indexPath)
        }
    }
    
}

extension VVImageCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tmpCount = self.imagesDataSource.count
        
        if tmpCount == 1 {
            return CGSize(width: globalWidth - 32, height: globalWidth - 32)
        } else if tmpCount == 2 || tmpCount == 4 {
            let _tmp = floor((globalWidth - 32 - 2)/2)
            return CGSize(width: _tmp, height: _tmp)
        } else if tmpCount > 0 {
            let _tmp = floor((globalWidth - 32 - 4) / 3)
            
            if tmpCount == 5 || tmpCount == 8 {
                if (indexPath as NSIndexPath).row == tmpCount - 1 {
                    return CGSize(width: _tmp * 2 + 2, height: _tmp)
                }
            } else if tmpCount == 7 {
                if (indexPath as NSIndexPath).row == tmpCount - 1 {
                    return CGSize(width: globalWidth - 32, height: _tmp)
                }
            }
            
            return CGSize(width: _tmp, height: _tmp)
        }
        
        return CGSize.zero
    }
}

class VVImageViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let _imageview = UIImageView()
        _imageview.contentMode = .scaleAspectFill
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











































