//
//  RegexHelper.swift
//  Nian iOS
//
//  Created by WebosterBob on 9/24/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import Foundation


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






