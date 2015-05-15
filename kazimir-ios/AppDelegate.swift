//
//  AppDelegate.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appearance.apply()
        GMSServices.provideAPIKey("AIzaSyCfiPBS-0-8EqHlX72TiKU0pEwi24-dLDo")
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        DataSynchronizer.sharedInstance.startSynchronization(locally: true)
    }
    
}
