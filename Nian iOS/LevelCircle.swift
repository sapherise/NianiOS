
extension CALayer {
    func SAAnimation(animation: CABasicAnimation) {
        let copy = animation.copy() as! CABasicAnimation
        
        if copy.fromValue == nil {
            copy.fromValue = self.presentationLayer().valueForKeyPath(copy.keyPath)
        }
        
        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath)
    }
}

func levelCount(exp:Int) -> (Int, Float) {
    //传入获得进展的值。
    // 0的时候是1级，当到达10的时候是2级，当到达10+20的时候是3级，当到达10+20+30的时候是4级，当到达10+20+30+40的时候是5级。
    var level = Int(sqrt(Double(exp) / 5 + 0.25) + 0.5)
    var lim = level * (level - 1) * 5
    return (level, Float(exp - lim) / Float(level * 10))
}
