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
    
    enum PayState {
        case Purchased
        case Failed
    }
    
    private var _callback: (String, PayState) -> Void
    
    init(callback: (String, PayState) -> Void) {
        _callback = callback
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    private func onPaymentPurchased(transaction: SKPaymentTransaction) {
        var url = NSBundle.mainBundle().appStoreReceiptURL
        var data = NSData(contentsOfURL: url!)!
        println(data)
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
        
        println(json)
        _callback(transaction.payment.productIdentifier, .Purchased)
        println("pay success")
    }
    
    private func onPaymentFailed(transaction: SKPaymentTransaction) {
        println(transaction.error)
        _callback(transaction.payment.productIdentifier, .Failed)
        println("pay fail")
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        if response.products.count == 0 {
            return
        }
        println("ready to pay")
        var queue = SKPaymentQueue.defaultQueue()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        for product: SKProduct in response.products as [SKProduct] {
            println(product)
            queue.addPayment(SKPayment(product: product))
        }
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("request(request: SKRequest!, didFailWithError error: NSError!)")
    }
    
    func requestDidFinish(request: SKRequest!) {
        println("requestDidFinish(request: SKRequest!)")
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("update transaction")
        for transaction: SKPaymentTransaction in transactions as [SKPaymentTransaction] {
            println("\(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                onPaymentPurchased(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            case SKPaymentTransactionState.Failed:
                onPaymentFailed(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            default:
                break
            }
        }
    }

    func pay(productId: String) -> Bool {
        var allowed = SKPaymentQueue.canMakePayments()
        if allowed {
            var request = SKProductsRequest(productIdentifiers: NSSet(object: productId))
            request.delegate = self
            request.start()
        }
        return allowed
    }
}