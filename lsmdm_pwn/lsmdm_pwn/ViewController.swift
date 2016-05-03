//
//  ViewController.swift
//  lsmdm_pwn
//
//  Created by Andrew Augustine on 5/1/16.
//  Copyright © 2016 Andrew Augustine. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var window1: NSView!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var Button1: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        label1.stringValue = "LSMDM_pwn"
        Button1.title = "Continue"
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

