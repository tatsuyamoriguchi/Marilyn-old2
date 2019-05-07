//
//  LocationStorage.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/6/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import Foundation
import CoreLocation

class LocationsStorage {
    static let shared = LocationsStorage()
    
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
