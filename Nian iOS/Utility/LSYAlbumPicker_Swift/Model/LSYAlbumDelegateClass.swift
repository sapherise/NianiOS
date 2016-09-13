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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: LSYAlbumCatalogCell! = tableView.dequeueReusableCell(withIdentifier: self.kAlbumCatalogCellIdentifer) as? LSYAlbumCatalogCell
        if cell == nil {
            cell = LSYAlbumCatalogCell(style: UITableViewCellStyle.value1, reuseIdentifier: self.kAlbumCatalogCellIdentifer)
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        cell.group = self.dataArray[(indexPath as NSIndexPath).row] as? ALAssetsGroup
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let albumPicker: LSYAlbumPicker! = LSYAlbumPicker()
        albumPicker.group = self.dataArray[(indexPath as NSIndexPath).row] as! ALAssetsGroup
        albumPicker.delegate = self
        albumPicker.maxminumNumber = self.maximumNumberOfSelectionPhoto
        self.navigationController?.pushViewController(albumPicker, animated: true)
    }
}
//MARK:LSYAlbumPickerDelegate
extension LSYAlbumCatalog:LSYAlbumPickerDelegate
{
    func AlbumPickerDidFinishPick(_ assets: NSArray) {
        if self.delegate != nil {
            self.delegate.AlbumDidFinishPick(assets)
        }
    }
}
//MARK:- LSYAlbumPicker
//MARK:UICollectionViewDelegate,UICollectionViewDataSource
extension LSYAlbumPicker:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albumAssets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LSYAlbumPickerCell! = collectionView.dequeueReusableCell(withReuseIdentifier: albumPickerCellIdentifer, for: indexPath) as? LSYAlbumPickerCell
        
        let model: LSYAlbumModel! = self.albumAssets[(indexPath as NSIndexPath).row] as? LSYAlbumModel
        model.indexPath = indexPath
        cell.model = model
        cell.padding = padding
        cell.setup()
        cell.setupIsSelect()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model: LSYAlbumModel! = self.albumAssets[(indexPath as NSIndexPath).row] as? LSYAlbumModel
        model.isSelect = !model.isSelect
        let cell = collectionView.cellForItem(at: indexPath) as! LSYAlbumPickerCell
        cell.setupIsSelect()
        selectedArray.append((indexPath as NSIndexPath).row)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let model: LSYAlbumModel! = self.albumAssets[(indexPath as NSIndexPath).row] as? LSYAlbumModel
        model.isSelect = !model.isSelect
        let cell = collectionView.cellForItem(at: indexPath) as! LSYAlbumPickerCell
        cell.setupIsSelect()
        if selectedArray.count > 0 {
            for i in 0...(selectedArray.count - 1) {
                if selectedArray[i] == (indexPath as NSIndexPath).row {
                    selectedArray.remove(at: i)
                    break
                }
            }
        }
//        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if !(self.maxminumNumber > collectionView.indexPathsForSelectedItems!.count){
            self.showTipText("最多只能 9 张...", delayTime: 1)
            return false
        }
        return true
    }
    
}
