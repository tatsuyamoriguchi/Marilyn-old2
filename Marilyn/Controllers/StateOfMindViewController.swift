//
//  StateOfMindViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/9/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import UserNotifications
import Contacts


class StateOfMindViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetchedResultsController()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        fetchAnnotations()
        
        
    }
    
    // To display a red pin right after entering a new SOM location data
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    func fetchAnnotations() {
        
        guard var pins = fetchedResultsController?.fetchedObjects as? [StateOfMind] else { return }
        
        // Place past pins onto the map
        for pin in pins {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: (pin.location?.latitude)!, longitude: pin.location!.longitude)
            pointAnnotation.title = pin.location!.locationName
            
            
            pointAnnotation.subtitle = pin.stateOfMindDesc!.adjective
            self.mapView.addAnnotation(pointAnnotation)
            
            
        }
    }
    
    func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        let sortDescriptorType = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate
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

extension StateOfMindViewController: UITableViewDelegate, UITableViewDataSource {
    
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

        let Cell = tableView.dequeueReusableCell(withIdentifier: "SOMCell", for: indexPath)
        if let stateOM = fetchedResultsController?.object(at: indexPath) as? StateOfMind {
            
            Cell.textLabel?.text = stateOM.location?.locationName
            Cell.detailTextLabel?.text = stateOM.stateOfMindDesc?.adjective
        }
        return Cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        
        let stateOM = fetchedResultsController?.object(at: indexPath) as? StateOfMind
        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        fetchRequest.predicate = NSPredicate(format: "location.locationName == %@", (stateOM?.location?.locationName)!)
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = stateOM?.location?.locationName
        pointAnnotation.subtitle = stateOM?.stateOfMindDesc?.adjective
        pointAnnotation.coordinate.latitude = (stateOM?.location?.latitude)!
        pointAnnotation.coordinate.longitude = (stateOM?.location?.longitude)!
    
        self.mapView.addAnnotation(pointAnnotation)
        mapView.selectAnnotation(pointAnnotation, animated: true)
        print("++++++++++++")
        print(pointAnnotation.title!)


        /*
        if let stateOM = fetchedResultsController?.object(at: indexPath) as? StateOfMind {
        
            let pointName = stateOM.location?.locationName
            let searchResutls = mapView.annotations.filter { annotation in
                return (annotation.title??.localizedCaseInsensitiveContains(pointName!) ?? false)
            }
            print("+++++++++++++")
            print(searchResutls) // MKPointAnnotation???
            
            mapView.selectAnnotation(searchResutls as! MKAnnotation, animated: true)
        }*/
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let wordToSwipe = self.fetchedResultsController?.object(at: indexPath)
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            print("Editing")
            if let som = self.fetchedResultsController?.object(at: indexPath) as? StateOfMind {
                
                self.somAlert(StateOfMind: som)
            }
        }
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            print("Deleting")
            managedContext?.delete(wordToSwipe as! NSManagedObject)
        }
        
        do {
            try managedContext?.save()
        } catch {
            print("Saving Error: \(error)")
        }
        
        edit.backgroundColor = UIColor.blue
        return [edit, delete]
    }
    
    
    func somAlert(StateOfMind: StateOfMind) {
        let alertController = UIAlertController(title: "Edit", message: "Edit and Update the State Of Mind data.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let nameToUpdate = alertController.textFields![0].text
            
            self.update(StateOfMind: StateOfMind, NameToUpdate: nameToUpdate!)
        })
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Type State of Mind to Update"
            saveAction.isEnabled = false
            textField.text = StateOfMind.stateOfMindDesc?.adjective
            
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertController.textFields![0], queue: OperationQueue.main) { (notification) in
            if (alertController.textFields![0].text?.count)! > 0 {
                saveAction.isEnabled = true
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func update(StateOfMind: StateOfMind, NameToUpdate: String) {
        StateOfMind.setValue(NameToUpdate, forKey: "stateOfMind.stateOfMindDesc.adjective")
    }
    
}

extension StateOfMindViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
        
        
    }
}

extension StateOfMindViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("An annotation was tapped!")
     
        let pinToZoomOn = view.annotation
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StateOfMind")
        
        if let selectedAnnotation = view.annotation as? MKPointAnnotation {
            
            let selectedLocationName = selectedAnnotation.title
            fetchRequest.predicate = NSPredicate(format: "location.locationName == %@", selectedLocationName!)
            
            print("selectedAnnotation.title: \(String(describing: selectedAnnotation.title))")
        }
        
        let sortDescriptorType = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorType]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        configureFetchedResultsController()
        tableView.reloadData()
    }
}


