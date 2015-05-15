//
//  StreetExtensions.swift
//  kazimir-ios
//
//  Created by Krzysiek on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

enum StreetRelation: String {
    case PresentPlaces = "present"
    case PastPlaces = "past"
}

enum StreetProperty: String {
    case Id = "id"
    case Name = "name"
    case Path = "path"
    case UpdateDate = "updated_at"
    case Places = "places"
}

extension Street: JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber? {
        return json[StreetProperty.Id.rawValue] as? NSNumber
    }
    
    static func getUpdateDateFromJSON(json: JSON) -> NSDate? {
        let updateDateString = json[StreetProperty.UpdateDate.rawValue] as? String
        if updateDateString == nil { return nil }
        return Storage.dateFormatter.dateFromString(updateDateString!)
    }
    
    func fromJSON(json: JSON) -> (Relations?, NSError?) {
        let updateDate = Street.getUpdateDateFromJSON(json)
        if updateDate == nil { return (nil, Storage.storageError) }
        self.updateDate = updateDate!
        
        let name = json[StreetProperty.Name.rawValue] as? String
        if name == nil { return (nil, Storage.storageError) }
        self.name = name!
        
        let path = json[StreetProperty.Path.rawValue] as? JSON
        if path == nil { return (nil, Storage.storageError) }
        self.path = path!
        
        var relations = Relations()
        let places = json[StreetProperty.Places.rawValue] as? JSON
        if places == nil { return (nil, Storage.storageError) }
        relations[StreetRelation.PresentPlaces.rawValue] = places![StreetRelation.PresentPlaces.rawValue] as? [JSON]
        relations[StreetRelation.PastPlaces.rawValue] = places![StreetRelation.PastPlaces.rawValue] as? [JSON]
        return (relations, nil)
    }
    
}
