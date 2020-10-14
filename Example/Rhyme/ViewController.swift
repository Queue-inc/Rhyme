//
//  ViewController.swift
//  Rhyme
//
//  Created by subdiox on 08/26/2020.
//  Copyright (c) 2020 subdiox. All rights reserved.
//

import UIKit
import Rhyme
import StoreKit

class ViewController: RhymeViewController {
    
    override func viewDidLoad() {
        delegate = self
        url = URL(string: "https://v2-dev.remonade.app")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        fetchProducts(["com.queueinc.remonade.100coin"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: RhymeDelegate {
    
    func didReceiveNotification(_ response: UNNotificationResponse) {
        
    }
    
    func didFetchProducts(_ products: [SKProduct]) {
//        purchaseProduct("com.queueinc.remonade.100coin")
    }
    
    func didUpdateTransactions(_ queue: SKPaymentQueue, _ transactions: [SKPaymentTransaction]) {
        
    }
    
    func didRestorePurchases(_ queue: SKPaymentQueue) {
        
    }
    
}
