//
//  GIFPlayer.swift
//  Nian iOS
//
//  Created by vizee on 14/11/20.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation
import ImageIO
import QuartzCore.CoreAnimation


class GIFPlayer: UIView {
    
    private class Gif {
        var Width: Float = 0
        var Height: Float = 0
        var TotalTime: Float = 0
        var Frames = [CGImageRef]()
        var Times = [Float]()
    }
    
    private var _playing: Bool = false
    private var _repeat: Bool = true
    private var _animation: CAKeyframeAnimation? = nil
    
    var repeat: Bool {
        get {
            return _repeat
        }
        set {
            if _repeat != newValue {
                if let animation = _animation {
                    animation.repeatCount = newValue ? HUGE : 1
                }
                _repeat = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func decode(data: NSData) -> Gif {
        var source = CGImageSourceCreateWithData(data, nil)
        var count = CGImageSourceGetCount(source)
        var gif = Gif()
        if count > 0 {
            var property = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as NSDictionary
            gif.Width = property.valueForKey(kCGImagePropertyPixelWidth as String)! as! Float
            gif.Height = property.valueForKey(kCGImagePropertyPixelHeight as String)! as! Float
        }
        var totalTime: Float = 0
        for var i: Int = 0; i < count; i++ {
            gif.Frames.append(CGImageSourceCreateImageAtIndex(source, i, nil))
            var property = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as NSDictionary
            var gifProperty = property.valueForKey(kCGImagePropertyGIFDictionary as String) as! NSDictionary
            var duration = min(gifProperty.valueForKey(kCGImagePropertyGIFDelayTime as String)! as! Float, 0.01)
            gif.Times.append(duration)
            totalTime += duration
        }
        gif.TotalTime = totalTime
        return gif
    }
    
    func play(data: NSData) {
        if _playing {
            stop()
        }
        var gif = decode(data)
        var animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = CFTimeInterval(gif.TotalTime)
        animation.repeatCount = _repeat ? HUGE : 1
        animation.keyTimes = gif.Times
        animation.values = gif.Frames
        self.layer.addAnimation(animation, forKey: "V.GifAnimation")
        _animation = animation
        _playing = true
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if _playing {
            self.layer.contents = nil
            _animation = nil
            _playing = false
        }
    }
    
    func stop() {
        if !_playing {
            return
        }
        self.layer.removeAnimationForKey("V.GifAnimation")
        _animation = nil
        _playing = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
