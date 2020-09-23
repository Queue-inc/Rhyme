//
//  ViewController.swift
//  Rhyme
//
//  Created by subdiox on 08/26/2020.
//  Copyright (c) 2020 subdiox. All rights reserved.
//

import UIKit
import Rhyme

class ViewController: RhymeViewController {
    
    
    override func viewDidLoad() {
        delegate = self
        url = URL(string: "https://dev.remonade.app")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: UNUserNotificationCenterDelegate {
    
}
