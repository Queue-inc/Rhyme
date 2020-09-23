//
//  DataUtil.swift
//  Rhyme
//
//  Created by subdiox on 2020/09/16.
//

import Foundation

struct UDKey {
    static let url = "url"
}

class DataUtil {
    private static let ud = UserDefaults.standard
    
    static var url: URL? {
        get {
            return ud.url(forKey: UDKey.url)
        }
        set {
            ud.set(newValue, forKey: UDKey.url)
            ud.synchronize()
        }
    }
}
