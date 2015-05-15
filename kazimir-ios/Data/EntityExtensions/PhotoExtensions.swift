//
//  PhotoExtensions.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

enum PhotoRelation: String {
    case Images = "images"
}

enum PhotoProperty: String {
    case Id = "id"
    case Details = "details"
}

extension Photo: JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber? {
        return json[PhotoProperty.Id.rawValue] as? NSNumber
    }
    
    static func getUpdateDateFromJSON(json: JSON) -> NSDate? {
        return NSDate(timeIntervalSince1970: 0)
    }
    
    func fromJSON(json: JSON) -> (Relations?, NSError?) {
        let details = json[PhotoProperty.Details.rawValue] as? JSON
        if details == nil { return (nil, Storage.storageError) }
        self.details = details!
        
        var relations = Relations()
        relations[PhotoRelation.Images.rawValue] = json[PhotoRelation.Images.rawValue] as? [JSON]
        return (relations, nil)
    }
    
}
