//
//  ViewController.swift
//  Syncron
//
//  Created by Armadillo on 07/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url :NSURL? = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        print(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

