//
//  Docs.swift
//  Syncron
//
//  Created by Armadillo on 12/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit

class Docs: UIDocument {
    var docContent :String!

    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        print(contents)
        
        if contents.length > 0 {
            docContent = String(data: contents as! NSData, encoding: NSUTF8StringEncoding)
        }
        else {
            docContent = "Empty"
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("documentChanged", object: self)
    }

    override func contentsForType(typeName: String) throws -> AnyObject {
        
        if docContent != nil {
            if docContent.characters.count == 0 {
                docContent = "Empty"
            }
        }
        else {
            docContent = "Empty"
        }

        
        return docContent.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func fileName() -> String {
        let documentName :String? = fileURL.lastPathComponent
        return documentName!
    }
}
