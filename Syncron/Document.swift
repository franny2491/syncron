//
//  Document.swift
//  Syncron
//
//  Created by Armadillo on 16/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import Foundation
import CoreData

class Document: NSManagedObject {

    class func createDocumentInContext(document :Docs, context:NSManagedObjectContext) -> Document! {
        
        if let doc :Document? = fetchDocumentInContext(document.fileName(), context: context) {
            return doc!
        }
        
        let newDocument :Document = NSEntityDescription.insertNewObjectForEntityForName(CoreDataEntities.Document, inManagedObjectContext: context) as! Document
        newDocument.title = document.fileName()
        newDocument.content = document.docContent
        
        CoreData.sharedInstance.saveContext(context)
        return newDocument
    }
    
    class func fetchDocumentInContext(fileName :String, context:NSManagedObjectContext) -> Document! {
        let request:NSFetchRequest = NSFetchRequest(entityName: CoreDataEntities.Document)
        request.fetchLimit = 1
        
        let matches:Array = try! context.executeFetchRequest(request)
        if matches.first != nil {
            return matches.first as! Document
        }
        
        return nil
    }
}
