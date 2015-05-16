//
//  DataLoader.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 15/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import CoreData

typealias StreetProcessResult = (street: Street?, error: NSError?)
typealias PlacesProcessResult = (places: [Place]?, error: NSError?)
typealias PhotosProcessResult = (photos: [Photo]?, error: NSError?)

class DataLoader {
    
    static let sharedInstance = DataLoader()
    
    let downloadError = NSError(domain: "kazimir", code: 3, userInfo: nil)
    
    private init() {}
    
    func loadDataIntoContext(context: NSManagedObjectContext, locally: Bool, progress: () -> Bool) -> NSError? {
        let (jsons, error) = Client.sharedInstance.getData(locally: locally)
        if error != nil { return error }
        
        var streets = [Street]()
        for json in jsons! {
            let streetProcessResult = self.processStreet(json, context: context)
            if streetProcessResult.error != nil { return streetProcessResult.error }
            streets.append(streetProcessResult.street!)
            if !progress() { return nil }
        }
        
        // delete deprecated streets
        var fetchError: NSError? = nil
        let fetchRequest = NSFetchRequest(entityName: Storage.getEntityName(Street.self))
        let result = context.executeFetchRequest(fetchRequest, error: &fetchError)
        if error != nil { return error }
        for street in result as! [Street] {
            if !contains(streets, street) { context.deleteObject(street) }
        }
        progress()
        return nil
    }
    
    func processStreet(json: JSON, context: NSManagedObjectContext) -> StreetProcessResult {
        let storateResult = Storage.sharedInstance.storeEntityFromJSON(json, context: context) as StorageResult<Street>
        if storateResult.error != nil { return  (nil, storateResult.error) }
        
        var places = [Place]()
        let presentPlacesRelationInfo = Street.getPresentPlacesJSON(json: json)
        if presentPlacesRelationInfo.error != nil { return (nil, presentPlacesRelationInfo.error) }
        let presentPlacesProcessResult = self.processPlacesForStreet(storateResult.entity!, jsons:presentPlacesRelationInfo.jsons!, present: true, context: context)
        if presentPlacesProcessResult.error != nil { return  (nil, presentPlacesProcessResult.error) }
        places = places + presentPlacesProcessResult.places!
        
        let pastPlacesRelationInfo = Street.getPastPlacesJSON(json: json)
        if pastPlacesRelationInfo.error != nil { return (nil, pastPlacesRelationInfo.error) }
        let pastPlacesProcessResult = self.processPlacesForStreet(storateResult.entity!, jsons:pastPlacesRelationInfo.jsons!, present: false, context: context)
        if pastPlacesProcessResult.error != nil { return  (nil, pastPlacesProcessResult.error) }
        places = places + pastPlacesProcessResult.places!
        storateResult.entity!.places = NSOrderedSet(array: places)
        
        return (storateResult.entity!, nil)
    }
    
    func processPlacesForStreet(street: Street, jsons: [JSON], present: Bool,  context: NSManagedObjectContext) -> PlacesProcessResult {
        var places = [Place]()
        for json in jsons {
            let storageResult = Storage.sharedInstance.storeEntityFromJSON(json, context: context) as StorageResult<Place>
            if storageResult.error != nil { return  (nil, storageResult.error) }
            places.append(storageResult.entity!)
            
            if storageResult.updated! {
                storageResult.entity!.present = NSNumber(bool: present)
                
                let photosRelationInfo = Place.getPhotosJSON(json: json)
                if photosRelationInfo.error != nil { return (nil, photosRelationInfo.error) }
                let photosProcessResult = self.processPhotosForPlace(storageResult.entity!, jsons: photosRelationInfo.jsons!, context: context)
                if photosProcessResult.error != nil { return (nil, photosProcessResult.error) }
                storageResult.entity!.photos = NSOrderedSet(array: photosProcessResult.photos!)
            }
        }
        return (places, nil)
    }
    
    func processPhotosForPlace(place: Place, jsons: [JSON], context: NSManagedObjectContext) -> PhotosProcessResult {
        var photos = [Photo]()
        for json in jsons {
            let storageResult = Storage.sharedInstance.storeEntityFromJSON(json, context: context) as StorageResult<Photo>
            if storageResult.error != nil { return  (nil, storageResult.error) }
            photos.append(storageResult.entity!)
            
            let imagesRelationInfo = Photo.getImagesJSON(json: json)
            if imagesRelationInfo.error != nil { return (nil, imagesRelationInfo.error) }

            let mediumPhotoString = imagesRelationInfo.jsons![0]["medium"] as? String
            if mediumPhotoString == nil { return (nil, downloadError) }
            
            let (imageData, error) = Client.sharedInstance.getImageData(urlString: mediumPhotoString!)
            if error != nil { return (nil, error) }
            storageResult.entity!.dataMedium = imageData!
        }
        return (photos, nil)
    }
    
}
