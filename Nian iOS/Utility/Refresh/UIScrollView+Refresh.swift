//
//  UIScrollView+Refresh.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func addHeaderWithCallback( _ callback:(() -> Void)!) {
        let header:RefreshHeaderView = RefreshHeaderView.footer()
        header.setWidth(self.width())
        self.addSubview(header)
        header.beginRefreshingCallback = callback
        header.addState(RefreshState.normal)
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
    
    
    func headerEndRefreshing(_ animated: Bool = true) {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                (object as! RefreshHeaderView).endRefreshing(animated)
            }
        }
        
    }
    
    func setHeaderHidden(_ hidden:Bool) {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                let view:UIView  = object as! UIView
                view.isHidden = hidden
            }
        }
        
    }
    
    func isHeaderHidden() -> Bool {
        for object : AnyObject in self.subviews{
            if object is RefreshHeaderView{
                let view:UIView  = object as! UIView
                return view.isHidden
            }
        }
        return true
    }
    
    func addFooterWithCallback( _ callback:(() -> Void)!) {
        let footer:RefreshFooterView = RefreshFooterView.footer()
        footer.setWidth(self.width())
        self.addSubview(footer)
        footer.beginRefreshingCallback = callback
        footer.addState(RefreshState.normal)
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
    
    
    func footerEndRefreshing(_ animated: Bool = true)
    {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                (object as! RefreshFooterView).endRefreshing(animated)
            }
        }
        
    }
    
    func setFooterHidden(_ hidden:Bool)
    {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                let view:UIView  = object as! UIView
                view.isHidden = hidden
            }
        }
        
    }
    
    func isFooterHidden() -> Bool {
        for object : AnyObject in self.subviews{
            if object is RefreshFooterView{
                let view:UIView  = object as! UIView
                return view.isHidden
            }
        }
        return true
    }
    
}
