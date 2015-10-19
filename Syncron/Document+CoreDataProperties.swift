//
//  Document+CoreDataProperties.swift
//  Syncron
//
//  Created by Armadillo on 16/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Document {

    @NSManaged var createdDate: NSDate?
    @NSManaged var updatedDate: NSDate?
    @NSManaged var url: String?
    @NSManaged var content: String?
    @NSManaged var title: String?

}
