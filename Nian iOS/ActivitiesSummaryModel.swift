//
//  ActivitiesSummaryModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/12/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

enum Result <T, O, E> {
    case success(T, O)
    case failure(T, E)
}

class ActivitiesSummaryModel: NSObject {
    
    let manager = AFHTTPSessionManager()
    
    override init() {
        super.init()
        
        manager.responseSerializer = AFJSONResponseSerializer()
    }
    
    func getMyAcitiviesSummary<T, O, E>(callback: (task: T, responseObject: O, error: E)) {

        
        
        
    }
    
    
    
}
