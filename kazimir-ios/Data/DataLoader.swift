//
//  DataLoader.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 15/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import CoreData

class DataLoader {
    
    static let sharedInstance = DataLoader()
    
    let loadError = NSError(domain: "kazimir", code: 3, userInfo: nil)
    
    private init() {}
    
    func loadDataIntoContext(context: NSManagedObjectContext, locally: Bool, progress: () -> Bool) -> NSError? {
        let result = Client.sharedInstance.getData(locally: locally)
        if result.error != nil { return result.error }
        
        var streets = [Street]()
        for json in result.jsons! {
            let street = self.processStreet(json, context: context)
            if street == nil { return loadError }
            streets.append(street!)
            if !progress() { return nil }
        }
        
        let error = self.deleteOldStreets(currentStreets: streets, context: context)
        if error != nil { return error }
        progress()
        return nil
    }
    
    private func deleteOldStreets(#currentStreets: [Street], context: NSManagedObjectContext) -> NSError? {
        var error: NSError? = nil
        let fetchRequest = NSFetchRequest(entityName: Storage.getEntityName(Street.self))
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil { return error }
        for street in result as! [Street] {
            if !contains(currentStreets, street) { context.deleteObject(street) }
        }
        return nil
    }
    
    private func processStreet(json: JSON, context: NSManagedObjectContext) -> Street? {
        let storageResult = Storage.sharedInstance.storeEntityFromJSON(json, context: context) as StorageResult<Street>
        if storageResult.error != nil { return nil }
        
        var places = [Place]()
        let presentPlacesRelationInfo = Street.getPresentPlacesJSON(json: json)
        if presentPlacesRelationInfo.error != nil { return nil }
        for json in presentPlacesRelationInfo.jsons! {
            let place = self.processPlace(json, context: context)
            if place == nil { return nil }
            place!.present = true
            places.append(place!)
        }
        
        let pastPlacesRelationInfo = Street.getPastPlacesJSON(json: json)
        if pastPlacesRelationInfo.error != nil { return nil }
        for json in pastPlacesRelationInfo.jsons! {
            let place = self.processPlace(json, context: context)
            if place == nil { return nil }
            place!.present = false
            places.append(place!)
        }
        
        for place in storageResult.entity!.places.array as! [Place] {
            if !contains(places, place) { context.deleteObject(place) }
        }
        storageResult.entity!.places = NSOrderedSet(array: places)
        
        return storageResult.entity
    }
    
    private func processPlace(json: JSON, context: NSManagedObjectContext) -> Place? {
        let storageResult = Storage.sharedInstance.storeEntityFromJSON(json, context: context) as StorageResult<Place>
        if storageResult.error != nil { return  nil }
        
        var photos = [Photo]()
        let photosRelationInfo = Place.getPhotosJSON(json: json)
        if photosRelationInfo.error != nil { return nil }
        for json in photosRelationInfo.jsons! {
            let photo = self.processPhoto(json, context: context)
            if photo == nil { return nil }
            photos.append(photo!)
        }
        
        for photo in storageResult.entity!.photos.array as! [Photo] {
            if !contains(photos, photo) { context.deleteObject(photo) }
        }
        storageResult.entity!.photos = NSOrderedSet(array: photos)
        
        return storageResult.entity
    }
    
    private func processPhoto(json: JSON, context: NSManagedObjectContext) -> Photo? {
        let storageResult = Storage.sharedInstance.storeEntityFromJSON(json, context: context) as StorageResult<Photo>
        if storageResult.error != nil { return nil }
        
        if storageResult.updated! {
            let thumbImageDataResult = self.loadImage(type: "thumb", withPhotoJSON: json)
            if thumbImageDataResult.error != nil { return nil }
            storageResult.entity!.dataThumb = thumbImageDataResult.data!
            
            let tinyImageDataResult = self.loadImage(type: "tiny", withPhotoJSON: json)
            if tinyImageDataResult.error != nil { return nil }
            storageResult.entity!.dataTiny = tinyImageDataResult.data!
            
            let smallImageDataResult = self.loadImage(type: "small", withPhotoJSON: json)
            if smallImageDataResult.error != nil { return nil }
            storageResult.entity!.dataSmall = smallImageDataResult.data!
            
            let mediumImageDataResult = self.loadImage(type: "medium", withPhotoJSON: json)
            if mediumImageDataResult.error != nil { return nil }
            storageResult.entity!.dataMedium = mediumImageDataResult.data!
            
            let largeImageDataResult = self.loadImage(type: "large", withPhotoJSON: json)
            if largeImageDataResult.error != nil { return nil }
            storageResult.entity!.dataLarge = largeImageDataResult.data!
        }
        
        return storageResult.entity
    }
    
    private func loadImage(#type: String, withPhotoJSON json: JSON) -> DataResult {
        let imagesRelationInfo = Photo.getImagesJSON(json: json)
        if imagesRelationInfo.error != nil { return (nil, imagesRelationInfo.error) }
        let photoString = imagesRelationInfo.jsons![0][type] as? String
        if photoString == nil { return (nil, loadError) }
        return Client.sharedInstance.getImageData(urlString: photoString!)
    }
    
}
