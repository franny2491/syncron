//
//  CoreData.swift
//  Syncron
//
//  Created by Armadillo on 16/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit
import CoreData

class CoreData: NSObject {
    static let sharedInstance = CoreData()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.storeURL
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            
        } catch _ as NSError {
            CoreData.sharedInstance.destroyStore()
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            do {
                try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            } catch _ as NSError {
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to destroy and recreate the store"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                dict[NSUnderlyingErrorKey] = error
                error = NSError(domain: "Shouldn't hit here", code: 9999, userInfo: dict)
                NSLog("This shouldn't happen! \(error), \(error!.userInfo)")
            }
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    lazy var storeURL : NSURL? = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent("Model.sqlite")
    }()
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.managedObjectContext
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            
            let context :NSManagedObjectContext = note.object as! NSManagedObjectContext
            if context != self.backgroundContext {
                return
            }
            
            let updateArray :NSSet! = note.userInfo?["updated"] as! NSSet
            
            for object in updateArray {
                let mainThreadObject :NSManagedObject! = try! CoreData.sharedInstance.managedObjectContext?.existingObjectWithID(object.objectID!)

                if mainThreadObject != nil {
                    if mainThreadObject.fault {
                        mainThreadObject.willAccessValueForKey(nil)
                    }
                }
            }
            
            if updateArray.count > 0 {
                CoreData.sharedInstance.managedObjectContext?.mergeChangesFromContextDidSaveNotification(note)
            }
        }
    }

    func destroyStore () {
        self.managedObjectContext = nil
        self.persistentStoreCoordinator = nil

        try! NSFileManager.defaultManager().removeItemAtURL(self.storeURL!)
    }

    func saveContext (context: NSManagedObjectContext) {
        let thread :NSThread = NSThread.currentThread()
        if thread.isMainThread {
            if context == self.backgroundContext {
                NSLog("Wrong Thread Pal, on Background Context on Main Thread...")
            }
        }
        else {
            if context == self.managedObjectContext {
                NSLog("Wrong Thread Pal, on Main Context on a Background Thread...")
            }
        }
        
        do {
            try context.save()
        } catch _ as NSError {
            NSLog("Unresolved error")
            
            if context == self.backgroundContext {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.saveMainContext()
                })
            }
        }
    }
    
    func saveMainContext () {
        self.saveContext(self.managedObjectContext!)
    }
}
