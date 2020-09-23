//
//  InfoPlistUtil.swift
//  Rhyme
//
//  Created by subdiox on 2020/09/16.
//

import Foundation

final class InfoPlistUtil {
    private init() {}
    
    static func objectForKey<T>(_ key: String) -> T? {
        Bundle.main.object(forInfoDictionaryKey: key) as? T
    }
    
    static func stringForKey(_ key: String) -> String? {
        InfoPlistUtil.objectForKey(key)
    }
    
    static var launchStoryboardName: String? {
        InfoPlistUtil.stringForKey("UILaunchStoryboardName")
    }
}
