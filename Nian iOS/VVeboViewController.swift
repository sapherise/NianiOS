//
//  VVeboViewController.swift
//  Nian iOS
//
//  Created by Sa on 15/10/17.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class VVeboViewController: UIViewController, SATableViewDelegate, delegateSAStepCell {
    var scrollToToping = false
    var needLoadArr = NSMutableArray()
    var SATableView: VVeboTableView!
    var dataArray = NSMutableArray()
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        needLoadArr.removeAllObjects()
    }
    
    // 正在滚动到顶部
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        scrollToToping = true
        return true
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollToToping = false
        loadContent()
    }
    
    // 已经滚动到顶部
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        scrollToToping = false
        loadContent()
    }
    
    func loadContent() {
        if scrollToToping {
            return
        }
        if SATableView.visibleCells.count > 0 {
            for temp in SATableView.visibleCells {
                if let cell = temp as? SACell {
                    cell.draw()
                }
            }
        }
    }
    
    func onTouch() {
        if !scrollToToping {
            needLoadArr.removeAllObjects()
            loadContent()
        }
    }
    
    func drawCell(cell: SACell, indexPath: NSIndexPath) {
        let data = dataArray[indexPath.row] as! NSDictionary
        cell.selectionStyle = .None
        cell.type = 1
        cell.delegate = self
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
    
    //按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let arr = NSMutableArray()
        let rowTarget = (SATableView.indexPathForRowAtPoint(targetContentOffset.memory)?.row)!    // 目标行
        let rowFirst = (SATableView.indexPathsForVisibleRows?.first?.row)!     // 可见的第一行
        let rowLast = (SATableView.indexPathsForVisibleRows?.last?.row)!      // 可见的最后一行
        if let temp = SATableView.indexPathsForRowsInRect(CGRectMake(0, targetContentOffset.memory.y, self.SATableView.width(), self.SATableView.height())) {
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
    
    // 更新数据
    func updateStep(index: Int, key: String, value: AnyObject) {
        SAUpdate(self.dataArray, index: index, key: key, value: value, tableView: self.SATableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        let numSection = max(SATableView.numberOfSections - 1, 0)
        SAUpdate(index, section: numSection, tableView: self.SATableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.SATableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        let numSection = max(SATableView.numberOfSections - 1, 0)
        SAUpdate(delete, dataArray: self.dataArray, index: index, tableView: self.SATableView, section: numSection)
    }
    
    // 用于 cellfor 函数
    func getCell(indexPath: NSIndexPath) -> UITableViewCell {
        var c = SATableView.dequeueReusableCellWithIdentifier("SACell") as? SACell
        if c == nil {
            c = SACell.init(style: .Default, reuseIdentifier: "SACell")
        }
        self.drawCell(c!, indexPath: indexPath)
        return c!
    }
    
    // 用于 heightfor 函数
    func getHeight(indexPath: NSIndexPath) -> CGFloat {
        let data = dataArray[indexPath.row] as! NSDictionary
        let height = data["heightCell"] as! CGFloat
        return height
    }
}