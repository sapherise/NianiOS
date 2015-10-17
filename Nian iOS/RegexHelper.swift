//
//  RegexHelper.swift
//  Nian iOS
//
//  Created by WebosterBob on 9/24/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import Foundation

/**
*  @author Bob Wei, 15-09-25 10:09:33
*
*  @brief  判断收到的消息的类型的一个辅助功能
*/
struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    func match(input: String) -> Bool {
        let matches = regex.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        
        return matches.count > 0
    }

}






