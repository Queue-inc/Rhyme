# Rhyme

[![CI Status](https://img.shields.io/travis/subdiox/Rhyme.svg?style=flat)](https://travis-ci.org/subdiox/Rhyme)
[![Version](https://img.shields.io/cocoapods/v/Rhyme.svg?style=flat)](https://cocoapods.org/pods/Rhyme)
[![License](https://img.shields.io/cocoapods/l/Rhyme.svg?style=flat)](https://cocoapods.org/pods/Rhyme)
[![Platform](https://img.shields.io/cocoapods/p/Rhyme.svg?style=flat)](https://cocoapods.org/pods/Rhyme)

Rhyme is a wrapper library for PWA/web applications, implementing web cache, push notifications and in-app purchase.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Firebase Environment
- A website using rhyme-js

## Installation

Rhyme is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Rhyme'
```

## Usage

0. Read [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging/ios/client) and add `GoogleService-Info.plist` to Xcode project.

1. Define a view controller which extends `RhymeViewController`, and implement delegate and url as following:

```swift:ViewController.swift
class ViewController: RhymeViewController {
    override func viewDidLoad() {
        delegate = self
        url = URL(string: "https://www.example.com")
        super.viewDidLoad()
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
}
```

2. Add codes to configure Firebase in `AppDelegate`.

```swift:AppDelegate.swift
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        return true
    }
}
```

## Author

Queue-inc, info@queue-inc.com

## License

Rhyme is available under the MIT license. See the LICENSE file for more info.
