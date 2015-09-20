//
//  UIScrollView+Refresh.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func addHeaderWithCallback( callback:(() -> Void)!) {
        let header:RefreshHeaderView = RefreshHeaderView.footer()
        header.setWidth(self.width())
        self.addSubview(header)
        header.beginRefreshingCallback = callback
        header.addState(RefreshState.Normal)
    }
    
    func removeHeader() {
        for view : AnyObject in self.subviews{
            if view is RefreshHeaderView{
                view.removeFromSuperview()
            }
        }
    }
    
    func headerBeginRefreshing() {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                object.beginRefreshing()
                delay(3) { () -> () in
                    (object as! RefreshHeaderView).endRefreshing()
                }
            }
        }
    }
    
    
    func headerEndRefreshing(animated: Bool = true) {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                (object as! RefreshHeaderView).endRefreshing(animated)
            }
        }
        
    }
    
    func setHeaderHidden(hidden:Bool) {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                let view:UIView  = object as! UIView
                view.hidden = hidden
            }
        }
        
    }
    
    func isHeaderHidden() -> Bool {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                let view:UIView  = object as! UIView
                return view.hidden
            }
        }
        return true
    }
    
    func addFooterWithCallback( callback:(() -> Void)!) {
        let footer:RefreshFooterView = RefreshFooterView.footer()
        footer.setWidth(self.width())
        self.addSubview(footer)
        footer.beginRefreshingCallback = callback
        footer.addState(RefreshState.Normal)
    }
    
    
    func removeFooter()
    {
        
        for view : AnyObject in self.subviews{
            if view is RefreshFooterView{
                view.removeFromSuperview()
            }
        }
    }
    
    func footerBeginRefreshing()
    {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                object.beginRefreshing()
            }
        }
        
    }
    
    
    func footerEndRefreshing(animated: Bool = true)
    {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                (object as! RefreshFooterView).endRefreshing(animated)
            }
        }
        
    }
    
    func setFooterHidden(hidden:Bool)
    {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                let view:UIView  = object as! UIView
                view.hidden = hidden
            }
        }
        
    }
    
    func isFooterHidden() -> Bool {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                let view:UIView  = object as! UIView
                return view.hidden
            }
        }
        return true
    }
    
}