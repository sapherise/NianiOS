//
//  RefreshHeaderView.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit
class RefreshHeaderView: RefreshBaseView {
    class func footer()->RefreshHeaderView{
        let footer:RefreshHeaderView  = RefreshHeaderView(frame: CGRectMake(0, 0,   UIScreen.mainScreen().bounds.width, RefreshViewHeight))
        return footer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let statusX:CGFloat = 0
        let statusY:CGFloat = 0
        let statusHeight:CGFloat = self.frame.size.height
        let statusWidth:CGFloat = self.frame.size.width
        //状态标签
        self.statusLabel.frame = CGRectMake(statusX, statusY + 10.0, statusWidth, statusHeight)
        //指示器
        self.activityView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 10.0)
    }
    
    override func willMoveToSuperview(newSuperview: UIView!) {
        super.willMoveToSuperview(newSuperview)
         // 设置自己的位置和尺寸
        var rect:CGRect = self.frame
        rect.origin.y = -self.frame.size.height
        self.frame = rect
    }
    
    //监听UIScrollView的contentOffset属性
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
                if (!self.userInteractionEnabled || self.hidden){
                    return
                }
                if (self.State == RefreshState.Refreshing) {
                    return
                }
                if RefreshContentOffset.isEqualToString(keyPath!){
                    self.adjustStateWithContentOffset()
                }
    }
   
    
    //调整状态
    func adjustStateWithContentOffset()
    {
        let currentOffsetY:CGFloat = self.scrollView.contentOffset.y
        let happenOffsetY:CGFloat = -self.scrollViewOriginalInset.top
        if (currentOffsetY >= happenOffsetY) {
            return
        }
        if self.scrollView.dragging{
            let normal2pullingOffsetY:CGFloat = happenOffsetY - self.frame.size.height
            if  self.State == RefreshState.Normal && currentOffsetY < normal2pullingOffsetY{
                self.State = RefreshState.Pulling
            }else if self.State == RefreshState.Pulling && currentOffsetY >= normal2pullingOffsetY{
                self.State = RefreshState.Normal
            }
            
        } else if self.State == RefreshState.Pulling {
            self.State = RefreshState.Refreshing
        }
    }
    
    //设置状态
    override  var State:RefreshState {
    willSet {
        if  State == newValue{
            return;
        }
        oldState = State
        setState(newValue)
    }
    didSet{
        switch State{
        case .Normal:
            self.statusLabel.text = RefreshHeaderPullToRefresh as String
            if RefreshState.Refreshing == oldState {
                UIView.animateWithDuration(RefreshSlowAnimationDuration, animations: {
                    var contentInset:UIEdgeInsets = self.scrollView.contentInset
                    contentInset.top = self.scrollViewOriginalInset.top
                    self.scrollView.contentInset = contentInset
                    })
                
            }
            break
        case .Pulling:
            // 在这里
            self.statusLabel.text = RefreshHeaderReleaseToRefresh as String
            break
        case .Refreshing:
            self.statusLabel.text =  RefreshHeaderRefreshing as String;
            
            UIView.animateWithDuration(RefreshSlowAnimationDuration, animations: {
                let top:CGFloat = self.scrollViewOriginalInset.top + self.frame.size.height
                var inset:UIEdgeInsets = self.scrollView.contentInset
                inset.top = top
                self.scrollView.contentInset = inset
                var offset:CGPoint = self.scrollView.contentOffset
                offset.y = -top
                self.scrollView.contentOffset = offset
                })
            break
        default:
            break
            
        }
    }
    }
    
    func addState(state:RefreshState){
        self.State = state
    }
}
    