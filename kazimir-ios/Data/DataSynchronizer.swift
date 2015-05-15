//
//  DataSynchronizer.swift
//  kazimir-ios
//
//  Created by Krzysiek on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

class DataSynchronizer {
    
    static let sharedInstance = DataSynchronizer()
    
    var isSynchronizationInProgress = false
    
    private init() {}
    
    func startSynchronization(completion: ((NSError?) -> Void)?) {
        if (!isSynchronizationInProgress) {
            isSynchronizationInProgress = true
            let writeContext = Storage.sharedInstance.getWriteManagedObjectContext()
            writeContext.performBlock({ () -> Void in
                var error = DataDownloader.sharedInstance.downloadDataIntoContext(writeContext)
                if error == nil { writeContext.save(&error) }
                error = error ?? Storage.sharedInstance.save()
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.isSynchronizationInProgress = false
                    if completion != nil { completion!(error) }
                })
            })
        }
    }
   
}
