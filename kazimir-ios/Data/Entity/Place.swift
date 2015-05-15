//
//  Place.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 11/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import Foundation
import CoreData

class Place: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var updateDate: NSDate
    @NSManaged var present: NSNumber
    @NSManaged var details: NSDictionary
    @NSManaged var photos: NSOrderedSet
    @NSManaged var street: Street

}
