//
//  AddReddit + Function.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import SpriteKit

extension AddStep {
    func onImage() {
        print("点击了图片")
    }
    
    func add() {
        print("发布")
    }
    
    func onViewDream() {
        if tableView.hidden {
            var hTableView = globalHeight - 64 - self.viewDream.height() - viewHolder.height() - seperatorView2.height() * 2 - keyboardHeight
            hTableView = max(hTableView, 0)
            tableView.setHeight(hTableView)
            tableView.hidden = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            })
        } else {
            tableView.hidden = true
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageArrow.transform = CGAffineTransformMakeRotation(0)
            })
        }
    }
}


extension NIAlert {
    func evolution(url: String) {
        //        var _tmpImg = self.imgView?.image!
        
        UIView.animateWithDuration(0.7, animations: {
            self.imgView!.setScale(0.8)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.15, animations: {
                    self.imgView!.setScale(0.75)
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.15, animations: {
                            self.imgView!.setScale(0.8)
                            }, completion: { (Bool) -> Void in
                                UIView.animateWithDuration(0.15, animations: {
                                    self.imgView!.setScale(0.75)
                                    }, completion: { (Bool) -> Void in
                                        UIView.animateWithDuration(0.15, animations: {
                                            self.imgView!.setScale(0.8)
                                            }, completion: { (Bool) -> Void in
                                                UIView.animateWithDuration(0.15, animations: {
                                                    self.imgView!.setScale(0.75)
                                                    }, completion: { (Bool) -> Void in
                                                        UIView.animateWithDuration(0.2, animations: {
                                                            self.imgView!.setScale(1.15)
                                                            }, completion: { (Bool) -> Void in
                                                                self.imgView?.image = nil
                                                                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                                                                    let skView = SKView(frame: CGRectMake(0, 0, 272, 108))
                                                                    if #available(iOS 8.0, *) {
                                                                        skView.allowsTransparency = true
                                                                    }
                                                                    self._containerView!.addSubview(skView)
                                                                    scene.scaleMode = SKSceneScaleMode.AspectFit
                                                                    skView.presentScene(scene)
                                                                    scene.setupViews()
                                                                    self._containerView?.sendSubviewToBack(skView)
                                                                }
                                                                delay(0.1, closure: {
                                                                    self.imgView!.setScale(1.35)
                                                                    self.imgView?.alpha = 0
                                                                    self.imgView?.setPet("http://img.nian.so/pets/\(url)!d")
                                                                    UIView.animateWithDuration(0.1, animations: {
                                                                        self.imgView?.alpha = 1
                                                                        self.imgView!.setScale(1.55)
                                                                        }, completion: { (Bool) -> Void in
                                                                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                                                                self.imgView!.setScale(1.2)
                                                                            })
                                                                            UIView.animateWithDuration(1, delay: 1, options: UIViewAnimationOptions(), animations: {
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
    func setScale(x: CGFloat) {
        self.transform = CGAffineTransformMakeScale(x, x)
    }
}