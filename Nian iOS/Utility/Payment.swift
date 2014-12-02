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
    
    enum PayState: Int {
        case Purchased
        case Cancelled
        case VerifyFailed
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
        println(transaction.transactionIdentifier)
        if let receiptData = NSData(contentsOfURL: url!) {
            Api.postIapReceipt(receiptData) {
                json in
                if json == nil {
                    println("nil")
                    self._callback(transaction.payment.productIdentifier, .VerifyFailed)
                } else {
                    println("bad")
                    self._callback(transaction.payment.productIdentifier, (json!["success"] as String).toInt()! == 1 ? .Purchased : .VerifyFailed)
                }
            }
        }
    }
    
    private func onPaymentFailed(transaction: SKPaymentTransaction) {
        _callback(transaction.payment.productIdentifier, transaction.error.code == SKErrorPaymentCancelled ? .Cancelled : .Failed)
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        if response.products.count == 0 {
            return
        }
        var queue = SKPaymentQueue.defaultQueue()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        for product: SKProduct in response.products as [SKProduct] {
            queue.addPayment(SKPayment(product: product))
        }
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
    }
    
    func requestDidFinish(request: SKRequest!) {
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction: SKPaymentTransaction in transactions as [SKPaymentTransaction] {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                onPaymentPurchased(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            case SKPaymentTransactionState.Failed:
                println(transaction.error)
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