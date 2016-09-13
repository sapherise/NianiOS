//
//  LSYAlbumModel.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/4.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import AssetsLibrary

open class LSYAlbumModel{
    var asset:ALAsset!
    var indexPath:IndexPath!
    var assetType:String!
    var isSelect:Bool
    init(data:ALAsset)
    {
        self.asset = data;
        self.isSelect = false
        self.assetType = data.value(forProperty: ALAssetPropertyType) as? String
    }
}
