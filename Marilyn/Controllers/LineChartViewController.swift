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

    
    private let dataSource = ["All", "Home", "Work", "School", "Grocery Store", "Ramen Shop", "Cafe", "On the Road"]
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var locationArray: [Any] = []
    
    @IBOutlet weak var LocationPicker: UIPickerView!
    
    @IBAction func hrsOnPressed(_ sender: UIButton) {
    }
    @IBAction func daysOnPressed(_ sender: UIButton) {
    }
    @IBAction func monthOnPressed(_ sender: UIButton) {
    }
    @IBAction func yearOnPressed(_ sender: UIButton) {
    }
    @IBAction func allTimeOnPressed(_ sender: UIButton) {
    }
    
    //// Mock up for graphic line chart, for now testing purpose,
    // just show row values
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationPicker.dataSource = self
        LocationPicker.delegate = self

        configureFetchedResultsController(EntityName: "Location")
        populatepickerView()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }

    func configureFetchedResultsController(EntityName: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
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

    func populatepickerView(){
        //var resultData: [String]
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        var locations = [Location]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        let sortDescriptorTypeTime = NSSortDescriptor(key: "locationName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        
        do { locations = try managedContext?.fetch(fetchRequest) as! [Location]
            
            for item in locations {
                locationArray.append(item.locationName as Any)
                
            }
            //print(locationArray)
            
        } catch {
            print("Error")
        }
        
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
        
        //textView.text = dataSource[row]
        textView.text = locationArray[row] as? String
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return dataSource[row]
        return locationArray[row] as? String
    }
    
    
    
}
