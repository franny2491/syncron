//
//  ViewController.swift
//  Syncron
//
//  Created by Armadillo on 07/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var query :NSMetadataQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url :NSURL? = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        print(url)
        
        loadDocument()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let nameOfFile :String = "myDocument.txt"
    func loadDocument() {
        let queryNew :NSMetadataQuery = NSMetadataQuery()
        let array :NSArray = NSArray(objects: NSMetadataQueryUbiquitousDocumentsScope)
        queryNew.searchScopes = array as [AnyObject]
        
        let predicate :NSPredicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, nameOfFile)
        queryNew.predicate = predicate
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSMetadataQueryDidFinishGatheringNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in

            let query :NSMetadataQuery = note.object as! NSMetadataQuery
            query.disableUpdates()
            query.stopQuery()

            NSNotificationCenter.defaultCenter().removeObserver(self, name:NSMetadataQueryDidFinishGatheringNotification, object: query)
            
            self.loadFile(query)
        }
        
        query = queryNew
        query!.startQuery()
    }

    func loadFile(query :NSMetadataQuery) {
        if query.resultCount == 1 {
            let item :NSMetadataItem = query.resultAtIndex(0) as! NSMetadataItem
            let url :NSURL = item.valueForAttribute(NSMetadataItemURLKey) as! NSURL
            let document :Docs = Docs(fileURL: url)
            document.openWithCompletionHandler({ (success) -> Void in
                if success {
                    print("Opened")
                }
                else {
                    print("Failed to open")
                }
            })
        }
        else {
            let url :NSURL? = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
            let ubiquitousPackage = url?.URLByAppendingPathComponent("Documents").URLByAppendingPathComponent(nameOfFile)
            
            let document :Docs = Docs(fileURL: ubiquitousPackage!)
            document.saveToURL(document.fileURL, forSaveOperation: UIDocumentSaveOperation.ForCreating, completionHandler: { (success) -> Void in
                if success {
                    document.openWithCompletionHandler({ (success) -> Void in
                        print("new document")
                    })
                }
            })
        }
    }
}

