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
    public typealias albumGroupsBlock = (_ groups:NSMutableArray)->()
    public typealias albumAssetsBlock = (_ assets:NSMutableArray)->()
    //定义类的存储属性
    var assetsGroup:ALAssetsGroup!
    var assetsLibrary:ALAssetsLibrary!
    var assetsFilter:ALAssetsFilter!
    var groups:NSMutableArray!
    var assets:NSMutableArray!
    
    public class func sharedAlbum()->LSYAlbum! {
        struct LSYAlbumStruct {
            static var album:LSYAlbum!
        }
        
        let myGlobal = {
            LSYAlbumStruct.album = LSYAlbum()
            LSYAlbumStruct.album.assetsLibrary = ALAssetsLibrary()
            LSYAlbumStruct.album.assetsFilter = ALAssetsFilter.allAssets()
        }
        
        _ = myGlobal
        
        return LSYAlbumStruct.album;
    }
    public func setupAlbumGroups(albumGroups:@escaping albumGroupsBlock){
        let groups = NSMutableArray()
        let resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group:ALAssetsGroup!,stop:UnsafeMutablePointer<ObjCBool>)->Void in
            if group != nil {
                group.setAssetsFilter(self.assetsFilter)
                let groupType = (group.value(forProperty: ALAssetsGroupPropertyType) as AnyObject).integerValue
                if UInt32(groupType!)  == ALAssetsGroupSavedPhotos {
                    groups.insert(group, at: 0)
                }
                else
                {
                    if group.numberOfAssets()>0 {
                        groups.add(group)
                    }
                }
            }
            else{
                self.groups = groups
                albumGroups(groups)
            }
        } as! ALAssetsLibraryGroupsEnumerationResultsBlock
        let failureBlock:ALAssetsLibraryAccessFailureBlock = {(error:NSError!)->Void in
            self.groups = groups
            albumGroups(groups)
        } as! ALAssetsLibraryAccessFailureBlock
        self.assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: resultBlock, failureBlock: failureBlock)
    }
    public func setupAlbumAssets(group:ALAssetsGroup,albumAssets:@escaping albumAssetsBlock){
        let assets = NSMutableArray()
        group.setAssetsFilter(self.assetsFilter)
        let assetCount = group.numberOfAssets()
        let resultBlock :ALAssetsGroupEnumerationResultsBlock = { (asset:ALAsset!,index:Int,stop:UnsafeMutablePointer<ObjCBool>)->Void in
            if asset != nil {
                let model:LSYAlbumModel = LSYAlbumModel(data: asset)
                assets.add(model)
                let assetType:String! = model.asset.value(forProperty: ALAssetPropertyType) as? String
                if assetType == ALAssetTypePhoto {
                    
                }
                else if assetType == ALAssetTypeVideo {
                    
                }
            }
            else if assets.count >= assetCount {
                self.assets = assets;
                albumAssets(assets)
            }
        } as! ALAssetsGroupEnumerationResultsBlock
        group.enumerateAssets(options: NSEnumerationOptions.reverse, using: resultBlock)
    }
    
    
}
