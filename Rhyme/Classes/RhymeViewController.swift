import UIKit
import WebKit
import FirebaseInstanceID
import Reachability
import StoreKit

public protocol RhymeDelegate {
    func didReceiveNotification(_ response: UNNotificationResponse)
    func didFetchProducts(_ products: [SKProduct])
    func didUpdateTransactions(_ queue: SKPaymentQueue, _ transactions: [SKPaymentTransaction])
    func didRestorePurchases(_ queue: SKPaymentQueue)
}

open class RhymeViewController: UIViewController {
    
    open var url: URL?
    open var delegate: RhymeDelegate?
    open var webView: WKWebView?
    var firebaseToken: String = ""
    var launchScreen: UIView?
    let reachability = try! Reachability()
    var alert: UIAlertController?
    var connection: Reachability.Connection = .unavailable
    
    var productsRequest = SKProductsRequest()
    var products = [SKProduct]()
    
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
            userController.add(self, name: "FCM")
            webConfig.userContentController = userController
            webConfig.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
            webConfig.websiteDataStore = WKWebsiteDataStore.default()
            webConfig.preferences.javaScriptEnabled = true
            webView = WKWebView(frame: self.view.frame, configuration: webConfig)
            let source: String =
                """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);
                """
            let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView?.configuration.userContentController.addUserScript(script)
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
                    if let next = key.host, let original = self.url?.host {
                        if next == original {
                            DataUtil.url = key
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    public func fetchProducts(_ identifiers: Set<String>)  {
        productsRequest = SKProductsRequest(productIdentifiers: identifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    public func purchaseProduct(_ productId: String) {
        if let product = products.filter({$0.productIdentifier == productId}).first {
            if SKPaymentQueue.canMakePayments() {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
            } else { print("Purchases are disabled in your device!") }
        }
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension RhymeViewController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "FCM" {
            if let body = message.body as? String {
                if body == "START_RECEIVING" {
                    FirebaseUtil.confirmNotification(delegate: self)
                    InstanceID.instanceID().instanceID { (result, error) in
                        if let error = error {
                            print("Error fetching remote instance ID: \(error)")
                        } else if let result = result {
                            print("Remote instance ID token: \(result.token)")
                            let firebaseToken = "Remote InstanceID token: \(result.token)"
                            self.firebaseToken = firebaseToken
                        }
                    }
                } else if body.contains("TOPIC:") {
                    let bodies = body.components(separatedBy: ":")
                    FirebaseUtil.registerTopic(topic: bodies[1])
                }
            }
        }
    }
    
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

extension RhymeViewController: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        delegate?.didReceiveNotification(response)
    }
    
}

extension RhymeViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        delegate?.didFetchProducts(response.products)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        delegate?.didUpdateTransactions(queue, transactions)
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchase succeeded.")
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Payment has failed.")
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchase has been successfully restored!")
                break
            default:
                break
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.didRestorePurchases(queue)
    }
    
}

extension RhymeViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
