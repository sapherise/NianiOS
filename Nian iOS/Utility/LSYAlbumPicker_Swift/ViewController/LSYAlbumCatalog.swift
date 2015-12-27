//
//  LSYAlbumCatalog.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/4.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

//MARK:唯类协议
protocol LSYAlbumCatalogDelegate:class {
    func AlbumDidFinishPick(assets:NSArray)->Void
}
@objc class LSYAlbumCatalog:SAViewController {
    let kAlbumCatalogCellIdentifer:String = "albumCatalogCellIdentifer"
    
    var maximumNumberOfSelectionPhoto:Int = 0{
        didSet{
            LSYAlbum.sharedAlbum().assetsFilter = ALAssetsFilter.allPhotos()
        }
    }
    var maximumNumberOfSelectionMedia:Int = 0{
        didSet{
            LSYAlbum.sharedAlbum().assetsFilter = ALAssetsFilter.allAssets()
        }
    }
    weak var delegate: LSYAlbumCatalogDelegate!
    var dataArray:NSMutableArray!
    private var albumTabView:UITableView!{
        didSet{
            albumTabView.delegate = self
            albumTabView.dataSource = self
            albumTabView.rowHeight = 70
            albumTabView.tableFooterView = UIView()
            self.view.addSubview(albumTabView)
        }
    }
    private func setup(){
        _setTitle("所有照片")
        self.dataArray = NSMutableArray()
        self.albumTabView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        LSYAlbum.sharedAlbum().setupAlbumGroups { (groups) -> () in
            self.dataArray = groups
            self.albumTabView.reloadData()
        }
    }
}
