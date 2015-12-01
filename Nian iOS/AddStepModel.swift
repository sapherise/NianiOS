//
//  AddStepModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


enum StepType: Int {
    case attendance = 1
    case voiceMessage
    case multiPicWithText
    case multiPicWithoutText
    case singlePicWithText
    case singlePicWithoutText
    case text
}



class AddStepModel: NSObject {

    /**
     <#Description#>
     
     - parameter content:  <#content description#>
     - parameter stepType: <#stepType description#>
     - parameter images:   <#images description#>
     - parameter callback: <#callback description#>
     */
    class func postAddStep(content content: String, stepType: StepType, images: NSArray, dreamId: String, callback: NetworkClosure) {
        let _uid = CurrentUser.sharedCurrentUser.uid!
        let _shell = CurrentUser.sharedCurrentUser.shell!
        
        NianNetworkClient.sharedNianNetworkClient.post(
            "dream/\(dreamId)/step/create?uid=\(_uid)&&shell=\(_shell)",
            content: ["content": content, "type": "\(stepType.rawValue)", "images": "\(images)"],
            callback: callback)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
