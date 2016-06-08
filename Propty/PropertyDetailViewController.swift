//
//  PropertyDetailViewController.swift
//  Propty
//
//  Created by Alp Eren Can on 24/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit

class PropertyDetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var saveToggleBarButtonItem: UIBarButtonItem!
    
    var detailItem: Property! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        self.title = detailItem.name
        if let label = self.detailDescriptionLabel {
            if let address = detailItem.address, let city = detailItem.city {
                label.text = "\(detailItem.name), ` \(address), \(city)"
            } else {
                label.text = detailItem.name
            }
            
        }
        
        if detailItem.saved {
            saveToggleBarButtonItem.title = "Remove"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    @IBAction func toggleSavedAttributeForProperty(sender: UIBarButtonItem) {
        
        detailItem.saved = !detailItem.saved
        CoreDataStackManager.sharedInstance().saveContext()
        
        saveToggleBarButtonItem.title = detailItem.saved ? "Remove" : "Save"
    }

}

