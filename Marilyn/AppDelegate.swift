//
//  AppDelegate.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 4/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        preloadData()
        return true
    }
    
    private func preloadData()
    {
        
        let preloadedDataKey = "didPreloadData"
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: preloadedDataKey) == false
        {
            // Preload
            
            let dataFile = ["CauseDesc", "CauseType", "Location", "StateOfMindDesc"]
            
            for file in dataFile
            {
                
                guard let urlPath = Bundle.main.url(forResource: file, withExtension: "plist") else
                {
                    return
                }
                
                // Import data in background thread
                let backgroundContext = persistentContainer.newBackgroundContext()
                
                // non-parent-child separate cotext from backgroundContext
                // context associated with main que, make persistentContainer to be aware of any change
                persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
                backgroundContext.perform {
                    do {
                        switch file {
                        case "CauseDesc":
                            if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                                for item in arrayContents {
                                    let dataObject = Cause(context: backgroundContext)
                                    dataObject.causeDesc = item
                                }
                            }
                        case "CauseType":
                            if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                                for item in arrayContents {
                                    let dataObject = CauseType(context: backgroundContext)
                                    dataObject.type = item
                                }
                            }
                        case "Location":
                            if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                                for item in arrayContents {
                                    let dataObject = Location(context: backgroundContext)
                                    dataObject.location = item
                                }
                            }
                        case "StateOfMindDesc":
                            if let dictContents = NSDictionary(contentsOf: urlPath) as? ([String : AnyObject]){
                                for (itemA, itemB) in dictContents {
                                    let dataObject = StateOfMindDesc(context: backgroundContext)
                                    dataObject.adjective = itemA
                                    dataObject.rate = itemB as! Int16
                                }
                            }
                        default:
                            print("default")
                        }
                        
                        try backgroundContext.save()
                        userDefaults.setValue(true, forKey: preloadedDataKey)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
            
        } else {
            print("Data has already been imported.")
        }
        
    }
                
                
                /*
                 backgroundContext.perform {
                 if let arrayContents = NSArray(contentsOf: urlPath) as? [String] {
                 
                 do {
                 
                 for item in arrayContents {
                 //print(item)
                 
                 switch file {
                 case "CauseType":
                 let dataObject = CauseType(context: backgroundContext)
                 dataObject.type = item
                 
                 case "Location":
                 let dataObject = Location(context: backgroundContext)
                 dataObject.location = item
                 
                 /* case "StateOfMindDesc":
                 let dataObject = StateOfMindDesc(context: backgroundContext)
                 dataObject.adjective = item
                 //dataObject.rate = item
                 */
                 default:
                 break
                 }
                 
                 }
                 
                 try backgroundContext.save()
                 
                 userDefaults.setValue(true, forKey: preloadedDataKey)
                 
                 } catch {
                 print(error.localizedDescription)
                 }
                 }
                 }
                 
                 
                 }
                 }
                 }
                 */
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Marilyn")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

