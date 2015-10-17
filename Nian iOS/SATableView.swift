//
//  SATableView.swift
//  Nian iOS
//
//  Created by Sa on 15/10/14.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class VVeboTableView: UITableView {
    var scrollToToping = false
    var needLoadArr = NSMutableArray()
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 用户触摸时第一时间加载内容
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        onTouch()
        return super.hitTest(point, withEvent: event)
    }
    
    func needLoadArrRemoveAll() {
        needLoadArr.removeAllObjects()
    }
    
    func setscrollToToping(isToToping: Bool) {
        scrollToToping = isToToping
    }
    
    func onTouch() {
        if !scrollToToping {
            needLoadArr.removeAllObjects()
            loadContent()
        }
    }
    
    func setFalseAndLoadContent() {
        scrollToToping = false
        loadContent()
    }
    
    func loadContent() {
        if scrollToToping {
            return
        }
        if self.visibleCells.count > 0 {
            for temp in self.visibleCells {
                if let cell = temp as? SACell {
                    cell.draw()
                }
            }
        }
    }
    
    func drawCell(cell: SACell, indexPath: NSIndexPath, dataArray: NSMutableArray) {
        let data = dataArray[indexPath.row] as! NSDictionary
        cell.selectionStyle = .None
        cell.type = 1
        // 复用时，清除原有内容
        if cell.num != indexPath.row {
            cell.clear()
            cell.num = indexPath.row
        }
        cell.data = data
        
        // 当快速滚动时，判断绘制的 cell 在不在 needLoadArr 数组内
        // 如果不存在，就 clear
        if needLoadArr.count > 0 && needLoadArr.indexOfObject(indexPath.row) >= needLoadArr.count {
            cell.clear()
            return
        }
        if scrollToToping {
            return
        }
        cell.draw()
    }
    
    func loadIfNeed(velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let arr = NSMutableArray()
        let rowTarget = (self.indexPathForRowAtPoint(targetContentOffset.memory)?.row)!    // 目标行
        let rowFirst = (self.indexPathsForVisibleRows?.first?.row)!     // 可见的第一行
        let rowLast = (self.indexPathsForVisibleRows?.last?.row)!      // 可见的最后一行
        if let temp = self.indexPathsForRowsInRect(CGRectMake(0, targetContentOffset.memory.y, self.width(), self.height())) {
            for i in temp {
                let row = i.row
                arr.addObject(row)
            }
        }   // 目标行的整屏
        
        var shouldClear = false
        
        // 向上滚动时，加载目标行下几行
        if velocity.y < 0 && rowLast - rowTarget > 8 {
            shouldClear = true
            arr.addObject(rowTarget + 1)
            arr.addObject(rowTarget + 2)
            arr.addObject(rowTarget + 3)
            // 向下滚动时，加载目标行上几行
        } else if rowTarget - rowFirst > 8 {
            shouldClear = true
            arr.addObject(rowTarget - 1)
            arr.addObject(rowTarget - 2)
            arr.addObject(rowTarget - 3)
        }
        if shouldClear {
            needLoadArr.addObjectsFromArray(arr as [AnyObject])
        }
    }
    
    // 用于 heightfor 函数
    func getHeight(indexPath: NSIndexPath, dataArray: NSMutableArray) -> CGFloat {
        let data = dataArray[indexPath.row] as! NSDictionary
        let height = data["heightCell"] as! CGFloat
        return height
    }
    
    // 用于 cellfor 函数
    func getCell(indexPath: NSIndexPath, dataArray: NSMutableArray) -> SACell {
        var c = self.dequeueReusableCellWithIdentifier("SACell") as? SACell
        if c == nil {
            c = SACell.init(style: .Default, reuseIdentifier: "SACell")
        }
        drawCell(c!, indexPath: indexPath, dataArray: dataArray)
        return c!
    }
    
}
