import UIKit
import WebKit
import Reachability
import SwiftyStoreKit
//import StoreKit

public protocol RhymeDelegate {
//    func didFetchProducts(_ products: [SKProduct])
//    func didUpdateTransactions(_ queue: SKPaymentQueue, _ transactions: [SKPaymentTransaction])
//    func didRestorePurchases(_ queue: SKPaymentQueue)
}

open class RhymeViewController: UIViewController {
    
    open var url: URL?
    open var delegate: RhymeDelegate?
    open var webView: WKWebView?
    var launchScreen: UIView?
    let reachability = try! Reachability()
    var alert: UIAlertController?
    var connection: Reachability.Connection = .unavailable
    
//    var productsRequest = SKProductsRequest()
//    var products = [SKProduct]()
    
    open override func viewDidLoad() {
        reachability.whenReachable = { reachability in
            if self.connection == .unavailable {
                print("Reachable")
                if let alert = self.alert {
                    alert.dismiss(animated: true)
                    self.alert = nil
                }
                if let lastUrl = DataUtil.url {
                    self.webView?.load(URLRequest(url: lastUrl))
                } else if let url = self.url {
                    self.webView?.load(URLRequest(url: url))
                } else {
                    self.webView?.reload()
                }
                self.connection = reachability.connection
            }
            
        }
        reachability.whenUnreachable = { reachability in
            print("Not reachable")
            self.webView?.reload()
            self.connection = reachability.connection
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        if let url = url {
            let webConfig: WKWebViewConfiguration = WKWebViewConfiguration()
            let userController: WKUserContentController = WKUserContentController()
            userController.add(self, name: "purchase")
            userController.add(self, name: "restore")
            webConfig.userContentController = userController
            webConfig.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
            webConfig.websiteDataStore = WKWebsiteDataStore.default()
            webConfig.preferences.javaScriptEnabled = true
            webView = WKWebView(frame: self.view.frame, configuration: webConfig)
            webView?.navigationDelegate = self
            webView?.scrollView.delegate = self
            if let webView = webView {
                if let lastUrl = DataUtil.url {
                    print("lastUrl: \(lastUrl)")
                    webView.load(URLRequest(url: lastUrl))
                } else {
                    print("url: \(url)")
                    webView.load(URLRequest(url: url))
                }
                webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
                webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
                self.view.addSubview(webView)
            }
        }
        launchScreen = ViewUtil.launchScreen
        if let launchScreen = launchScreen {
            view.addSubview(launchScreen)
            NSLayoutConstraint.activate([
                launchScreen.topAnchor.constraint(equalTo: view.topAnchor),
                launchScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                launchScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                launchScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            view.bringSubview(toFront: launchScreen)
        }
        
        SwiftyStoreKit.retrieveProductsInfo(["com.queueinc.rhyme.100coin", "com.queueinc.rhyme.divine"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            assertionFailure()
            return
        }
        
        if let webView = webView {
            switch keyPath {
            case #keyPath(WKWebView.isLoading):
                if !webView.isLoading {
                    launchScreen?.removeFromSuperview()
                }
            case #keyPath(WKWebView.url):
                if let key = change?[NSKeyValueChangeKey.newKey] as? URL {
                    DataUtil.url = key
                }
            default:
                break
            }
        }
    }
    
    
//    public func fetchProducts(_ identifiers: Set<String>)  {
//        productsRequest = SKProductsRequest(productIdentifiers: identifiers)
//        productsRequest.delegate = self
//        productsRequest.start()
//    }
//
//    public func purchaseProduct(_ productId: String) {
//        if let product = products.filter({$0.productIdentifier == productId}).first {
//            if SKPaymentQueue.canMakePayments() {
//                let payment = SKPayment(product: product)
//                SKPaymentQueue.default().add(self)
//                SKPaymentQueue.default().add(payment)
//            } else { print("Purchases are disabled in your device!") }
//        }
//    }
//
//    public func restorePurchases() {
//        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }
    
}

extension RhymeViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let code = (error as NSError).code
        print(code)
        if code == -1001 || code == -1003 || code == -1009 || code == -1100 {
            alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            if let alert = alert {
                present(alert, animated: true)
            }
        }
    }
    
}

extension RhymeViewController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "purchase" {
            if let body = message.body as? String {
                print("purchase: \(body)")
                let productId = String(body.split(separator: ",")[0])
                if let quantity = Int(body.split(separator: ",")[1]) {
                    SwiftyStoreKit.purchaseProduct(productId, quantity: quantity, atomically: true) { result in
                        switch result {
                        case .success(let purchase):
                            print("Purchase Success: \(purchase.productId)")
                            self.webView?.evaluateJavaScript("window.paymentComplete(true)", completionHandler: nil)
                        case .error(let error):
                            self.webView?.evaluateJavaScript("window.paymentComplete(false)", completionHandler: nil)
                            switch error.code {
                            case .unknown: print("Unknown error. Please contact support")
                            case .clientInvalid: print("Not allowed to make the payment")
                            case .paymentCancelled: break
                            case .paymentInvalid: print("The purchase identifier was invalid")
                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            default: print((error as NSError).localizedDescription)
                            }
                        }
                    }
                }
            }
        } else if message.name == "restore" {
            if let body = message.body as? String {
                print("restore: \(body)")
                SwiftyStoreKit.restorePurchases(atomically: true) { results in
                    if results.restoreFailedPurchases.count > 0 {
                        print("Restore Failed: \(results.restoreFailedPurchases)")
                        self.webView?.evaluateJavaScript("window.restoreComplete(false)", completionHandler: nil)
                    }
                    else if results.restoredPurchases.count > 0 {
                        print("Restore Success: \(results.restoredPurchases)")
                        self.webView?.evaluateJavaScript("window.restoreComplete(true)", completionHandler: nil)
                    }
                    else {
                        print("Nothing to Restore")
                        self.webView?.evaluateJavaScript("window.restoreComplete(false)", completionHandler: nil)
                    }
                }
            }
        }
    }
    
}

//extension RhymeViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
//
//    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        products = response.products
//        delegate?.didFetchProducts(response.products)
//    }
//
//    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        delegate?.didUpdateTransactions(queue, transactions)
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased:
//                SKPaymentQueue.default().finishTransaction(transaction)
//                print("Purchase succeeded.")
//                break
//            case .failed:
//                SKPaymentQueue.default().finishTransaction(transaction)
//                print("Payment has failed.")
//                break
//            case .restored:
//                SKPaymentQueue.default().finishTransaction(transaction)
//                print("Purchase has been successfully restored!")
//                break
//            default:
//                break
//            }
//        }
//    }
//
//    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
//        return true
//    }
//
//    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        delegate?.didRestorePurchases(queue)
//    }
//
//}

extension RhymeViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
