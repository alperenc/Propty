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


    var detailItem: Property? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            self.title = detail.name
            if let label = self.detailDescriptionLabel {
                if let address = detail.address, let city = detail.city {
                    label.text = "\(detail.name), ` \(address), \(city)"
                } else {
                    label.text = detail.name
                }
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }


}

