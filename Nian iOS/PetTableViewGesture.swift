//
//  PetTableViewGesture.swift
//  Nian iOS
//
//  Created by Sa on 15/7/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController: UIGestureRecognizerDelegate, NIAlertDelegate {
    
    func showPetInfo() {
        petDetailView = NIAlert()
        petDetailView?.delegate = self
        var data = dataArray[current] as! NSDictionary
        var name = data.stringAttributeForKey("name")
        var level = data.stringAttributeForKey("level")
        var owned = data.stringAttributeForKey("owned")
        var content = "\n升到 5 级时会进化"
        if let _level = level.toInt() {
            if _level >= 5 && _level < 10 {
                content = "\n升到 10 级时会进化"
            } else if _level == 15 {
                content = "\n这只宠物满级了！"
            } else if _level >= 10 {
                content = ""
            }
        }
        var titleButton = "哦"
        if owned == "1" {
            content = "当前等级为 \(level) 级\(content)"
            titleButton = "分享"
        } else {
            content = "还没获得这个宠物..."
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

extension UIImageView {
    func setImageGray(urlString: String) {
        var url = NSURL(string: urlString)
        self.image = nil
        self.backgroundColor = UIColor.clearColor()
        var req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        self.setImageWithURLRequest(req,
            placeholderImage: nil,
            success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                self.image = image.convertToGrayscale()
                self.contentMode = .ScaleAspectFill
            },
            failure: nil)
    }
}
