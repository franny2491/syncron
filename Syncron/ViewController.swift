//
//  ViewController.swift
//  Syncron
//
//  Created by Armadillo on 07/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView :UITableView?
    
    var documents :NSMutableArray?
    var query :NSMetadataQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url :NSURL? = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        print(url)
        
        title = "Documents"
        let addButton :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "newDocument:")
        navigationItem.rightBarButtonItem = addButton
        
        let refreshButton :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "loadDocuments")
        navigationItem.leftBarButtonItem = refreshButton
        
        documents = NSMutableArray()
        loadDocuments()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadDocuments", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDocuments() {
        let urlUbiq :NSURL? = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        if urlUbiq != nil {
            query = NSMetadataQuery()
            query?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            
            let predicate :NSPredicate = NSPredicate(format: "%K like 'Document-*'", NSMetadataItemFSNameKey)
            query?.predicate = predicate
            
            NSNotificationCenter.defaultCenter().addObserverForName(NSMetadataQueryDidFinishGatheringNotification, object: query, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
                
                let queryLocal :NSMetadataQuery = note.object as! NSMetadataQuery
                queryLocal.disableUpdates()
                queryLocal.stopQuery()
  
                self.loadData(queryLocal)
            })

            query?.startQuery()
        }
        else {
            print("Can't Access iCloud")
        }
    }
    
    func loadData(query :NSMetadataQuery) {
        documents?.removeAllObjects()
        
        for item in query.results {
            let metaItem :NSMetadataItem = item as! NSMetadataItem
            let url :NSURL = metaItem.valueForAttribute(NSMetadataItemURLKey) as! NSURL
            
            let doc :Docs = Docs(fileURL :url)
            doc.openWithCompletionHandler({ (success) -> Void in
                if success {
                    Document.createDocumentInContext(doc, context: CoreData.sharedInstance.managedObjectContext!)
                    
                    if !self.documents!.containsObject(doc) {
                        self.documents?.addObject(doc)
                        self.tableView?.reloadData()
                    }
                }
            })
        }
    }

    func newDocument(sender :UIBarButtonItem) {
        let dateFormatter :NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        
        let fileName :String = String(format: "Document-%@", dateFormatter.stringFromDate(NSDate()))
        let url :NSURL? = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        let ubiquitousPackage = url?.URLByAppendingPathComponent("Documents").URLByAppendingPathComponent(fileName)
        
        let document :Docs = Docs(fileURL :ubiquitousPackage!)
        Document.createDocumentInContext(document, context: CoreData.sharedInstance.managedObjectContext!)
        
        document.saveToURL(document.fileURL, forSaveOperation: UIDocumentSaveOperation.ForCreating) { (success) -> Void in
            if success {
                self.documents?.addObject(document)
                self.tableView?.reloadData()
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell :UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("defaultCell")
        
        let document :Docs = documents?.objectAtIndex(indexPath.row) as! Docs
        cell!.textLabel!.text = document.fileName()
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "documentContentSegue" {
            let destinationController :FileViewController = segue.destinationViewController as! FileViewController
            let index :Int = tableView!.indexPathForSelectedRow!.row
            destinationController.document = documents?.objectAtIndex(index) as? Docs
        }
    }
}

