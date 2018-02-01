//
//  Color.swift
//  Nian iOS
//
//  Created by Sa on 16/1/29.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

/* 主题编号 */
var theme = 1

extension UIColor {
    
    /* 导航栏颜色 */
    class func NavColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x25/255.0, green: 0x27/255.0, blue: 0x2a/255.0, alpha: 1)
        }
        return UIColor(red: 0x1e/255.0, green: 0x20/255.0, blue: 0x25/255.0, alpha: 1)
    }
    
    /* 底部栏颜色 */
    class func TabbarColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x25/255.0, green: 0x27/255.0, blue: 0x2a/255.0, alpha: 1)
        }
        return UIColor(red: 0x1e/255.0, green: 0x20/255.0, blue: 0x25/255.0, alpha: 1)
    }
    
    /* 高亮颜色 */
    class func HighlightColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x6c/255.0, green: 0xc5/255.0, blue: 0xee/255.0, alpha: 1)
            
        }
        return UIColor(red: 0x6c/255.0, green: 0xc5/255.0, blue: 0xee/255.0, alpha: 1)
    }
    
    class func PremiumColor() -> UIColor {
        return UIColor(red: 0xff/255.0, green: 0xe2/255.0, blue: 0x7e/255.0, alpha: 1)
    }
    
    /* 背景颜色*/
    class func BackgroundColor() -> UIColor {
        if theme == 1 {
            return UIColor.white
        }
        return UIColor(red: 0x1e/255.0, green: 0x20/255.0, blue: 0x25/255.0, alpha: 1)
    }
    
    class func GreyBackgroundColor() -> UIColor {
        return UIColor(red: 0xfa/255.0, green: 0xfa/255.0, blue: 0xfa/255.0, alpha: 1)
    }
    
    /* 浅灰 */
    class func GreyColor1() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
        }
        return UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
    }
    
    class func MainColor() -> UIColor {
        return UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1)
    }
    
    class func secAuxiliaryColor() -> UIColor {
        return UIColor(red: 0xb3/255.0, green: 0xb3/255.0, blue: 0xb3/255.0, alpha: 1)
    }
    
    class func AuxiliaryColor() -> UIColor {
        return UIColor(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0, alpha: 1)
    }
    
    class func WindowColor() -> UIColor {
        return UIColor(red: 0xf5/255.0, green: 0xf5/255.0, blue: 0xf5/255.0, alpha: 1)
    }
    
    class func Accomplish() -> UIColor {
        return UIColor(red: 0xf5/255.0, green: 0xc4/255.0, blue: 0x3b/255.0, alpha: 1)
    }
    
    /* 深灰，#333 */
    class func GreyColor2() -> UIColor {
        return UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1)
    }
    
    /* 中灰，#666 */
    class func GreyColor3() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0xb3/255.0, green: 0xb3/255.0, blue: 0xb3/255.0, alpha: 1)
        }
        return UIColor(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0, alpha: 1)
    }
    
    /* 最浅的颜色，#fafafa */
    class func GreyColor4() -> UIColor {
        return UIColor(red: 0xfa/255.0, green: 0xfa/255.0, blue: 0xfa/255.0, alpha: 1)
    }
    
    /* 主文本颜色 */
    class func ContentColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1)
        }
        return UIColor(red: 0xb3/255.0, green: 0xb3/255.0, blue: 0xb3/255.0, alpha: 1)
    }
    
    /* 分割线颜色 */
    class func LineColor() -> UIColor {
        if theme == 1 {
            return UIColor(red: 0xe6/255.0, green: 0xe6/255.0, blue: 0xe6/255.0, alpha: 1)
        }
        return UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1)
    }
    
}
