//
//  AddReddit + Function.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import SpriteKit
import AssetsLibrary

extension AddStep {
    func onImage() {
        field2.resignFirstResponder()
        LSYAlbum.sharedAlbum().setupAlbumGroups { (groups) -> () in
            let albumPicker = LSYAlbumPicker()
            if groups.count > 0 {
                albumPicker.group = groups[0] as! ALAssetsGroup
                albumPicker.maxminumNumber = 9 - self.imageArray.count
                albumPicker.delegate = self
                self.navigationController?.pushViewController(albumPicker, animated: true)
            } else {
                self.showTipText("念没有访问照片的权限 >_<")
            }
        }
    }
    
    /* 上传队列完成后，准备提交到服务器 */
    func upYunMulti(_ data: NSDictionary?, count: Int) {
        go {
            if data != nil {
                self.uploadArray.add(data!)
            } else {
                let n = self.hasUploadedArray[count]
                let images = self.dataEdit!.object(forKey: "images") as! NSArray
                let image = images[n] as! NSDictionary
                self.uploadArray.add(image)
            }
            let num = count + 1
            /* 按照队列进行上传 */
            if self.imageArray.count > num {
                let op = UpyunOperation()
                op.num = num
                op.hasUploaded = self.hasUploadedArray[num] >= 0
                op.image = self.imageArray[num]
                op.delegate = self
                self.queue.addOperation(op)
            } else {
                /* 全部上传成功后，提交服务器 */
                self.addStep()
            }
        }
    }
    
