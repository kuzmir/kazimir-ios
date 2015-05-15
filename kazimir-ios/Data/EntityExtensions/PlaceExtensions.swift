
//
//  PlaceExtensions.swift
//  kazimir-ios
//
//  Created by Krzysiek on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

enum PlaceRelation: String {
    case Photos = "photos"
}

enum PlaceProperty: String {
    case Id = "id"
    case Details = "details"
    case UpdateDate = "update_at"
}

extension Place: JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber? {
        return json[PlaceProperty.Id.rawValue] as? NSNumber
    }
    
    static func getUpdateDateFromJSON(json: JSON) -> NSDate? {
        let updateDateString = json[PlaceProperty.UpdateDate.rawValue] as? String
        if updateDateString == nil { return nil }
        return Storage.dateFormatter.dateFromString(updateDateString!)
    }
    
    func fromJSON(json: JSON) -> (Relations?, NSError?) {
        let updateDate = Photo.getUpdateDateFromJSON(json)
        if updateDate == nil { return (nil, Storage.storageError) }
        self.updateDate = updateDate!
        
        let details = json[PlaceProperty.Details.rawValue] as? JSON
        if details == nil { return (nil, Storage.storageError) }
        self.details = details!
        
        var relations = Relations()
        relations[PlaceRelation.Photos.rawValue] = json[PlaceRelation.Photos.rawValue] as? [JSON]
        return (relations, nil)
    }
    
}
