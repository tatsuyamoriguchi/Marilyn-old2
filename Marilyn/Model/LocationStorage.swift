//
//  LocationStorage.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/6/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//
// scrap this later, don't need it

import Foundation
import CoreLocation

class LocationsStorage {
    //static let shared = LocationsStorage()
    //private(set) var locations: [Location]


    func saveCLLocationToDisk(_ clLocation: CLLocation) {
        
        let currentDate = Date()
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let location = LocationData(clLocation.coordinate, date: currentDate, descriptionString: "\(place)")
//                self.saveLocationOnDisk(location)
            }
        }
    }

    
    
}




/*
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
 
 
 func saveSOM(locationName: String) {
 guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
 let managedContext = appDelegate.persistentContainer.viewContext
 
 let entity = NSEntityDescription.entity(forEntityName: "stateOfMind", in: managedContext)!
 let item = NSManagedObject(entity: entity, insertInto: managedContext)
 
 item.setValue(locationName, forKey: "stateOfMind.location")
 item.setValue(timeStamp, forKey: "timeStamp")
 item.setValue(causeDesc, forKey: "stateOfMind.cause")
 item.setValue(causeTypeSelected, forKey: "stateOfMind.causeType")
 item.setValue(stateOfMindDesc, forKey: "stateOfMind.stateOfMindDesc")
 
 do {
 try managedContext.save()
 
 } catch {
 print("Failed to save an item: \(error.localizedDescription)")
 }
 }
 */
