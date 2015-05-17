//
//  PlaceExtensions.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

enum PlaceRelation: String {
    case Photos = "photos"
}

enum PlaceProperty: String {
    case Id = "id"
    case Details = "details"
    case UpdateDate = "updated_at"
}

extension Place {
    
    static func getPhotosJSON(#json: JSON) -> RelationInfo {
        let photos = json[PlaceRelation.Photos.rawValue] as? [JSON]
        if photos == nil { return (nil, Storage.storageError) }
        return (photos!, nil)
    }
    
}

extension Place: JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber? {
        return json[PlaceProperty.Id.rawValue] as? NSNumber
    }
    
    func fromJSON(json: JSON) -> ConversionResult {
        let updateDateString = json[PlaceProperty.UpdateDate.rawValue] as? String
        if updateDateString == nil { return (nil, Storage.storageError) }
        let updateDate = Storage.dateFormatter.dateFromString(updateDateString!)
        if updateDate == nil { return (nil, Storage.storageError) }
        
        if self.updateDate.compare(updateDate!) == .OrderedAscending {
            self.updateDate = updateDate!
            
            let details = json[PlaceProperty.Details.rawValue] as? JSON
            if details == nil { return (nil, Storage.storageError) }
            self.details = details!
            return (true, nil)
        }
        return (false, nil)
    }
    
}
