//
//  AppDelegate.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appearance.apply()
        GMSServices.provideAPIKey("AIzaSyCfiPBS-0-8EqHlX72TiKU0pEwi24-dLDo")
        Storage.sharedInstance.initializeStorage()
        DataSynchronizer.sharedInstance.startSynchronization { (error) -> Void in
        }
        return true
    }
    
}

