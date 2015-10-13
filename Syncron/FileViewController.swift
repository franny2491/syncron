//
//  FileViewController.swift
//  Syncron
//
//  Created by Armadillo on 13/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textView :UITextView?
    var document :Docs?


    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserverForName("documentChanged", object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            self.document = note.object as? Docs
            self.textView?.text = self.document?.docContent
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        textView?.text = document?.docContent
    }
    
    func textViewDidChange(textView: UITextView) {
        document?.docContent = textView.text
        document?.updateChangeCount(.Done)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
