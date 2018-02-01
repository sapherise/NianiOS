//
//  images.swift
//  NianiOS
//
//  Created by Sa on 2016/10/22.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import Photos

protocol imagesPickerDelegate {
    func imagesPickerDidFinishPick(_ assets: [PHAsset])
}

class imagesViewController: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var dataArray = NSMutableArray()
    let padding: CGFloat = 8
    var fetchResult: PHFetchResult<PHAsset>!
    fileprivate let imageManager = PHCachingImageManager()
    var numSelected = 0
    var indexSeleted: [Int] = []
    var delegate: imagesPickerDelegate?
    var max = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("相册")
        self.view.backgroundColor = UIColor.black
        setBarButtonImage("newOK", actionGesture: #selector(self.onOK))
        
        let w = (globalWidth - padding * 2) / 3
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = 0
        let size = CGSize(width: w, height: w)
        layout.itemSize = size
        layout.sectionInset = UIEdgeInsetsMake(padding, 0, padding, 0)
        
        let rect = CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64)
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.allowsMultipleSelection = true
        collectionView.register(UINib(nibName: "LSYAlbumPickerCell", bundle: nil), forCellWithReuseIdentifier: "albumPickerCellIdentifer")
        self.view.addSubview(collectionView)
        
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: option)
        if fetchResult.count > 0 {
            for i in 0...(fetchResult.count - 1) {
                let asset = fetchResult.object(at: i)
                let data = ["asset": asset, "selected": false] as [String : Any]
                dataArray.add(data)
            }
        }
    }
    
    @objc func onOK() {
        var arr: [PHAsset] = []
        if indexSeleted.count > 0 {
            for i in 0...(indexSeleted.count - 1) {
                let num = indexSeleted[i]
                let asset = fetchResult.object(at: num)
                arr.append(asset)
            }
        }
        delegate?.imagesPickerDidFinishPick(arr)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "albumPickerCellIdentifer", for: indexPath) as! LSYAlbumPickerCell
        if let data = dataArray[indexPath.row] as? NSDictionary {
            if let asset = data.object(forKey: "asset") as? PHAsset {
                let w = (globalWidth - padding * 2) / 3
                let size = CGSize(width: w, height: w)
                imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { (image, _) in
                    if c.imageView.image != image {
                        c.imageView.image = image
                    }
                }
            }
            if let selected = data.object(forKey: "selected") as? Bool {
                c.imageView.layer.borderWidth = selected ? 8 : 0
            }
        }
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = dataArray[indexPath.row] as? NSDictionary {
            if let selected = data.object(forKey: "selected") as? Bool {
                if selected {
                    numSelected -= 1
                    if indexSeleted.count > 0 {
                        for i in 0...(indexSeleted.count - 1) {
                            if indexSeleted[i] == indexPath.row {
                                indexSeleted.remove(at: i)
                                break
                            }
                        }
                    }
                    let d = NSMutableDictionary(dictionary: data)
                    d.setValue(!selected, forKey: "selected")
                    dataArray.replaceObject(at: indexPath.row, with: d)
                    collectionView.reloadData()
                } else {
                    if numSelected < max {
                        numSelected += 1
                        indexSeleted.append(indexPath.row)
                        let d = NSMutableDictionary(dictionary: data)
                        d.setValue(!selected, forKey: "selected")
                        dataArray.replaceObject(at: indexPath.row, with: d)
                        collectionView.reloadData()
                    } else {
                        self.showTipText("最多只能 9 张...")
                    }
                }
            }
        }
    }
}
