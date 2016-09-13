//
//  AddStepModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class AddStepModel: NSObject {

    /**
     <#Description#>
     
     - parameter content:  <#content description#>
     - parameter stepType: <#stepType description#>
     - parameter images:   <#images description#>
     - parameter callback: <#callback description#>
     */
    
    class func postAddStep(content: String, stepType: Int, images: NSArray, dreamId: String, callback: NetworkClosure) {
        let _uid = CurrentUser.sharedCurrentUser.uid!
        let _shell = CurrentUser.sharedCurrentUser.shell!
        
        
        let jsonString = try! JSONSerialization.data(withJSONObject: images, options: JSONSerialization.WritingOptions.prettyPrinted)
        let imagesString = NSString(data: jsonString, encoding: String.Encoding.utf8.rawValue)!
        
        NianNetworkClient.sharedNianNetworkClient.post(
            "multidream/\(dreamId)/update?uid=\(_uid)&shell=\(_shell)",
            content: ["content": content, "type": "\(stepType)", "images": "\(imagesString)"],
            callback: callback)
    }
    
    class func postEditStep(content: String, stepType: Int, images: NSArray, sid: String, callback: NetworkClosure) {
        let _uid = CurrentUser.sharedCurrentUser.uid!
        let _shell = CurrentUser.sharedCurrentUser.shell!
    
        let jsonString = try! JSONSerialization.data(withJSONObject: images, options: JSONSerialization.WritingOptions.prettyPrinted)
        let imagesString = NSString(data: jsonString, encoding: String.Encoding.utf8.rawValue)!
    
        NianNetworkClient.sharedNianNetworkClient.post(
            "v2/step/\(sid)/edit?uid=\(_uid)&shell=\(_shell)",
            content: ["content": content, "type": "\(stepType)", "images": "\(imagesString)"],
            callback: callback)
    }
    
    
    
    
    
    
    
}
