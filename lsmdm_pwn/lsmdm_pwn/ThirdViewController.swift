//
//  ThirdViewController.swift
//  lsmdm_pwn
//
//  Created by Andrew Augustine on 5/1/16.
//  Copyright © 2016 Andrew Augustine. All rights reserved.
//

import Cocoa

class ThirdViewController: NSViewController {
    
    @IBOutlet weak var actionLabel: NSTextField!
    @IBOutlet weak var cancelButton: NSCancelButton!

    @IBAction func dismiss(sender: NSCancelButton) {
        self.dismissController(self)
    }
    
}
