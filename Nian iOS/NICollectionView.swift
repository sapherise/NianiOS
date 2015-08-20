//
//  NICollectionView.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/20/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class NICollectionView: UICollectionView {
    
    var disableScrollViewScroll: Bool = false
    
}

extension NICollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if disableScrollViewScroll {
            if otherGestureRecognizer.state == .Ended || otherGestureRecognizer.state == .Failed {
                (self.findRootViewController() as! ExploreViewController).scrollView.scrollEnabled = true
            }
            disableScrollViewScroll = false
        }
        
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
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        (self.findRootViewController() as! ExploreViewController).scrollView.scrollEnabled = false
        disableScrollViewScroll = true
        
        return true
    }
    
    
}