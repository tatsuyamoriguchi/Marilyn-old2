//
//  LineChartViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/14/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class LineChartViewController: UIViewController {

    
    //private let dataSource = ["All", "Home", "Work", "School", "Grocery Store", "Ramen Shop", "Cafe", "On the Road"]
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var locationArray: [Any] = []
    var somArray: [Date] = []
    var locaName: String? = "All"
    
    @IBOutlet weak var LocationPicker: UIPickerView!
    
    
    @IBAction func hrsOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "24hrs")
        mockupDisplay()
    }
    @IBAction func daysOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "7days")
        mockupDisplay()
    }
    @IBAction func monthOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "1month")
        mockupDisplay()
    }
    @IBAction func yearOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "1year")
        mockupDisplay()
    }
    @IBAction func allTimeOnPressed(_ sender: UIButton) {
        calculateRate(timeRangeString: "all")
        mockupDisplay()
    }
    
    func mockupDisplay() {
       /* var somArrayString: String = ""
        for i in somArray {
            print("i: \(i)")
           // let today = Date()
            //today.toString(dateFormat: "MM-dd-yyyy-hh-mm-ss")
            somArrayString = i.toString(style: .long)
            print("somArrayString: \(somArrayString)")
            somArrayString.append(somArrayString)
        }
        */
        textView.text = "somArray: \(somArray)"
        print("final somArray: \(somArray)")
    }

    //// Mock up for graphic line chart, for now testing purpose,
    // just show row values
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationPicker.dataSource = self
        LocationPicker.delegate = self

        configureFetchedResultsController(EntityName: "Location", sortString: "timeStamp")
        
        populateLocationData()
        
    }
    
    // To reload UIPickerView data with new location data
    override func viewDidAppear(_ animated: Bool) {
        // To avoid append array data to itself
        locationArray = []
        viewDidLoad()
    }

    func configureFetchedResultsController(EntityName: String, sortString: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        let sortDescriptorType = NSSortDescriptor(key: sortString, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func calculateRate(timeRangeString: String) {
        
        configureFetchedResultsController(EntityName: "StateOfMind", sortString: "timeStamp")
        
        switch timeRangeString {
        case "24hrs":
            print("24hrs")
            let endDate = Date()
            //let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
            let startDate = Calendar.current.date(byAdding: .hour, value: -7, to: endDate)
            //print("startDate: \(startDate)")
            //print("endDate: \(endDate)")
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)
            
        case "7days":
            print("7days")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)

        case "1month":
            print("1month")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)

        case "1year":
            print("1year")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)
            
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)

        default:
            print("default all")
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: 0, to: endDate)
            populateSOMData(startDate: startDate!, endDate: endDate, selectedLocationName: locaName!)

        }
    }


    func populateSOMData(startDate: Date, endDate: Date, selectedLocationName: String){
        somArray = []
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var items = [StateOfMind]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        print("selectedLocationName: \(selectedLocationName)")
        
/*        if selectedLocationName != "All" {
            fetchRequest.predicate = NSPredicate(format: "location.locationName == %@", selectedLocationName)
            print("Howdy!")
            
        }
  */
        // selectedLocaitonName = "All" && startDate == endDate
/*
        if selectedLocationName != "All" {
            if startDate != endDate {
                //fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
                fetchRequest.predicate = NSPredicate(format: "(location.locationName == %@) AND (timeStamp >= %@) AND (timeStamp < %@)", selectedLocationName, startDate as CVarArg, endDate as CVarArg)
            }
            else {
                fetchRequest.predicate = NSPredicate(format: "location.locationName == %@", selectedLocationName)
            }
        } else if startDate != endDate {
            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
        } else {}
*/
        
        // selectedLocationName : startDate == endDate
        // All : All Time(true)
        // All : limited time
        // Location : All time
        // Locaiton : Limited time
        
        if (selectedLocationName != "All") && (startDate != endDate) {
            //fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            fetchRequest.predicate = NSPredicate(format: "(location.locationName == %@) AND (timeStamp >= %@) AND (timeStamp < %@)", selectedLocationName, startDate as CVarArg, endDate as CVarArg)
            
        } else if (selectedLocationName != "All") && (startDate == endDate) {
            fetchRequest.predicate = NSPredicate(format: "location.locationName == %@", selectedLocationName)
            
        } else if (selectedLocationName == "All") && (startDate != endDate) {
            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp < %@)", startDate as CVarArg, endDate as CVarArg)
            
        } else {}

    
    
        
        let sortDescriptorTypeTime = NSSortDescriptor(key: "timeStamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        
        do { items = try managedContext?.fetch(fetchRequest) as! [StateOfMind]
            for item in items {
                somArray.append(item.timeStamp!)
                print("item.location.locationName: \(item.location?.locationName)")
            }
        } catch {
            print("Error")
        }
    }
    
    func populateLocationData(){
        //var resultData: [String]
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var items = [Location]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        let sortDescriptorTypeTime = NSSortDescriptor(key: "locationName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        
        do { items = try managedContext?.fetch(fetchRequest) as! [Location]
            for item in items {
                locationArray.append(item.locationName as Any)
            }
        } catch {
            print("Error")
        }
        locationArray.insert("All", at: 0)
        print("locationArray: \(locationArray)")
    }

}


extension LineChartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return dataSource.count
        return locationArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //textView.text = locationArray[row] as? String
        locaName = locationArray[row] as? String ?? "All"
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return dataSource[row]
        return locationArray[row] as? String
    }
}

extension Date {
    func toString(style : DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}
