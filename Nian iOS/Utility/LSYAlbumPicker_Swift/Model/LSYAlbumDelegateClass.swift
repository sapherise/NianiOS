//
//  LSYAlbumDelegateClass.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/4.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
//MARK:- LSYAlbumCatalog
//MARK:UITableViewDataSource,UITableViewDelegate
extension LSYAlbumCatalog:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: LSYAlbumCatalogCell! = tableView.dequeueReusableCellWithIdentifier(self.kAlbumCatalogCellIdentifer) as? LSYAlbumCatalogCell
        if cell == nil {
            cell = LSYAlbumCatalogCell(style: UITableViewCellStyle.Value1, reuseIdentifier: self.kAlbumCatalogCellIdentifer)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        cell.group = self.dataArray[indexPath.row] as? ALAssetsGroup
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let albumPicker: LSYAlbumPicker! = LSYAlbumPicker()
        albumPicker.group = self.dataArray[indexPath.row] as! ALAssetsGroup
        albumPicker.delegate = self
        albumPicker.maxminumNumber = self.maximumNumberOfSelectionPhoto
        self.navigationController?.pushViewController(albumPicker, animated: true)
    }
}
//MARK:LSYAlbumPickerDelegate
extension LSYAlbumCatalog:LSYAlbumPickerDelegate
{
    func AlbumPickerDidFinishPick(assets: NSArray) {
        if self.delegate != nil {
            self.delegate.AlbumDidFinishPick(assets)
        }
    }
}
//MARK:- LSYAlbumPicker
//MARK:UICollectionViewDelegate,UICollectionViewDataSource
extension LSYAlbumPicker:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albumAssets.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: LSYAlbumPickerCell! = collectionView.dequeueReusableCellWithReuseIdentifier(albumPickerCellIdentifer, forIndexPath: indexPath) as? LSYAlbumPickerCell
        
        let model: LSYAlbumModel! = self.albumAssets[indexPath.row] as? LSYAlbumModel
        model.indexPath = indexPath
        cell.model = model
        cell.padding = padding
        cell.setup()
        cell.setupIsSelect()
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let model: LSYAlbumModel! = self.albumAssets[indexPath.row] as? LSYAlbumModel
        model.isSelect = !model.isSelect
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LSYAlbumPickerCell
        cell.setupIsSelect()
        selectedArray.append(indexPath.row)
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let model: LSYAlbumModel! = self.albumAssets[indexPath.row] as? LSYAlbumModel
        model.isSelect = !model.isSelect
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LSYAlbumPickerCell
        cell.setupIsSelect()
        if selectedArray.count > 0 {
            for i in 0...(selectedArray.count - 1) {
                if selectedArray[i] == indexPath.row {
                    selectedArray.removeAtIndex(i)
                    break
                }
            }
        }
//        collectionView.reloadData()
    }
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.maxminumNumber != 0 {
            if !(self.maxminumNumber > collectionView.indexPathsForSelectedItems()!.count){
                self.view.showTipText("最多只能 9 张...", delay: 1)
                return false
            }
            return true
        } else {
            return true
        }
    }
    
}