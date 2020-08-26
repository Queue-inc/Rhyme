//
//  FirebaseUtil.swift
//  pwa-wrapper
//
//  Created by subdiox on 2020/08/26.
//

import UIKit
//import Firebase
import FirebaseMessaging

class FirebaseUtil: UIResponder, UIApplicationDelegate {
    // ユーザからPush Notification通知の許可をもらう
    class func confirmNotification(delegate: UNUserNotificationCenterDelegate) {
        let app = UIApplication.shared
        UNUserNotificationCenter.current().delegate = delegate
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in
            
        })
        app.registerForRemoteNotifications()
    }
    
    class func registerTopic(topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            print("Subscribed to \(topic) topic")
        }
    }
}
