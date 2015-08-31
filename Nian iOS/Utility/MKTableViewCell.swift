//
//  MKTableViewCell.swift
//  MaterialKit
//
//  Created by Le Van Nghia on 11/15/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit

class MKTableViewCell : UITableViewCell {
    @IBInspectable var rippleLocation: MKRippleLocation = .TapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    @IBInspectable var circleAniDuration: Float = 0.75
    @IBInspectable var backgroundAniDuration: Float = 1.0
    @IBInspectable var circleAniTimingFunction: MKTimingFunction = .Linear
    @IBInspectable var shadowAniEnabled: Bool = true
    
    // color
    @IBInspectable var circleLayerColor: UIColor = UIColor(red:0.42, green:0.81, blue:0.99, alpha:0.2) {
        didSet {
            mkLayer.setCircleLayerColor(circleLayerColor)
        }
    }
    @IBInspectable var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.1) {
        didSet {
            mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        }
    }
    
    private lazy var mkLayer: MKLayer = MKLayer(superLayer: self.contentView.layer)
    private var contentViewResized = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
//    override init(frame: CGRect) {†t
//        super.init(frame: frame)
//        setupLayer()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    func setupLayer() {
        self.selectionStyle = .None
        mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        mkLayer.setCircleLayerColor(circleLayerColor)
        mkLayer.circleGrowRatioMax = 1.2
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches as Set<UITouch>, withEvent: event)
        if let firstTouch = touches.first {
            if !contentViewResized {
                mkLayer.superLayerDidResize()
                contentViewResized = true
            }
            mkLayer.didChangeTapLocation(firstTouch.locationInView(self.contentView))
            
            mkLayer.animateScaleForCircleLayer(0.65, toScale: 1.0, timingFunction: circleAniTimingFunction, duration: CFTimeInterval(circleAniDuration))
            mkLayer.animateAlphaForBackgroundLayer(MKTimingFunction.Linear, duration: CFTimeInterval(backgroundAniDuration))
        }
    }
}
