//
//  PetTableViewGesture.swift
//  Nian iOS
//
//  Created by Sa on 15/7/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController {
    
    func showPetInfo() {
        petDetailView = NIAlert()
        petDetailView?.delegate = self
        let data = dataArray[current] as! NSDictionary
        let name = data.stringAttributeForKey("name")
        let level = data.stringAttributeForKey("level")
        let owned = data.stringAttributeForKey("owned")
        let description = data.stringAttributeForKey("description")
        var content = description
        
        var titleButton = "哦"
        if owned == "1" {
            titleButton = "分享"
            if let _level = Int(level) {
                let _tmp = 5 - _level % 5
                if _level  < 10 {
                    content += "\n\n（距离下次进化还有 \(_tmp) 级）"
                } else if _level < 15 {
                    content += "\n\n（距离满级还有 \(_tmp) 级）"
                } else if _level == 15 {
                    content += "\n\n（这只宠物满级了！）"
                }
            }
        } else {
            content += "\n\n（还没获得这个宠物...）"
        }
        petDetailView?.dict = NSMutableDictionary(objects: [self.imageView, name, content, [titleButton]],
            forKeys: ["img", "title", "content", "buttonArray"])
        petDetailView?.showWithAnimation(.flip)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }
        return true
    }
}
