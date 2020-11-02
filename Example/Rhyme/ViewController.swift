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
import WebKit

class ViewController: RhymeViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        delegate = self
        url = URL(string: "https://v2.remonade.app")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        fetchProducts(["com.queueinc.remonade.100coin"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let script = "localStorage.getItem(\"REMONADE_CURRENT_USER_ID\")"
        webView.evaluateJavaScript(script) { userId, error in
            if let userId = userId as? String {
                if let interests = self.appDelegate.pushNotifications.getDeviceInterests() {
                    for interest in interests {
                        if interest != userId || interest != "debug-\(userId)" {
                            try? self.appDelegate.pushNotifications.removeDeviceInterest(interest: interest)
                        }
                    }
                }
                try? self.appDelegate.pushNotifications.addDeviceInterest(interest: userId)
                try? self.appDelegate.pushNotifications.addDeviceInterest(interest: "debug-\(userId)")
            }
        }
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
