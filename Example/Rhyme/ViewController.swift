//
//  ViewController.swift
//  Rhyme
//
//  Created by subdiox on 08/26/2020.
//  Copyright (c) 2020 subdiox. All rights reserved.
//

import UIKit
import Rhyme
//import StoreKit
import WebKit
import SwiftyStoreKit

class ViewController: RhymeViewController {
        
    override func viewDidLoad() {
        delegate = self
        url = URL(string: "http://192.168.0.131:8888")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: RhymeDelegate {
    
//    func didFetchProducts(_ products: [SKProduct]) {
//        purchaseProduct("com.queueinc.rhyme.100coin")
//    }
//
//    func didUpdateTransactions(_ queue: SKPaymentQueue, _ transactions: [SKPaymentTransaction]) {
//
//    }
//
//    func didRestorePurchases(_ queue: SKPaymentQueue) {
//
//    }
    
}