    /* 提交服务器 */
    func addStep() {
        var type: Int = 5
        if field2.text == "" {
            if imageArray.count == 0 {
                /* 无文字，无图片，签到 */
                type = 1
            } else if imageArray.count == 1 {
                /* 无文字，单图片 */
                type = 6
            } else {
                /* 无文字，多图片 */
                type = 4
            }
        } else {
            if imageArray.count == 0 {
                /* 有文字，无图片 */
                type = 7
            } else if imageArray.count == 1 {
                /* 有文字，单图片 */
                type = 5
            } else {
                /* 有文字，多图片 */
                type = 3
            }
        }
        
        /* 不管编辑或新增，都把当前的记本 id 加入缓存 */
        Cookies.set(idDream as AnyObject?, forKey: "DreamNewest")
        
        if willEdit {
            let sid = dataEdit!.stringAttributeForKey("sid")
            AddStepModel.postEditStep(content: field2.text, stepType: type, images: uploadArray, sid: sid, callback: { (task, data, error) -> Void in
                if let d = data as? NSDictionary {
                    let error = d.stringAttributeForKey("error")
                    if error == "0" {
                        let mutableData = NSMutableDictionary(dictionary: self.dataEdit!)
                        mutableData.setValue(self.field2.text, forKey: "content")
                        mutableData.setValue(self.uploadArray, forKey: "images")
                        mutableData.setValue(type, forKey: "type")
                        if self.uploadArray.count > 0 {
                            if let image = self.uploadArray[0] as? NSDictionary {
                                mutableData.setValue(image.stringAttributeForKey("path"), forKey: "image")
                                mutableData.setValue(image.stringAttributeForKey("width"), forKey: "width")
                                mutableData.setValue(image.stringAttributeForKey("height"), forKey: "height")
                            }
                        } else {
                            mutableData.setValue("", forKey: "image")
                            mutableData.setValue("0", forKey: "width")
                            mutableData.setValue("0", forKey: "height")
                        }
                        
                        let heightContent = (self.field2.text as NSString).sizeWithConstrained(toWidth: globalWidth - 40, from: UIFont.systemFont(ofSize: 16), lineSpace: 5).height
                        var heightCell: CGFloat = 0
                        var heightImage: CGFloat = 0
                        
                        if type == 7 {
                            /* 无图，有文字 */
                            heightCell = heightContent + SIZE_PADDING * 4 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                        } else if type == 1 {
                            /* 无图，无文字 */
                            heightCell = 155 + 23
                        } else {
                            /* 多图带文字 */
                            if type == 3 {
                                let count = ceil(CGFloat(self.uploadArray.count) / 3)
                                let h = (globalWidth - SIZE_PADDING * 2 - SIZE_COLLECTION_PADDING * 2) / 3 + SIZE_COLLECTION_PADDING
                                heightImage = h * count - SIZE_COLLECTION_PADDING
                                heightCell = heightContent + heightImage + SIZE_PADDING * 5 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                            } else if type == 4 {
                                /* 多图不带文字 */
                                let count = ceil(CGFloat(self.uploadArray.count) / 3)
                                let h = (globalWidth - SIZE_PADDING * 2 - SIZE_COLLECTION_PADDING * 2) / 3 + SIZE_COLLECTION_PADDING
                                heightImage = h * count - SIZE_COLLECTION_PADDING
                                heightCell = heightImage + SIZE_PADDING * 4 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                            } else {
                                /* 单图 */
                                if let image = self.uploadArray[0] as? NSDictionary {
                                    let w = image.stringAttributeForKey("width").toCGFloat()
                                    let h = image.stringAttributeForKey("height").toCGFloat()
                                    heightImage = h * (globalWidth - 40) / w
                                    if type == 6 {
                                        /* 有文字，单图片 */
                                        heightCell = heightImage + SIZE_PADDING * 4 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                                    } else if type == 5 {
                                        /* 无文字，单图片 */
                                        heightCell = heightContent + heightImage + SIZE_PADDING * 5 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                                    }
                                }
                            }
                        }
                        mutableData["heightImage"] = heightImage
                        mutableData["heightCell"] = heightCell
                        mutableData["heightContent"] = heightContent
                        
                        self.delegate?.editStepRow = self.rowEdit
                        self.delegate?.editStepData = mutableData
                        self.delegate?.Editstep()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        } else {
            AddStepModel.postAddStep(content: field2.text, stepType: type, images: uploadArray, dreamId: idDream, callback: { (task, data, error) -> Void in
                if let d = data as? NSDictionary {
                    let error = d.stringAttributeForKey("error")
                    if error == "0" {
                        let result = d.object(forKey: "data") as! NSDictionary
                        let coin = result.stringAttributeForKey("coin")
                        let totalCoin = result.stringAttributeForKey("totalCoin")
                        let isfirst = result.stringAttributeForKey("isfirst")
                        self.field2.resignFirstResponder()
                        
                        let contentCard = self.field2.text
                        go {
                            /* 创建进展卡片 */
                            let modeCard = SACookie("modeCard")
                            if modeCard == "off" {
                            } else {
                                let card = (Bundle.main.loadNibNamed("Card", owner: self, options: nil))?.first as! Card
                                if self.uploadArray.count > 0 {
                                    let image = self.uploadArray[0] as! NSDictionary
                                    card.url = "http://img.nian.so/step/\(image.stringAttributeForKey("path"))!large"
                                    card.widthImage = image.stringAttributeForKey("width")
                                    card.heightImage = image.stringAttributeForKey("height")
                                }
                                card.content = contentCard!
                                card.onCardSave()
                            }
                        }
                        
                        /* 设置为空，以确保保存到 draft 里的内容为空 */
                        self.field2.text = ""
                        
                        if isfirst == "1" {
                            /* 更新后将新增加的念币加入缓存 */
                            if let coinBefore = Cookies.get("coin") as? String {
                                if let _coin = Int(coin) {
                                    let coinAfter = _coin + Int(coinBefore)!
                                    Cookies.set("\(coinAfter)" as AnyObject?, forKey: "coin")
                                }
                            }
                            Nian.saegg(coin, totalCoin: totalCoin)
                        }
                        let vc = DreamViewController()
                        vc.Id = self.idDream
                        vc.willBackToRootViewController = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        
                    } else {
                        self.showTipText("服务器坏了")
                    }
                } else {
                    self.showTipText("服务器坏了")
                }
            })
        }
    }
    
    /* 点击提交进展按钮 */
    func add() {
        self.setBarButtonLoading()
        go {
            if self.imageArray.count > 0 {
                self.queue.maxConcurrentOperationCount = 1
                if self.imageArray.count > 0 {
                    let op = UpyunOperation()
                    op.num = 0
                    /* 编辑图片为正，上传图片为负，如果大于等于零，就已上传 */
                    op.hasUploaded = self.hasUploadedArray[0] >= 0
                    op.image = self.imageArray[0]
                    op.delegate = self
                    self.queue.addOperation(op)
                }
            } else {
                self.addStep()
            }
        }
    }
    
    /* 筛选多图完成后调用 */
    func AlbumPickerDidFinishPick(_ assets:NSArray) {
        for asset in assets {
            if let a = asset as? ALAsset {
                if  (a.value(forProperty: "ALAssetPropertyType") as AnyObject).isEqual("ALAssetTypePhoto") {
                    imageArray.append(a)
                    hasUploadedArray.append(-1)
                }
            }
        }
        reLayout()
        self.navigationController?.popViewController(animated: true)
    }
    
    func onViewDream() {
        if tableView.isHidden {
            var hTableView = globalHeight - 64 - self.viewDream.height() - viewHolder.height() - keyboardHeight
            hTableView = max(hTableView, 0)
            tableView.setHeight(hTableView)
            tableView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.imageArrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            })
        } else {
            tableView.isHidden = true
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.imageArrow.transform = CGAffineTransform(rotationAngle: 0)
            })
        }
    }
    
