//
//  DataDownloader.swift
//  kazimir-ios
//
//  Created by Krzysiek on 15/05/15.
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
    
    

//    private func storeStreetFromJSON(json: [String: AnyObject], context: NSManagedObjectContext) -> (Street?, NSError?) {
//        let id = json["id"] as? NSNumber
//        if id == nil { return (nil, standardError) }
//        let street: Street = self.getEntity(id!, context: context)
//
//        let dateString = json["updated_at"] as? String
//        if dateString == nil { return (nil, standardError) }
//        let updateDate = dateFormatter.dateFromString(dateString!)
//        if updateDate == nil { return (nil, standardError) }
//
//        if street.updateDate.compare(updateDate!) == .OrderedAscending {
//            street.updateDate = updateDate!
//
//            let name = json["name"] as? String
//            if name == nil { return (nil, standardError) }
//            street.name = name!
//
//            let path = json["path"] as? [String : AnyObject]
//            if path == nil { return (nil, standardError) }
//            street.path = path!
//
//            let placesJSON = json["places"] as? [String: AnyObject]
//            if placesJSON == nil { return (nil, standardError) }
//
//            let presentPlacesJSON = placesJSON!["present"] as? [[String: AnyObject]]
//            if presentPlacesJSON == nil { return (nil, standardError) }
//
//            var places = [Place]()
//            for placeJSON in presentPlacesJSON! {
//                let (place, error) = self.storePlaceFromJSON(placeJSON, present: true, context: context)
//                if error != nil { return (nil, error) }
//                places.append(place!)
//            }
//
//            let pastPlacesJSON = placesJSON!["past"] as? [[String: AnyObject]]
//            if pastPlacesJSON == nil { return (nil, standardError) }
//
//            for placeJSON in pastPlacesJSON! {
//                let (place, error) = self.storePlaceFromJSON(placeJSON, present: false, context: context)
//                if error != nil { return (nil, error) }
//                places.append(place!)
//            }
//            street.places = NSOrderedSet(array: places)
//        }
//
//        return (street, nil)
//    }
//
//    private func storePlaceFromJSON(json: [String: AnyObject], present: Bool, context: NSManagedObjectContext) -> (Place?, NSError?) {
//        let id = json["id"] as? NSNumber
//        if id == nil { return (nil, standardError) }
//        let place: Place = self.getEntity(id!, context: context)
//
//        let dateString = json["update_at"] as? String
//        if dateString == nil { return (nil, standardError) }
//        let updateDate = dateFormatter.dateFromString(dateString!)
//        if updateDate == nil { return (nil, standardError) }
//
//        if place.updateDate.compare(updateDate!) == .OrderedAscending {
//            place.updateDate = updateDate!
//            place.present = NSNumber(bool: present)
//
//            let details = json["details"] as? [String : AnyObject]
//            if details == nil { return (nil, standardError) }
//            place.details = details!
//
//            let photosJSON = json["photos"] as? [[String: AnyObject]]
//            if photosJSON == nil { return (nil, standardError) }
//
//            var photos = [Photo]()
//            for photoJSON in photosJSON! {
//                let (photo, error) = self.storePhotoFromJSON(photoJSON, context: context)
//                if error != nil { return (nil, error) }
//                photos.append(photo!)
//            }
//            place.photos = NSOrderedSet(array: photos)
//        }
//
//        return (place, nil)
//    }
//
//    private func storePhotoFromJSON(json: [String: AnyObject], context: NSManagedObjectContext) -> (Photo?, NSError?) {
//        let id = json["id"] as? NSNumber
//        if id == nil { return (nil, standardError) }
//        let photo: Photo = self.getEntity(id!, context: context)
//
//        let details = json["details"] as? [String : AnyObject]
//        if details == nil { return (nil, standardError) }
//        photo.details = details!
//
//        let imagesJSON = json["images"] as? [String: String]
//        if imagesJSON == nil { return (nil, standardError) }
//
//        let mediumPhotoString = imagesJSON!["medium"]
//        if mediumPhotoString == nil { return (nil, standardError) }
//        let (imageData, error) = self.downloadImageData(mediumPhotoString!)
//        if error != nil { return (nil, error) }
//        photo.dataMedium = imageData!
//        
//        return (photo, nil)
//    }
//    
//    private func downloadImageData(urlString: String) -> (NSData?, NSError?) {
//        let url = NSURL(string: urlString)
//        if url == nil { return (nil, standardError) }
//        let data = NSData(contentsOfURL: url!)
//        if data == nil { return (nil, standardError) }
//        return (data, nil)
//    }
   
}
