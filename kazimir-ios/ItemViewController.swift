//
//  ItemViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

enum ItemContext: Int {
    case Old
    case New
}

class ItemViewController: UITableViewController {
    
    var context: ItemContext!
    
    var popDirection: SlideTransitionDirection {
        return SlideTransitionDirection(rawValue: (context.rawValue + 1) % 2)!
    }
    
    var pushDirection: SlideTransitionDirection {
        return SlideTransitionDirection(rawValue: context.rawValue)!
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        switch (context!) {
        case .Old:
            self.navigationItem.rightBarButtonItem = nil
        case .New:
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
}

extension ItemViewController: BarTintColorChanging {
    
    func barTintColor() -> UIColor {
        return context == .Old ? Appearance.oldColor : Appearance.newColor
    }
    
}
