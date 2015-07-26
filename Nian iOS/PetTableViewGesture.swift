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
    func setupGesture() {
        tapOnTableView = UITapGestureRecognizer(target: self, action: "showPetInfo")
        tapOnTableView!.delegate = self
        tableViewPet.addGestureRecognizer(tapOnTableView!)
    }
    
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
    
    /**
    主要是为了使 tableView 中间的 petNormal View 显示图片
    tableView 能响应滑动事件，也能在 petNormal View 范围内响应点击事件
    */
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let tHHeight = tableViewPet.tableHeaderView!.frame.height
        let tFHeight = tableViewPet.tableFooterView!.frame.height
        
        var tableViewCenter: CGFloat = globalWidth / 2.0
        
        if gestureRecognizer == tapOnTableView {
            var point = gestureRecognizer.locationInView(tableViewPet)
            var HeaderXInScreen: CGFloat = point.y - tableViewPet.contentOffset.y
            var FooterXInScreen: CGFloat = point.y - tableViewPet.contentOffset.y
            
            if abs(HeaderXInScreen - tableViewCenter) < 60 && abs(FooterXInScreen - tableViewCenter) < 60 {
                return true
            } else {
                return false
            }
        }
        return true
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
