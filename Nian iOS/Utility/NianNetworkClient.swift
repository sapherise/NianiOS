//
//  NianNetworkClient.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/21/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

/// basic url string
let baseURLString = "http://api.nian.so/"

/// 大概相当于 typedef
typealias NetworkClosure = (_ task: URLSessionDataTask, _ responseObject: AnyObject?, _ error: NSError?) -> Void

/*=========================================================================================================================================*/

/*
为什么重新写一个 network client，since 我们已经有好几个轮子了？
-- 因为之前的都没有加入错误处理，如果在原来的基础上修改，涉及的东西实在太多了
*/

/*=========================================================================================================================================*/

///
class NianNetworkClient: AFHTTPSessionManager {
    /// nian network client is singleton
    static let sharedNianNetworkClient = NianNetworkClient()
    
    /**
    单例的 init() 方法都是 private 的， -- 保证线程安全
    */
    fileprivate init() {
        super.init(baseURL: nil, sessionConfiguration: nil)
        
//        self.requestSerializer = AFJSONRequestSerializer()
//        /* 设置解析 server 返回的 json */
//        self.responseSerializer = AFJSONResponseSerializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    :param: string    URL 在 baseURL 的基础上的剩余部分
    :param: callback  -
    
    :returns:
    */
    func get(_ string: String, callback: @escaping NetworkClosure) -> URLSessionDataTask {
        return  self.get(baseURLString + string,
                    parameters: nil,
                    success: { (task, id) in
                        callback(task, id, nil)
                    },
                    failure: { (task, error) in
                        callback(task: task, responseObject: nil, error: error)
                })
    }
    
    /**
    :param: string    string URL 在 baseURL 的基础上的剩余部分
    :param: content   提交的内容
    :param: callback  -
    
    :returns:
    */
    func post(_ string: String, content: AnyObject, callback: @escaping NetworkClosure) -> URLSessionDataTask {
        return  self.post(baseURLString + string,
                    parameters: content,
                    success: { (task, id) in
                        callback(task, id, nil)
                    },
                    failure: { (task, error) in
                        callback(task: task, responseObject: nil, error: error)
                })
    }
    
    /**
     <#Description#>
     
     :param: string   <#string description#>
     :param: content  <#content description#>
     :param: callback <#callback description#>
     
     :returns: <#return value description#>
     */
    func put(_ string: String, content: AnyObject, callback: @escaping NetworkClosure) -> URLSessionDataTask {
        return self.put(baseURLString + string,
                    parameters: content,
                    success: { (task, id) -> Void in
                        callback(task, id, nil)
                    }, failure: { (task, error) -> Void in
                        callback(task: task, responseObject: nil, error: error)
                })
        
        
        
        
    }
    
    
    
}
