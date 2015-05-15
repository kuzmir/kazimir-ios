//
//  Street.swift
//  kazimir-ios
//
//  Created by Krzysiek on 11/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import Foundation
import CoreData

class Street: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var updateDate: NSDate
    @NSManaged var path: NSDictionary
    @NSManaged var places: NSOrderedSet

}
