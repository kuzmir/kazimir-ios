//
//  DataDownloader.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 15/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import CoreData

class DataDownloader {
    
    static let sharedInstance = DataDownloader()
    
    let downloadError = NSError(domain: "kazimir", code: 3, userInfo: nil)
    
    private init() {}
    
    func downloadDataIntoContext(context: NSManagedObjectContext) -> NSError? {
        var (jsons, error) = Client.sharedInstance.downloadData()
        if error != nil { return error }
        
        var streets = [Street]()
        for json in jsons! {
            var result: (Street, Relations?)? = nil
            (result, error) = Storage.sharedInstance.createEntityFromJSON(json, context: context)
            if error != nil { return  error }
            let street = result!.0
            
            var places = [Place]()
            let presentPlacesJSON = result!.1![StreetRelation.PresentPlaces.rawValue]
            if presentPlacesJSON != nil {
                var presentPlaces: [Place]? = nil
                (presentPlaces, error) = self.processPlacesForStreet(street, jsons:presentPlacesJSON!, present: true, context: context)
                if error != nil { return  error }
                places = places + presentPlaces!
            }
            
            let pastPlacesJSON = result!.1![StreetRelation.PastPlaces.rawValue]
            if pastPlacesJSON != nil {
                var pastPlaces: [Place]? = nil
                (pastPlaces, error) = self.processPlacesForStreet(street, jsons:pastPlacesJSON!, present: false, context: context)
                if error != nil { return  error }
                places = places + pastPlaces!
            }
            street.places = NSOrderedSet(array: places)
            streets.append(street)
        }
        
        // delete old streets
        let fetchRequest = NSFetchRequest(entityName: Storage.getEntityName(Street.self))
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil { return error }
        for street in result as! [Street] {
            if !contains(streets, street) { context.deleteObject(street) }
        }
        return nil
    }
    
    func processPlacesForStreet(street: Street, jsons: [JSON], present: Bool,  context: NSManagedObjectContext) -> ([Place]?, NSError?) {
        var places = [Place]()
        for json in jsons {
            var error: NSError? = nil
            var result: (Place, Relations?)? = nil
            (result, error) = Storage.sharedInstance.createEntityFromJSON(json, context: context)
            if error != nil { return  (nil, error) }
            let place = result!.0
            place.present = NSNumber(bool: present)
            places.append(place)
            
            let photosJSON = result!.1![PlaceRelation.Photos.rawValue]
            if photosJSON != nil {
                var photos: [Photo]? = nil
                (photos, error) = self.processPhotosForPlace(place, jsons: photosJSON!, context: context)
                if error != nil { return (nil, error) }
                place.photos = NSOrderedSet(array: photos!)
            }
        }
        return (places, nil)
    }
    
    func processPhotosForPlace(place: Place, jsons: [JSON], context: NSManagedObjectContext) -> ([Photo]?, NSError?) {
        var photos = [Photo]()
        for json in jsons {
            var (photo, error) = Storage.sharedInstance.createEntityWithoutRelationsFromJSON(json, context: context) as (Photo?, NSError?)
            if error != nil { return  (nil, error) }
            photos.append(photo!)
            
            let images = json["images"] as? [String: String]
            if images == nil { return (nil, downloadError) }
            let mediumPhotoString = images!["medium"]
            if mediumPhotoString == nil { return (nil, downloadError) }
            
            var imageData: NSData? = nil
            (imageData, error) = self.downloadImageData(mediumPhotoString!)
            if error != nil { return (nil, error) }
            photo!.dataMedium = imageData!
        }
        return (photos, nil)
    }
    
    private func downloadImageData(urlString: String) -> (NSData?, NSError?) {
        let url = NSURL(string: urlString)
        if url == nil { return (nil, downloadError) }
        let data = NSData(contentsOfURL: url!)
        if data == nil { return (nil, downloadError) }
        return (data, nil)
    }
   
}
