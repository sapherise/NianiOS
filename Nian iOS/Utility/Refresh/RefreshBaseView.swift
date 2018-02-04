//
//  RefreshBaseView.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-23.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//
import UIKit


let RefreshViewHeight:CGFloat = 64.0
let RefreshSlowAnimationDuration:TimeInterval = 0.2
let RefreshFooterPullToRefresh:NSString = "上拉加载"
let RefreshFooterReleaseToRefresh:NSString =  "放开加载"
let RefreshFooterRefreshing:NSString =  ""
let RefreshHeaderPullToRefresh:NSString =  "下拉刷新"
let RefreshHeaderReleaseToRefresh:NSString =  "放开刷新"
let RefreshHeaderRefreshing:NSString =  ""
let RefreshHeaderTimeKey:NSString =  "RefreshHeaderView"
let RefreshContentOffset:NSString =  "contentOffset"
let RefreshContentSize:NSString =  "contentSize"

//控件的刷新状态
enum RefreshState {
    case  pulling               // 放开就可以进行刷新的状态
    case  normal                // 普通状态
    case  refreshing            // 正在刷新中的状态
    case  willRefreshing
}

//控件的类型
enum RefreshViewType {
    case  typeHeader             // 头部控件
    case  typeFooter             // 尾部控件
}
let RefreshLabelTextColor:UIColor = UIColor.HighlightColor()


class RefreshBaseView: UIView {
    
    
    //  父控件
    var scrollView:UIScrollView!
    var scrollViewOriginalInset:UIEdgeInsets!
    
    // 内部的控件
    var statusLabel:UILabel!
    var activityView:UIActivityIndicatorView!
    
    //回调
    var beginRefreshingCallback:(()->Void)?
    
    // 交给子类去实现 和 调用
    var  oldState:RefreshState?
    
    var State:RefreshState = RefreshState.normal{
        willSet{
        }
        didSet{
            
        }
        
    }
    
    func setState(_ newValue:RefreshState){
        
        
        if self.State != RefreshState.refreshing {
            
            scrollViewOriginalInset = self.scrollView.contentInset;
        }
        if self.State == newValue {
            return
        }
        switch newValue {
        case .normal:
            self.activityView.stopAnimating()
            break
        case .pulling:
            break
        case .refreshing:
            activityView.startAnimating()
            beginRefreshingCallback!()
            break
        default:
            break
            
        }
        
        
    }
    
    
    //控件初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //状态标签
        statusLabel = UILabel()
        statusLabel.autoresizingMask = UIViewAutoresizing.flexibleWidth
        statusLabel.font = UIFont.boldSystemFont(ofSize: 13)
        statusLabel.textColor = RefreshLabelTextColor
        statusLabel.backgroundColor =  UIColor.clear
        statusLabel.textAlignment = NSTextAlignment.center
        self.addSubview(statusLabel)
        //self.addSubview(arrowImage)
        //状态标签
        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.color = UIColor.HighlightColor()
//        activityView.bounds = self.arrowImage.bounds
        activityView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        self.addSubview(activityView)
        //自己的属性
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
        //设置默认状态
        self.State = RefreshState.normal;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //箭头
        let arrowX:CGFloat = self.frame.size.width * 0.5 - 50
        //指示器
        self.activityView.center = CGPoint(x: arrowX, y: self.frame.size.height * 0.5 + 10.0)
    }
    
    
    override func willMove(toSuperview newSuperview: UIView!) {
        super.willMove(toSuperview: newSuperview)
        // 旧的父控件
        
        //        if (self.superview != nil) {
        //            self.superview.removeObserver(self,forKeyPath:RefreshContentSize,context: nil)
        //            }
        // 新的父控件
        if (newSuperview != nil) {
            newSuperview.addObserver(self, forKeyPath: RefreshContentOffset as String, options: NSKeyValueObservingOptions.new, context: nil)
            var rect:CGRect = self.frame
            // 设置宽度   位置
            rect.size.width = newSuperview.frame.size.width
            rect.origin.x = 0
            self.frame = frame;
            //UIScrollView
            scrollView = newSuperview as! UIScrollView
            scrollViewOriginalInset = scrollView.contentInset;
        }
    }
    
    // 刷新相关
    // 是否正在刷新
    func isRefreshing()->Bool{
        return RefreshState.refreshing == self.State;
    }
    
    // 开始刷新
    @objc func beginRefreshing(){
         self.State = RefreshState.refreshing
//        if (self.window != nil) {
//            self.State = RefreshState.Refreshing;
//        } else {
//            //不能调用set方法
//            State = RefreshState.WillRefreshing;
//            super.setNeedsDisplay()
//        }
    }
    
    //结束刷新
    func endRefreshing(_ animated: Bool = true) {
        if animated {
            let delayInSeconds:Double = 0.3
            let popTime:DispatchTime = DispatchTime.now() + Double(Int64(delayInSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
                self.State = RefreshState.normal
            })
        } else {
            self.State = RefreshState.normal
        }
    }
}
