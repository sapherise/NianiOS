//
//  ActivitiesSummaryModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/12/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit


class ActivitiesSummaryModel: NSObject {
    
    
    override init() {
        super.init()
        
    }
   
    /**
     <#Description#>
     */
    class func getMyAcitiviesSummary(callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(
            "user/\(CurrentUser.sharedCurrentUser.uid!)/summary?uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
            callback: callback)
    }
    
    /**
     <#Description#>
     */
    class func getMyLikeNote(page page: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(
            "user/\(CurrentUser.sharedCurrentUser.uid!)/like/dreams/?page=\(page)&&uid=\(CurrentUser.sharedCurrentUser.uid!)&&shell=\(CurrentUser.sharedCurrentUser.shell!)",
            callback: callback)
    }
    
    /**
     <#Description#>
     */
    class func getMyActitvity(url url: String, callback: NetworkClosure) {
        NianNetworkClient.sharedNianNetworkClient.get(url, callback: callback)
    }
    
    
    
    
    
    
}
