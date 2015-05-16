//
//  StreetExtensions.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

enum StreetRelation: String {
    case Places = "places"
    case PresentPlaces = "present"
    case PastPlaces = "past"
}

enum StreetProperty: String {
    case Id = "id"
    case Name = "name"
    case Path = "path"
    case UpdateDate = "updated_at"
}

extension Street {
    
    static func getPresentPlacesJSON(#json: JSON) -> RelationInfo {
        let places = json[StreetRelation.Places.rawValue] as? JSON
        if places == nil { return (nil, Storage.storageError) }
        let presentPlaces = places![StreetRelation.PresentPlaces.rawValue] as? [JSON]
        if presentPlaces == nil { return (nil, Storage.storageError) }
        return (presentPlaces!, nil)
    }
    
    static func getPastPlacesJSON(#json: JSON) -> RelationInfo {
        let places = json[StreetRelation.Places.rawValue] as? JSON
        if places == nil { return (nil, Storage.storageError) }
        let presentPlaces = places![StreetRelation.PastPlaces.rawValue] as? [JSON]
        if presentPlaces == nil { return (nil, Storage.storageError) }
        return (presentPlaces!, nil)
    }
    
}

extension Street: JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber? {
        return json[StreetProperty.Id.rawValue] as? NSNumber
    }
    
    func fromJSON(json: JSON) -> ConversionResult {
        let updateDateString = json[StreetProperty.UpdateDate.rawValue] as? String
        if updateDateString == nil { return (nil, Storage.storageError) }
        let updateDate =  Storage.dateFormatter.dateFromString(updateDateString!)
        if updateDate == nil { return (nil, Storage.storageError) }
        
        if self.updateDate.compare(updateDate!) == .OrderedAscending {
            self.updateDate = updateDate!
            
            let name = json[StreetProperty.Name.rawValue] as? String
            if name == nil { return (nil, Storage.storageError) }
            self.name = name!
            
            let path = json[StreetProperty.Path.rawValue] as? JSON
            if path == nil { return (nil, Storage.storageError) }
            self.path = path!
            return (true, nil)
        }

        return (false, nil)
    }
    
}
