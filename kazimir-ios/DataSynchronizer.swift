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
    
    func startSynchronization(completion: ((NSError?) -> Void)?) {
        if (!isSynchronizationInProgress) {
            isSynchronizationInProgress = true
            let writeContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            writeContext.parentContext = Storage.sharedInstance.managedObjectContext
            writeContext.performBlock({ () -> Void in
                var error = self.synchronizeInContext(writeContext)
                if error == nil {
                    writeContext.save(&error)
                }
//                error = error ?? Storage.sharedInstance.save()
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.isSynchronizationInProgress = false
                    if completion != nil {
                        completion!(error)
                    }
                })
            })
        }
    }
    
    private func synchronizeInContext(context: NSManagedObjectContext) -> NSError? {
        let (json, clientError) = Client.sharedInstance.downloadData()
        if clientError != nil { return clientError }
        let (objects, storageError) = Storage.sharedInstance.storeDataFromJSON(json!, context: context)
        if storageError != nil { return storageError }
        return nil
    }
   
}
