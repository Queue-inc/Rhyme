# Rhyme

[![CI Status](https://img.shields.io/travis/subdiox/Rhyme.svg?style=flat)](https://travis-ci.org/subdiox/Rhyme)
[![Version](https://img.shields.io/cocoapods/v/Rhyme.svg?style=flat)](https://cocoapods.org/pods/Rhyme)
[![License](https://img.shields.io/cocoapods/l/Rhyme.svg?style=flat)](https://cocoapods.org/pods/Rhyme)
[![Platform](https://img.shields.io/cocoapods/p/Rhyme.svg?style=flat)](https://cocoapods.org/pods/Rhyme)

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

Define a view controller which extends `RhymeViewController`, and implement delegate and url as following:

```swift
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

## Author

subdiox, subdiox@gmail.com

## License

Rhyme is available under the MIT license. See the LICENSE file for more info.
