//
//  Storage.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 10/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import CoreData

class Storage {
    
    static let sharedInstance = Storage()
    static let storageError = NSError(domain: "kazimir", code: 4, userInfo: nil)
    static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    
    static func getEntityName(type: NSManagedObject.Type) -> String {
        let className = NSStringFromClass(type)
        let entityName = className.substringFromIndex(advance(className.startIndex, count("kazimir_ios.")))
        return entityName
    }
    
    let managedObjectContext: NSManagedObjectContext? = {
        let modelURL = NSBundle.mainBundle().URLForResource("Kazimir", withExtension: "momd")
        if modelURL == nil { return nil }
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        if managedObjectModel == nil { return nil }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL
        if documentsDirectory == nil { return nil }
        let storeURL = documentsDirectory!.URLByAppendingPathComponent("Kazimir.sqlite")
        
        var error: NSError? = nil
        persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error)
        if error != nil { return nil }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private init() { }
    
    func createEntityFromJSON<T where T: JSONConvertible, T: NSManagedObject>(json: JSON, context: NSManagedObjectContext) -> ((T, Relations?)?, NSError?) {
        let id = T.getIdFromJSON(json)
        if id == nil { return (nil, Storage.storageError) }
        let entity: T = self.getEntity(id!, context: context)
        
        let (relations, error) = entity.fromJSON(json)
        if (error != nil) { return (nil, error) }
        else { return ((entity, relations), nil) }
    }
    
    func createEntityWithoutRelationsFromJSON<T where T: JSONConvertible, T: NSManagedObject>(json: JSON, context: NSManagedObjectContext) -> (T?, NSError?) {
        var error: NSError? = nil
        var result: (T, Relations?)? = nil
        (result, error) = self.createEntityFromJSON(json, context: context)
        if error != nil { return (nil, error) }
        return (result!.0, nil)
    }
    
    func getWriteManagedObjectContext() -> NSManagedObjectContext! {
        let writeManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        writeManagedObjectContext.parentContext = managedObjectContext
        return writeManagedObjectContext
    }
    
    func save() -> NSError? {
        var error: NSError? = nil
        managedObjectContext!.save(&error)
        return error
    }
    
    func getStreetsFetchedResultsController() -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: "Street")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    private func getEntity<T: NSManagedObject>(id: NSNumber, context: NSManagedObjectContext) -> T {
        let entityName = Storage.getEntityName(T.self)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        let result = context.executeFetchRequest(fetchRequest, error: nil)!
        return result.count > 0 ? result[0] as! T : self.createEntity(id, context: context) as T
    }
    
    private func createEntity<T: NSManagedObject>(id: NSNumber, context: NSManagedObjectContext) -> T {
        let entityName = Storage.getEntityName(T.self)
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
    
}