//
//  Storage.swift
//  kazimir-ios
//
//  Created by Krzysiek on 10/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import CoreData

class Storage {
    
    static let sharedInstance = Storage()
    
    let standardError = NSError(domain: "kazimir", code: 2, userInfo: nil)
    let dateFormatter = NSDateFormatter()
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    
    private init() {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
    
    func initializeStorage() -> NSError? {
        let modelURL = NSBundle.mainBundle().URLForResource("Kazimir", withExtension: "momd")
        if modelURL == nil { return standardError }
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        if managedObjectModel == nil { return standardError }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
        if documentsDirectory == nil { return standardError }
        let storeURL = documentsDirectory!.URLByAppendingPathComponent("Kazimir.sqlite")
        
        var error: NSError? = nil
        persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error)
        if error != nil {return error}
        
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return nil
    }
    
    func save() -> NSError? {
        var error: NSError? = nil
        managedObjectContext.save(&error)
        return error
    }
    
    func getStreetsFetchedResultsController() -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: "Street")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    private func getEntityName(type: NSManagedObject.Type) -> String {
        let className = NSStringFromClass(type)
        return className.substringFromIndex(advance(className.startIndex, count("kazimir_ios.")))
    }
    
    private func getEntity<T: NSManagedObject>(id: NSNumber, context: NSManagedObjectContext) -> T {
        let entityName = self.getEntityName(T.self)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        let result = context.executeFetchRequest(fetchRequest, error: nil)!
        if result.count > 0 {
            return result[0] as! T
        }
        else {
            let entity: T = self.createEntity(id, context: context)
            return entity
        }
    }
    
    private func createEntity<T: NSManagedObject>(id: NSNumber, context: NSManagedObjectContext) -> T {
        let entityName = self.getEntityName(T.self)
        let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as! T
        if let street = entity as? Street  {
            street.id = id
            street.updateDate = NSDate(timeIntervalSince1970: 0)
        }
        if let place = entity as? Place {
            place.id = id
            place.updateDate = NSDate(timeIntervalSince1970: 0)
        }
        if let photo = entity as? Photo {
            photo.id = id
        }
        return entity
    }
    
    func storeDataFromJSON(json: [[String: AnyObject]], context: NSManagedObjectContext) -> ([Street]?, NSError?) {
        var streets = [Street]()
        for entityJSON in json {
            let (street, error) = self.storeStreetFromJSON(entityJSON, context: context)
            if error != nil { return (nil, error) }
            streets.append(street!)
        }
        return (streets, nil)
    }
    
    private func storeStreetFromJSON(json: [String: AnyObject], context: NSManagedObjectContext) -> (Street?, NSError?) {
        let id = json["id"] as? NSNumber
        if id == nil { return (nil, standardError) }
        let street: Street = self.getEntity(id!, context: context)
        
        let dateString = json["updated_at"] as? String
        if dateString == nil { return (nil, standardError) }
        let updateDate = dateFormatter.dateFromString(dateString!)
        if updateDate == nil { return (nil, standardError) }
        
        if street.updateDate.compare(updateDate!) == .OrderedAscending {
            street.updateDate = updateDate!
            
            let name = json["name"] as? String
            if name == nil { return (nil, standardError) }
            street.name = name!
            
            let path = json["path"] as? [String : AnyObject]
            if path == nil { return (nil, standardError) }
            street.path = path!
            
            let placesJSON = json["places"] as? [String: AnyObject]
            if placesJSON == nil { return (nil, standardError) }
            
            let presentPlacesJSON = placesJSON!["present"] as? [[String: AnyObject]]
            if presentPlacesJSON == nil { return (nil, standardError) }
            
            var places = [Place]()
            for placeJSON in presentPlacesJSON! {
                let (place, error) = self.storePlaceFromJSON(placeJSON, present: true, context: context)
                if error != nil { return (nil, error) }
                places.append(place!)
            }
            
            let pastPlacesJSON = placesJSON!["past"] as? [[String: AnyObject]]
            if pastPlacesJSON == nil { return (nil, standardError) }
            
            for placeJSON in pastPlacesJSON! {
                let (place, error) = self.storePlaceFromJSON(placeJSON, present: false, context: context)
                if error != nil { return (nil, error) }
                places.append(place!)
            }
            street.places = NSOrderedSet(array: places)
        }
        
        return (street, nil)
    }
    
    private func storePlaceFromJSON(json: [String: AnyObject], present: Bool, context: NSManagedObjectContext) -> (Place?, NSError?) {
        let id = json["id"] as? NSNumber
        if id == nil { return (nil, standardError) }
        let place: Place = self.getEntity(id!, context: context)
        
        let dateString = json["update_at"] as? String
        if dateString == nil { return (nil, standardError) }
        let updateDate = dateFormatter.dateFromString(dateString!)
        if updateDate == nil { return (nil, standardError) }
        
        if place.updateDate.compare(updateDate!) == .OrderedAscending {
            place.updateDate = updateDate!
            place.present = NSNumber(bool: present)
            
            let details = json["details"] as? [String : AnyObject]
            if details == nil { return (nil, standardError) }
            place.details = details!
            
            let photosJSON = json["photos"] as? [[String: AnyObject]]
            if photosJSON == nil { return (nil, standardError) }
            
            var photos = [Photo]()
            for photoJSON in photosJSON! {
                let (photo, error) = self.storePhotoFromJSON(photoJSON, context: context)
                if error != nil { return (nil, error) }
                photos.append(photo!)
            }
            place.photos = NSOrderedSet(array: photos)
        }
        
        return (place, nil)
    }
    
    private func storePhotoFromJSON(json: [String: AnyObject], context: NSManagedObjectContext) -> (Photo?, NSError?) {
        let id = json["id"] as? NSNumber
        if id == nil { return (nil, standardError) }
        let photo: Photo = self.getEntity(id!, context: context)
        
        let details = json["details"] as? [String : AnyObject]
        if details == nil { return (nil, standardError) }
        photo.details = details!
        
        let imagesJSON = json["images"] as? [String: String]
        if imagesJSON == nil { return (nil, standardError) }
        
        let mediumPhotoString = imagesJSON!["medium"]
        if mediumPhotoString == nil { return (nil, standardError) }
        let (imageData, error) = self.downloadImageData(mediumPhotoString!)
        if error != nil { return (nil, error) }
        photo.dataMedium = imageData!
        
        return (photo, nil)
    }
    
    private func downloadImageData(urlString: String) -> (NSData?, NSError?) {
        let url = NSURL(string: urlString)
        if url == nil { return (nil, standardError) }
        let data = NSData(contentsOfURL: url!)
        if data == nil { return (nil, standardError) }
        return (data, nil)
    }
    
}
