//
//  Coin.swift
//  Nian iOS
//
//  Created by Sa on 16/1/12.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class Coin: SAViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let btn = UIView(frame: CGRectMake(globalWidth/2 - 100, 200, 200, 50))
        btn.backgroundColor = UIColor.HightlightColor()
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onClick"))
        btn.userInteractionEnabled = true
        self.view.addSubview(btn)
        
        //        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        /* 监听购买结果 */
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func pay() {
        let set = NSSet(array: ["so.nian.c12"])
        let request = SKProductsRequest(productIdentifiers: set as! Set<String>)
        request.delegate = self
        request.start()
    }
    
    func onClick() {
        if SKPaymentQueue.canMakePayments() {
            pay()
        } else {
            self.showTipText("要先允许念付费购买...")
        }
    }
    
    /* 获取查询产品信息的回调 */
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products = response.products
        if products.count == 0 {
            print("无法获取产品信息，购买失败")
            return
        }
        let payment = SKPayment(product: products[0])
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: SKPaymentTransaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                print("交易完成")
                complete(transaction)
                break
            case SKPaymentTransactionState.Failed:
                print("交易失败")
                failed(transaction)
                break
            case SKPaymentTransactionState.Restored:
                print("已购买过该产品")
                restore(transaction)
                break
            case SKPaymentTransactionState.Purchasing:
                print("商品添加进列表")
                break
            default:
                break
            }
        }
    }
    
    /* 成功 */
    func complete(transaction: SKPaymentTransaction) {
        print("向服务器验证")
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
        let receipt = NSData(contentsOfURL: receiptURL!)
        let data = receipt!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        Api.postIapVerify(transaction.transactionIdentifier!, data: data) { json in
            print(json)
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    /* 失败 */
    func failed(transaction: SKPaymentTransaction) {
        if transaction.error?.code != SKErrorPaymentCancelled {
            print("购买失败")
        } else {
            print("用户取消")
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    /* 恢复 */
    func restore(transaction: SKPaymentTransaction) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
}