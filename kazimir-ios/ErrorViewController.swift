//
//  ErrorViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 15/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
   
    @IBAction func tapGestureRecognized(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
