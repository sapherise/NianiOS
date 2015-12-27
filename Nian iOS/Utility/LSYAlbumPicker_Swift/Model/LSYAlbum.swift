//
//  LSYAlbum.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/4.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import AssetsLibrary
public class LSYAlbum {
    //定义block
    public typealias albumGroupsBlock = (groups:NSMutableArray)->()
    public typealias albumAssetsBlock = (assets:NSMutableArray)->()
    //定义类的存储属性
    var assetsGroup:ALAssetsGroup!
    var assetsLibrary:ALAssetsLibrary!
    var assetsFilter:ALAssetsFilter!
    var groups:NSMutableArray!
    var assets:NSMutableArray!
    
    public class func sharedAlbum()->LSYAlbum! {
        struct LSYAlbumStruct {
            static var album:LSYAlbum!
            static var onceToken:dispatch_once_t = 0
        }
        dispatch_once(&LSYAlbumStruct.onceToken, { () -> Void in
            LSYAlbumStruct.album = LSYAlbum()
            LSYAlbumStruct.album.assetsLibrary = ALAssetsLibrary()
            LSYAlbumStruct.album.assetsFilter = ALAssetsFilter.allAssets()
        })
        return LSYAlbumStruct.album;
    }
    
    public func setupAlbumGroups(albumGroups:albumGroupsBlock){
        let groups = NSMutableArray()
        let resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group:ALAssetsGroup!,stop:UnsafeMutablePointer<ObjCBool>)->Void in
            if group != nil {
                group.setAssetsFilter(self.assetsFilter)
                let groupType = group.valueForProperty(ALAssetsGroupPropertyType).integerValue
                if UInt32(groupType)  == ALAssetsGroupSavedPhotos {
                    groups.insertObject(group, atIndex: 0)
                } else {
                    if group.numberOfAssets()>0 {
                        groups.addObject(group)
                    }
                }
            } else{
                self.groups = groups
                albumGroups(groups: groups)
            }
        }
        let failureBlock:ALAssetsLibraryAccessFailureBlock = {(error:NSError!)->Void in
            self.groups = groups
            albumGroups(groups: groups)
        }
        self.assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: resultBlock, failureBlock: failureBlock)
    }
    
    public func setupAlbumAssets(group:ALAssetsGroup,albumAssets:albumAssetsBlock){
        let assets = NSMutableArray()
        group.setAssetsFilter(self.assetsFilter)
        let assetCount = group.numberOfAssets()
        let resultBlock :ALAssetsGroupEnumerationResultsBlock = { (asset:ALAsset!,index:Int,stop:UnsafeMutablePointer<ObjCBool>)->Void in
            if asset != nil {
                let model:LSYAlbumModel = LSYAlbumModel(data: asset)
                assets.addObject(model)
                let assetType:String! = model.asset.valueForProperty(ALAssetPropertyType) as? String
                if assetType == ALAssetTypePhoto {
                    
                }
            }
            else if assets.count >= assetCount {
                self.assets = assets;
                albumAssets(assets: assets)
            }
        }
        group.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: resultBlock)
    }
    
    
}
