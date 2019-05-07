//
//  LocationViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/4/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import UserNotifications
import Contacts


class LocationViewController: UIViewController {
    
    var stateOfMindDesc: StateOfMindDesc!
    var causeDesc: Cause!
    var causeTypeSelected: CauseType!
    
    var address: String!
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addOnPressed(_ sender: UIBarButtonItem) {
        
        // To save current location data
        guard let currentLocation = mapView.userLocation.location else {
            return
        }
        
        
        
        let alert = UIAlertController(title: "Add Location", message: "Add a new location.", preferredStyle: .alert)
        
        let add = UIAlertAction(title: "Add", style: .default) { (alertAction: UIAlertAction) in
            guard let locationName = alert.textFields?[0].text else {
                print("alert.textFields?[0].text got nil.")
                return
            }
            
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            let timeStamp = currentLocation.timestamp
            let descriptionString = currentLocation.description
            
            
            //let clLocaiton = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            self.address = self.convertToAddress(latitude: latitude, longitude: longitude)
            self.add(locationName: locationName, descriptionString: descriptionString, latitude: latitude, longitude: longitude, timeStamp: timeStamp, address: self.address)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(add)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }

    func convertToAddress(latitude: Double, longitude: Double) -> String {
        // Get the location description
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
            
            guard let place = clPlacemark?.first else {
                print("No placemark from Apple: \(String(describing: error))")
                return
            }
            
            let postalAddressFormatter = CNPostalAddressFormatter()
            postalAddressFormatter.style = .mailingAddress
            
            if let postalAddress = place.postalAddress {
                self.address = postalAddressFormatter.string(from: postalAddress)
                print("ERROORRORORORO: \(self.address)")
                
            }
        }
        return self.address ?? "Super Error"
    }
    
    // Add a new locaiton with a location name to Location entity
    func add(locationName: String, descriptionString: String, latitude: Double, longitude: Double, timeStamp: Date, address: String ) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(locationName, forKey: "locationName")
        item.setValue(descriptionString, forKey: "descriptionString")
        item.setValue(latitude, forKey: "latitude")
        item.setValue(longitude, forKey: "longitude")
        item.setValue(timeStamp, forKey: "timeStamp")
        item.setValue(address, forKey: "address")
        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
        
        configureFetchedResultsController()
        tableView.reloadData()
       
    }
    
    
    func save(locationName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "stateOfMind", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(locationName, forKey: "stateOfMind.location")
        
        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        configureFetchedResultsController()
        
        // Testing
        print("This is LocationTableVC")
        print("stateOfMindDesc: \(String(describing: stateOfMindDesc))")
        print("causeDesc: \(String(describing: causeDesc))")
        print("causeTypeSelected: \(String(describing: causeTypeSelected))")

        // Do any additional setup after loading the view.
    }
    
    func configureFetchedResultsController() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let sortDescriptorType = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            print("numberOfRowsInSection failed.")
            return 0
        }
        let rowCount = sections[section].numberOfObjects
        print("The amount of rows in the section are: \(rowCount)")
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let LocationCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        if let loca = fetchedResultsController?.object(at: indexPath) as? Location {
            LocationCell.textLabel?.text = loca.locationName
            LocationCell.detailTextLabel?.text = loca.address
            
        }
        return LocationCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //saveSOM()
        
        
        
        
        // Back to TabBarController
        if let tabBarController = appDelegate.window!.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        }
        // animated: true returns warning "Swift Unbalanced calls to begin/end appearance transitions for"
        // This line should be placed at the bottom this funciton
        self.navigationController?.popToRootViewController(animated: false)
    }
}
