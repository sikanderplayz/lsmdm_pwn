//
//  SecondViewController.swift
//  lsmdm_pwn
//
//  Created by Andrew Augustine on 5/1/16.
//  Copyright © 2016 Andrew Augustine. All rights reserved.
//

import Cocoa

class SecondViewController: NSViewController {

    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var cancelButton: NSCancelButton!
    
    @IBAction func scriptInit(sender: NSButton) {
        self.presentViewController(ThirdViewController.swift, animated: true, completion: nil)
        self.dismissController(self)
    }
    
    @IBAction func dismiss(sender: NSCancelButton) {
        self.dismissController(self)
    }
    
}