    func reLayout() {
        collectionView.reloadData()
        let num = ceil(CGFloat(imageArray.count) / 3)
        var h = (globalWidth - size_field_padding * 2 - size_collectionview_padding * 2) / 3 + size_collectionview_padding
        h = num * h
        collectionView.setHeight(h)
        field2.setY(collectionView.bottom())
        labelPlaceholder.frame.origin = CGPoint(x: field2.x() + 6, y: field2.y() + 6)
        setScrollContentHeight()
    }
}


extension NIAlert {
    func evolution(_ url: String) {
        //        var _tmpImg = self.imgView?.image!
        
        UIView.animate(withDuration: 0.7, animations: {
            self.imgView!.setScale(0.8)
            }, completion: { (Bool) -> Void in
                UIView.animate(withDuration: 0.15, animations: {
                    self.imgView!.setScale(0.75)
                    }, completion: { (Bool) -> Void in
                        UIView.animate(withDuration: 0.15, animations: {
                            self.imgView!.setScale(0.8)
                            }, completion: { (Bool) -> Void in
                                UIView.animate(withDuration: 0.15, animations: {
                                    self.imgView!.setScale(0.75)
                                    }, completion: { (Bool) -> Void in
                                        UIView.animate(withDuration: 0.15, animations: {
                                            self.imgView!.setScale(0.8)
                                            }, completion: { (Bool) -> Void in
                                                UIView.animate(withDuration: 0.15, animations: {
                                                    self.imgView!.setScale(0.75)
                                                    }, completion: { (Bool) -> Void in
                                                        UIView.animate(withDuration: 0.2, animations: {
                                                            self.imgView!.setScale(1.15)
                                                            }, completion: { (Bool) -> Void in
                                                                self.imgView?.image = nil
                                                                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                                                                    let skView = SKView(frame: CGRect(x: 0, y: 0, width: 272, height: 108))
                                                                    if #available(iOS 8.0, *) {
                                                                        skView.allowsTransparency = true
                                                                    }
                                                                    self._containerView!.addSubview(skView)
                                                                    scene.scaleMode = SKSceneScaleMode.aspectFit
                                                                    skView.presentScene(scene)
                                                                    scene.setupViews()
                                                                    self._containerView?.sendSubview(toBack: skView)
                                                                }
                                                                delay(0.1, closure: {
                                                                    self.imgView!.setScale(1.35)
                                                                    self.imgView?.alpha = 0
                                                                    self.imgView?.setPet("http://img.nian.so/pets/\(url)!d")
                                                                    UIView.animate(withDuration: 0.1, animations: {
                                                                        self.imgView?.alpha = 1
                                                                        self.imgView!.setScale(1.55)
                                                                        }, completion: { (Bool) -> Void in
                                                                            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                                                                self.imgView!.setScale(1.2)
                                                                            })
                                                                            UIView.animate(withDuration: 1, delay: 1, options: UIViewAnimationOptions(), animations: {
                                                                                self.imgView!.setScale(1)
                                                                                }, completion: { (Bool) -> Void in
                                                                            })
                                                                    })
                                                                })
                                                        })
                                                })
                                        })
                                })
                        })
                })
        })
    }
}

extension UIView {
    func setScale(_ x: CGFloat) {
        self.transform = CGAffineTransform(scaleX: x, y: x)
    }
}
