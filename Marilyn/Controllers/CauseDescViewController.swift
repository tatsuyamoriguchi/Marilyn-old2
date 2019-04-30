//
//  CauseDescViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 4/29/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

//class CauseDescViewController: UIViewController, UITextViewDelegate {
class CauseDescViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
 
    // Passed from StateOfMindTVC via segue
    var stateOfMindDesc: StateOfMindDesc!
    var wordToSave: Cause?
    var updateMode: Bool = false
    
    let adjectiveError = "Adjective was not selected."
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    @IBOutlet weak var causeTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func clearToAddNewOnPressed(_ sender: UIButton) {
        updateMode = false
        causeTextView.text = "" //"Type a new cause here."
        self.changeTitle(title: "Add New")
        self.causeTextView.isEditable = true
        
    }
 
    
    @IBAction func saveOnPressed(_ sender: Any) {
        print("why this is not working???")
        // Add a new cause
        if causeTextView.text == "" {
            print("Nothing to save here, really")
            // add a alert here
    
        } else if updateMode == true {
             //update(itemToUpdate: CauseDesc, itemName: itemToAdd!)
            // To update a change of an existing cause
            
            print("wordToSave on saveOnPressed: \(wordToSave)")
            update(itemToUpdate: wordToSave!, itemName: causeTextView.text)
            performSegue(withIdentifier: "toCauseTVCSegue", sender: self)
        } else {
            // To add a new cause
            save(itemName: causeTextView.text)
            performSegue(withIdentifier: "toCauseTVCSegue", sender: self)
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        tableView.dataSource = self
        tableView.dataSource = self

        self.navigationItem.prompt = "Your Current State of Mind: \(stateOfMindDesc.adjective ?? adjectiveError)"
        
        // To dismiss a keyboard
        causeTextView.delegate = self // as? UITextViewDelegate
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
 
        self.causeTextView.isEditable = true
        self.changeTitle(title: "Add New")
        
    }
    
    // Change Navigation Bar Item Button Title, dynamically
    func changeTitle(title: String) {
        let item = self.navigationItem.rightBarButtonItem!
        let button = item.customView as! UIButton
        //button.titleLabel?.font =
        
        button.titleLabel?.font.withSize(30)
        button.setTitle(title, for: .normal)
    }

    
    // MARK: - Clear UITextView upon Editing and Dismissing a Keyboard
    @objc func tap(sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
    }

    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cause")
        let sortDescriptorType = NSSortDescriptor(key: "causeDesc", ascending: true)
       
        fetchRequest.sortDescriptors = [sortDescriptorType]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self //as? NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    

    
    
   // let causeDescObj: NSManagedObject

    func save(itemName: String) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
       
        let entity = NSEntityDescription.entity(forEntityName: "Cause", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(itemName, forKey: "causeDesc")
        
        do {
            try managedContext.save()
            
        } catch {
            print("Failed to save an item: \(error.localizedDescription)")
        }
        updateMode = false
        causeTextView.text = ""
    }
   
/*
    func causeEditAlert(CauseDesc: Cause) {
        let alertController = UIAlertController(title: "Edit", message: "Edit the cause.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            
            let newCause = alertController.textFields![0]
            let itemToAdd = newCause.text
            
            self.update(itemToUpdate: CauseDesc, itemName: itemToAdd!)
            //self.save(itemName: itemToAdd!, itemRate: rateToAdd) // Later add no-nil validation
            
            
        })
        
        alertController.addTextField { (textField: UITextField) in
            //textField.placeholder = "Adjective"
            //saveAction.isEnabled = false
            textField.text = CauseDesc.causeDesc
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
 */
    func update(itemToUpdate: NSManagedObject, itemName: String) {
        print("update itemToUpdate: \(itemToUpdate)")
        itemToUpdate.setValue(itemName, forKey: "causeDesc")
        updateMode = false
        causeTextView.text = ""
        self.causeTextView.isEditable = true
        self.changeTitle(title: "Add New")
    }

 
//}

//extension CauseDescViewController: UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
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
        let CauseDescCell = tableView.dequeueReusableCell(withIdentifier: "CauseDescCell", for: indexPath)
        if let causeDesc = fetchedResultsController?.object(at: indexPath) as? Cause {
            CauseDescCell.textLabel?.text = causeDesc.causeDesc
            //CauseCell.detailTextLabel?.text = causeType.type as AnyObject as? String
        }
        return CauseDescCell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        //let wordToSave = self.fetchedResultsController?.object(at: indexPath) as! Cause
        wordToSave = self.fetchedResultsController?.object(at: indexPath) as? Cause
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            
            //if let wordToSave = self.fetchedResultsController?.object(at: indexPath) as? Cause {
            print("Editing: \(self.wordToSave)")
            self.causeTextView.text = self.wordToSave!.causeDesc
            
            //let causeDescToUpdate = wordToSave.causeDesc
            //self.causeEditAlert(CauseDesc: wordToSave)
            //}
            // call a function passing wordToSave
            self.updateMode = true

            self.causeTextView.isEditable = true
            self.changeTitle(title: "Update")
        
        }

        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            print("Deleting")
            managedContext?.delete(self.wordToSave!)
        //}
        
        do {
            try managedContext?.save()
        } catch {
            print("Saving Error: \(error)")
        }
        }
        
        edit.backgroundColor = UIColor.blue
        return [edit, delete]
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let appDelegate = UIApplication.shared.delegate as? AppDelegate
        //let managedContext = appDelegate?.persistentContainer.viewContext
        let wordToSave = self.fetchedResultsController?.object(at: indexPath) as! Cause
        
        print(wordToSave.causeDesc as Any)
        self.causeTextView.text = wordToSave.causeDesc
        causeTextView.isEditable = false
        changeTitle(title: "Select")
        
        
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCauseTVCSegue" {
            let destVC = segue.destination as! CauseTableViewController
            destVC.stateOfMindDesc = stateOfMindDesc
            
        }
    }
    
}

