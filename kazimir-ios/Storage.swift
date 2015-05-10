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
    
    let managedObjectContext = NSManagedObjectContext()
    let dateFormatter = NSDateFormatter()
    
    private init() {
        let modelURL = NSBundle.mainBundle().URLForResource("Kazimir", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        let storeURL = documentsDirectory.URLByAppendingPathComponent("Kazimir.sqlite")
        
        var error: NSError? = nil
        persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error)
        
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
   
    func storeDataFromJsonObject(jsonObject: [Dictionary<String, AnyObject>]) -> NSOrderedSet {
        let streets = NSMutableOrderedSet()
        for streetObject in jsonObject {
            let street = self.storeStreetFromJsonObject(streetObject)
            streets.addObject(street)
        }
        return streets
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
    
    private func getEntity<T: NSManagedObject>(id: NSNumber) -> T {
        let entityName = self.getEntityName(T.self)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = \(id)", argumentArray: nil)
        let result = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)!
        if result.count > 0 {
            return result[0] as! T
        }
        let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext) as! T
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
    
    private func storeStreetFromJsonObject(jsonObject: Dictionary<String, AnyObject>) -> Street {
        let street: Street = self.getEntity(jsonObject["id"] as! NSNumber)
        let dateString = jsonObject["updated_at"] as! String
        let updateDate = dateFormatter.dateFromString(dateString)!
        let aaa = street.updateDate.compare(updateDate)
        if street.updateDate.compare(updateDate) == .OrderedAscending {
            street.updateDate = updateDate
            street.name = jsonObject["name"] as! String
            street.path = jsonObject["path"] as! NSDictionary
            
            let places = NSMutableOrderedSet()
            let placesObject = jsonObject["places"] as! [String: AnyObject]
            for placeObject in placesObject["present"] as! [[String: AnyObject]] {
                let place = self.storePlaceFromJsonObject(placeObject, present: true)
                places.addObject(place)
            }
            for placeObject in placesObject["past"] as! [[String: AnyObject]] {
                let place = self.storePlaceFromJsonObject(placeObject, present: false)
                places.addObject(place)
            }
            street.places = places
        }
        
        return street
    }
    
    private func storePlaceFromJsonObject(jsonObject: [String: AnyObject], present: Bool) -> Place {
        let place: Place = self.getEntity(jsonObject["id"] as! NSNumber)
        let dateString = jsonObject["update_at"] as! String
        let updateDate = dateFormatter.dateFromString(dateString)!
        if place.updateDate.compare(updateDate) == .OrderedAscending {
            place.updateDate = updateDate
            place.present = NSNumber(bool: present)
            place.details = jsonObject["details"] as! NSDictionary
            
            let photos = NSMutableOrderedSet()
            for photoObject in jsonObject["photos"] as! [[String: AnyObject]] {
                let photo = self.storePhotoFromJsonObject(photoObject)
                photos.addObject(photo)
            }
            place.photos = photos
        }
        
        return place
    }
    
    private func storePhotoFromJsonObject(jsonObject: [String: AnyObject]) -> Photo {
        let photo: Photo = self.getEntity(jsonObject["id"] as! NSNumber)
        photo.id = jsonObject["id"] as! NSNumber
        photo.details = jsonObject["details"] as! NSDictionary
        
        let imagesObject = jsonObject["images"] as! Dictionary<String, String>
        photo.dataThumb = NSData(contentsOfURL: NSURL(string: imagesObject["thumb"]!)!)!
        photo.dataTiny = NSData(contentsOfURL: NSURL(string: imagesObject["tiny"]!)!)!
        photo.dataSmall = NSData(contentsOfURL: NSURL(string: imagesObject["small"]!)!)!
        photo.dataMedium = NSData(contentsOfURL: NSURL(string: imagesObject["medium"]!)!)!
        photo.dataLarge = NSData(contentsOfURL: NSURL(string: imagesObject["large"]!)!)!
        
        return photo
    }
    
}
