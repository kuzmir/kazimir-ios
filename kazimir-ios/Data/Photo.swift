//
//  Photo.swift
//  kazimir-ios
//
//  Created by Krzysiek on 11/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var dataThumb: NSData
    @NSManaged var dataTiny: NSData
    @NSManaged var dataSmall: NSData
    @NSManaged var dataMedium: NSData
    @NSManaged var dataLarge: NSData
    @NSManaged var details: NSDictionary
    @NSManaged var place: Place

}
