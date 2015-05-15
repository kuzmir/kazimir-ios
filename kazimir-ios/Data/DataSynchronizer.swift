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
    
    func dataSynchronizerDidStartSynchronization(dataSynchronizer: DataSynchronizer)
    func dataSynchronizerDidFinishSynchronization(dataSynchronizer: DataSynchronizer, error: NSError?)
    
}

class DataSynchronizer {
    
    static let sharedInstance = DataSynchronizer()
    
    var isSynchronizationInProgress = false
    var delegate: DataSynchronizerDelegate?
    
    private init() {}
    
    func startSynchronization(completion: ((NSError?) -> Void)?) {
        if (!isSynchronizationInProgress) {
            isSynchronizationInProgress = true
            delegate?.dataSynchronizerDidStartSynchronization(self)
            let writeContext = Storage.sharedInstance.getWriteManagedObjectContext()
            writeContext.performBlock({ () -> Void in
                var error = DataDownloader.sharedInstance.downloadDataIntoContext(writeContext)
                if error == nil { writeContext.save(&error) }
                error = error ?? Storage.sharedInstance.save()
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.isSynchronizationInProgress = false
                    self.delegate?.dataSynchronizerDidFinishSynchronization(self, error: error)
                    if completion != nil { completion!(error) }
                })
            })
        }
    }
   
}
