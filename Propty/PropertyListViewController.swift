//
//  PropertyListViewController.swift
//  Propty
//
//  Created by Alp Eren Can on 24/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class PropertyListViewController: UITableViewController, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    // MARK: - Properties

    var detailViewController: PropertyDetailViewController? = nil
    
    let locationManager = CLLocationManager()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PropertyDetailViewController
        }
        
        locationManager.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // TODO: Replace this implementation with suitable code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Begin: Parts of this code snippet is taken from NSHipster
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        case .NotDetermined:
            let alertController = UIAlertController(
                title: "Enable Location Access",
                message: "In order to show properties near you, Propty needs access to your device location.",
                preferredStyle: .Alert)
            
            let denyAction = UIAlertAction(title: "Deny", style: .Cancel) { (action) in
                self.showLocationDisabledAlert()
            }
            alertController.addAction(denyAction)
            
            let allowAction = UIAlertAction(title: "Allow", style: .Default) { (action) in
                self.locationManager.requestWhenInUseAuthorization()
            }
            alertController.addAction(allowAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        case .Restricted, .Denied:
            showLocationDisabledAlert()
        }
        // End: Parts of this code snippet is taken from NSHipster
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PropertyDetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Actions and Helpers
    func showLocationDisabledAlert() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order to see properties near you, please open this app's settings and set location access to 'While Using the App' or 'Always'.",
            preferredStyle: .Alert)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        alertController.addAction(openAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let property = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Property
            
            sharedContext.deleteObject(property)
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }

    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        cell.textLabel!.text = object.valueForKey("timeStamp")!.description
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    // MARK: - Fetched Results Controller

    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request for properties
        let fetchRequest = NSFetchRequest(entityName: "Property")
        
        // Sort by status and distance
        let savedSort = NSSortDescriptor(key: "saved", ascending: true)
        let distanceSort = NSSortDescriptor(key: "distance", ascending: true)
        fetchRequest.sortDescriptors = [savedSort, distanceSort]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: "saved",
                                                                  cacheName: nil)
        // Set the delegate
        fetchedResultsController.delegate = self
        
        // Return the fetched results controller.
        return fetchedResultsController
    }()

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
    
    // MARK: - Core Location
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO: Fetch properties nearby with updated location
    }

}

