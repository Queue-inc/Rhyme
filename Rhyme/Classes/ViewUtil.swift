//
//  ViewUtil.swift
//  Rhyme
//
//  Created by subdiox on 2020/09/16.
//

import Foundation

final class ViewUtil {
    private init() {}
    
    static var launchScreen: UIView? {
        guard let name = InfoPlistUtil.launchStoryboardName else {
            return nil
        }
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        let retainedView = viewController?.view // retain Launch Screen
        viewController?.view = nil // Cut reference from viewController to Launch Screen
        return retainedView
    }
}
