//
//  PropertyListViewController.swift
//  Propty
//
//  Created by Alp Eren Can on 24/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
import SWTableViewCell

class PropertyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties

    var detailViewController: PropertyDetailViewController? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    let locationManager = CLLocationManager()
    
    let saveColor = UIColor(red:119.0/255.0, green: 170.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    
    var lastUpdatedLocation: CLLocation?
    var locationUpdateFailCount = 0
    var editingMode: Bool = false
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add edit button
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PropertyDetailViewController
        }
        
        // Add refreshing capability
        refreshControl.addTarget(self, action: #selector(PropertyListViewController.refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        locationManager.distanceFilter = 500
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
        tableView.remembersLastFocusedIndexPath = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (lastUpdatedLocation?.coordinate.latitude != locationManager.location?.coordinate.latitude
            && lastUpdatedLocation?.coordinate.longitude != locationManager.location?.coordinate.longitude)
            || locationManager.location == nil {
            fetchLocation()
        }
        
        configureAnnotations()
        
    }

    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PropertyDetailViewController
            
            if let sender = sender as? UITableView {
                if let indexPath = sender.indexPathForSelectedRow {
                    let property = fetchedResultsController.objectAtIndexPath(indexPath) as! Property
                    controller.detailItem = property
                }
            } else if let sender = sender as? MKAnnotationView {
                if let property = sender.annotation as? Property {
                    controller.detailItem = property
                }
            }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Actions and Helpers
    
    @IBAction func switchViews(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            mapView.hidden = true
        } else {
            configureAnnotations()
            mapView.hidden = false
        }
        
    }
    
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
    
    func fetchLocation() {
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
                // TODO: Show "Location Needed" alert instead of this.
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
    
    func refresh() {
        fetchLocation()
        
        refreshControl.endRefreshing()
    }
    
    func leftUtilityButtons(indexPath: NSIndexPath) -> [AnyObject] {
        let leftUtilityButtons = NSMutableArray()
        
        if fetchedResultsController.sections?.count > 1 {
            if indexPath.section == 0 {
                leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor.grayColor(), title: "Remove")
            } else {
                
                leftUtilityButtons.sw_addUtilityButtonWithColor(saveColor, title: "Save")
            }
        } else {
            leftUtilityButtons.sw_addUtilityButtonWithColor(saveColor, title: "Save")
        }
        
        return leftUtilityButtons as [AnyObject]
    }
    
    func toggleSavedAttributeForProperty(property: Property) {
        property.saved = !property.saved
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    func configureAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        if let properties = fetchedResultsController.fetchedObjects as? [Property] {
            for property in properties {
                mapView.addAnnotation(property)
            }
        }
        
    }
    
    // MARK: - View Controller
    override func setEditing(editing: Bool, animated: Bool) {
        editingMode = editing
        super.setEditing(editing, animated: animated)
    }

    // MARK: - Table View Data Source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("propertyCell", forIndexPath: indexPath) as! PropertyTableViewCell
        cell.leftUtilityButtons = leftUtilityButtons(indexPath)
        cell.delegate = self
        
        let property = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Property
        self.configureCell(cell, withProperty: property)
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let property = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Property
            
            sharedContext.deleteObject(property)
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }

    func configureCell(cell: PropertyTableViewCell, withProperty property: Property) {
        cell.textLabel?.text = property.title
        cell.detailTextLabel?.text = property.subtitle
    }
    
    // MARK: - Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: tableView)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fetchedResultsController.sections?.count > 1 {
            if section == 0 {
                return "Saved Properties"
            } else {
                return "Properties provided by foursquare"
            }
        } else {
            return "Properties provided by foursquare"
        }
    }
    
    // MARK: - Map View Delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let propertyAnnotation = annotation as? Property else {
            return nil
        }
        
        let reuseId = "propertyAnnotationView"
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            view?.animatesDrop = true
        } else {
            view?.annotation = annotation
        }
        
        if propertyAnnotation.saved {
            view?.pinTintColor = saveColor
        } else {
            view?.pinTintColor = UIColor.redColor()
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        guard let property = view.annotation as? Property else {
            print("Selected annotation is not a Property!")
            return
        }
        
        if editingMode {
            sharedContext.deleteObject(property)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("showDetail", sender: view)
        }
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
        let savedSort = NSSortDescriptor(key: "saved", ascending: false)
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
        
        guard let property = anObject as? Property else {
            return
        }
        
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                mapView.addAnnotation(property)
            
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                mapView.removeAnnotation(property)
            
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! PropertyTableViewCell
                self.configureCell(cell, withProperty: property)
                mapView.removeAnnotation(property)
                mapView.addAnnotation(property)
            
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
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
    
}

// MARK: - Core Location

extension PropertyListViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        mapView.showsUserLocation = true
        
        guard let updatedLocation = locations.last else {
            return
        }
        
        var deletedPropertyCount = 0
        if (lastUpdatedLocation?.coordinate.latitude != locations.last?.coordinate.latitude && lastUpdatedLocation?.coordinate.longitude != locations.last?.coordinate.longitude) && lastUpdatedLocation != nil {
            for property in fetchedResultsController.fetchedObjects as! [Property] {
                if !property.saved {
                    sharedContext.deleteObject(property)
                    deletedPropertyCount += 1
                }
            }
            print("Deleted properties: \(deletedPropertyCount)")
        }
        
        
        
        lastUpdatedLocation = updatedLocation
        
        if abs(updatedLocation.timestamp.timeIntervalSinceNow) > 300 {
            return
        }
        
        FoursquareClient.sharedInstance().getVenuesForLocation(updatedLocation) { (success, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    let alertController = UIAlertController(
                        title: "Properties failed to load.",
                        message: "\(error!.localizedDescription) \n Please try again later.",
                        preferredStyle: .Alert)
                    
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
                    
                    alertController.addAction(dismissAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            
        }
        
        let mapRegion = MKCoordinateRegionMakeWithDistance(updatedLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        locationUpdateFailCount += 1
        
        if locationUpdateFailCount > 1 {
            
            let alertController = UIAlertController(
                title: "Updating Location Failed",
                message: error.localizedDescription,
                preferredStyle: .Alert)
            
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            self.presentViewController(alertController, animated: true) {
                self.locationUpdateFailCount = 0
            }
        }
    }
    
}

// MARK: - UIToolbarDelegate

extension PropertyListViewController: UIToolbarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}

// MARK: - SWTableViewCellDelegate

extension PropertyListViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            let indexPath = tableView.indexPathForCell(cell)!
            let property = fetchedResultsController.objectAtIndexPath(indexPath) as! Property
            toggleSavedAttributeForProperty(property)
        default:
            break
        }
    }
    
}

