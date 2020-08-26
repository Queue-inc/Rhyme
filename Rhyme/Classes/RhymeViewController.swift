import UIKit
import WebKit
import FirebaseInstanceID

open class RhymeViewController: UIViewController {
    
    open var url: URL?
    open var delegate: UNUserNotificationCenterDelegate?
    var firebaseToken: String = ""
    
    open override func viewDidLoad() {
        if let url = url {
            let webConfig: WKWebViewConfiguration = WKWebViewConfiguration()
            let userController: WKUserContentController = WKUserContentController()
            userController.add(self, name: "FCM")
            webConfig.userContentController = userController
            let wkWebView = WKWebView(frame: self.view.frame, configuration: webConfig)
            wkWebView.load(URLRequest(url: url))
            self.view.addSubview(wkWebView)
        }
    }
    
}

extension RhymeViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let delegate = delegate, message.name == "FCM" {
            if let body = message.body as? String {
                if body == "START_RECEIVING" {
                    FirebaseUtil.confirmNotification(delegate: delegate)
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
