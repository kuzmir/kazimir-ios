//
//  Appearance.swift
//  kazimir-ios
//
//  Created by Krzysiek on 27/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

protocol BarTintColorChanging {
    
    func barTintColor() -> UIColor
    
}

class Appearance: NSObject {
    
    static let oldColor = Appearance.colorWithHex(0xCFBB32)
    static let newColor = Appearance.colorWithHex(0x359AAE)
    
    class func apply() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName : UIFont(name: "OpenSans", size: 22)!,
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
    }
    
    class func colorWithHex(hex: Int) -> UIColor {
        return UIColor(
            red:CGFloat((hex & 0xFF0000) >> 16) / 0xFF,
            green: CGFloat((hex & 0x00FF00) >> 8) / 0xFF,
            blue: CGFloat((hex & 0x0000FF) >> 0) / 0xFF,
            alpha: 1.0)
    }
   
}
