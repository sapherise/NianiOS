//
//  Payment.swift
//  Nian iOS
//
//  Created by vizee on 14/11/26.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation
import StoreKit

class Payment: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
    }
    
    class func pay(productId: String, callback: (Int) -> Void) {
        
    }
}