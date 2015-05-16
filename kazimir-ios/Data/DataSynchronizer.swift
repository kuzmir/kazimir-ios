//
//  DataSynchronizer.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

protocol DataSynchronizerDelegate {
    
    func dataSynchronizerDidFinishSynchronization(dataSynchronizer: DataSynchronizer, error: NSError?)
    
}

class DataSynchronizer {
    
    static let sharedInstance = DataSynchronizer()
    
    var isSynchronizationInProgress = false
    var delegate: DataSynchronizerDelegate?
    
    private init() {}
    
    func startSynchronization(#locally: Bool) {
        if (!isSynchronizationInProgress) {
            isSynchronizationInProgress = true
            let writeContext = Storage.sharedInstance.getWriteManagedObjectContext()
            writeContext.performBlock({ () -> Void in
                var error: NSError? = nil
                error = DataLoader.sharedInstance.loadDataIntoContext(writeContext, locally: locally, progress: { () -> Bool in
                    writeContext.save(&error)
                    error = error ?? Storage.sharedInstance.save()
                    return error == nil
                })
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.isSynchronizationInProgress = false
                    self.delegate?.dataSynchronizerDidFinishSynchronization(self, error: error)
                })
            })
        }
    }
   
}
