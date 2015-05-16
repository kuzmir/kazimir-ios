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

extension Photo {
    
    static func getImagesJSON(#json: JSON) -> RelationInfo {
        let images = json[PhotoRelation.Images.rawValue] as? JSON
        if images == nil { return (nil, Storage.storageError) }
        return ([images!], nil)
    }
    
}

extension Photo: JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber? {
        return json[PhotoProperty.Id.rawValue] as? NSNumber
    }
    
    func fromJSON(json: JSON) -> ConversionResult {
        let details = json[PhotoProperty.Details.rawValue] as? JSON
        if details == nil { return (nil, Storage.storageError) }
        self.details = details!
        
        return (true, nil)
    }
    
}
