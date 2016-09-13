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
        self.separatorStyle = .none
        self.backgroundColor = UIColor.BackgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 用户触摸时第一时间加载内容
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        onTouch()
        return super.hitTest(point, with: event)
    }
    
    func needLoadArrRemoveAll() {
        needLoadArr.removeAllObjects()
    }
    
    func setscrollToToping(_ isToToping: Bool) {
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
                if let cell = temp as? VVeboCell {
                    cell.draw()
                }
            }
        }
    }
    
    func drawCell(_ cell: VVeboCell, indexPath: IndexPath, dataArray: NSMutableArray) {
        if (indexPath as NSIndexPath).row < dataArray.count {
            let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.selectionStyle = .none
            // 复用时，清除原有内容
            if cell.num != (indexPath as NSIndexPath).row || globalVVeboReload {
                cell.num = (indexPath as NSIndexPath).row
                cell.clear()
            }
            cell.data = data
            
            // 当快速滚动时，判断绘制的 cell 在不在 needLoadArr 数组内
            // 如果不存在，就 clear
            if needLoadArr.count > 0 && needLoadArr.index(of: (indexPath as NSIndexPath).row) >= needLoadArr.count {
                cell.clear()
                return
            }
            if scrollToToping {
                return
            }
            cell.draw()
        }
    }
    
    func loadIfNeed(_ velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let arr = NSMutableArray()
        if let rowTarget = (self.indexPathForRow(at: targetContentOffset.pointee) as NSIndexPath?)?.row {
            if let rowFirst = (self.indexPathsForVisibleRows?.first as NSIndexPath?)?.row {   // 可见的第一行
                let rowLast = ((self.indexPathsForVisibleRows?.last as NSIndexPath?)?.row)!      // 可见的最后一行
                if let temp = self.indexPathsForRows(in: CGRect(x: 0, y: targetContentOffset.pointee.y, width: self.width(), height: self.height())) {
                    for i in temp {
                        let row = (i as NSIndexPath).row
                        arr.add(row)
                    }
                }   // 目标行的整屏
                
                var shouldClear = false
                
                // 向上滚动时，加载目标行下几行
                if velocity.y < 0 && rowLast - rowTarget > 8 {
                    shouldClear = true
                    arr.add(rowTarget + 1)
                    arr.add(rowTarget + 2)
                    arr.add(rowTarget + 3)
                    // 向下滚动时，加载目标行上几行
                } else if rowTarget - rowFirst > 8 {
                    shouldClear = true
                    arr.add(rowTarget - 1)
                    arr.add(rowTarget - 2)
                    arr.add(rowTarget - 3)
                }
                if shouldClear {
                    needLoadArr.addObjects(from: arr as [AnyObject])
                }
            }
        }
    }
    
    // 用于 heightfor 函数
    func getHeight(_ indexPath: IndexPath, dataArray: NSMutableArray) -> CGFloat {
        let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let height = data["heightCell"] as! CGFloat
        return height
    }
    
    // 不要直接用于 cellfor，因为这个函数里没有 delegate
    func getCell(_ indexPath: IndexPath, dataArray: NSMutableArray, type: Int) -> VVeboCell {
        var c = self.dequeueReusableCell(withIdentifier: "VVeboCell") as? VVeboCell
        if c == nil {
            c = VVeboCell.init(style: .default, reuseIdentifier: "VVeboCell")
        }
        c?.type = type
        drawCell(c!, indexPath: indexPath, dataArray: dataArray)
        return c!
    }
    
    // 清除已显示在屏幕上的 cell，否则会文本错位
    func clearVisibleCell() {
        for c in self.visibleCells {
            if let cell = c as? VVeboCell {
                cell.clear()
            }
        }
    }
    
    
}
