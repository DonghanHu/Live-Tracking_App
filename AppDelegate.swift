//
//  AppDelegate.swift
//  Live-Tracking_App
//
//  Created by Donghan Hu on 10/26/23.
//

import Cocoa
import CoreData



@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // optional NSStatusItem, unwrap before use
    private var statusItem  : NSStatusItem?
    
    let popover = NSPopover()
    private var monitor: Any?

    // Refernce to managed object context
    var context : NSManagedObjectContext?
    
    var items:[FTApplication] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        
        // user UserDefault to set staring hour and minute for tracking session
        let defaults = UserDefaults.standard
        let startHour = "startHourKey"
        let startMinute = "startMinuteKey"
        
        
        
        //unwrap statusItem, same for the following codes
        if let button = statusItem?.button {
            // changed later for a dynamic displaying
            button.title = "Live Tracking"
            button.action = #selector(togglePopover(_:))
        }
        
        popover.contentViewController = PopMenuViewController.initController()
        popover.behavior = NSPopover.Behavior.transient;
        
        // typeof: NSManagedObjectContext
        context = self.persistentContainer.viewContext
        
        fetchApplicationTracking()
        
        
        
        // read applescript csv file to a global dictionary
        let readCSVFileHander = readCSVFile()
        readCSVFileHander.readCSVFileToGlobalDicrionary(fileName : "applescript")
        
    }
    
    func fetchApplicationTracking(){
        //context.fetch()
        do{
            let fetchRequest: NSFetchRequest<FTApplication> = FTApplication.fetchRequest()
            let dateObject = DateFormatting()
            let todayDate = dateObject.getTodayDateFormatString()
            let datePredicate = NSPredicate(format: "date == %@", todayDate)
            fetchRequest.predicate = datePredicate
            try items = (context?.fetch(fetchRequest))!
            
            // fetch data from core data, based on today's date, and this is a temporary array for daily usage
            dailyApplicationDictionary = items
            
            // print out each item in the fetched data
//            for item in items {
//                print(item)
//            }
            //
        }
        catch {
            print(error)
        }
        
    }
    
    func printAppName(){
        print(statusItem!.button!.title)
    }
    
    // function: change appliaction title 
    func changeAppTitle(appName: String){
        print("this is changeAppTitle function")
        statusItem!.button!.title = appName
        print(statusItem!.button!.title)
    }
    
    @objc func togglePopover(_ sender: Any?) {
          if popover.isShown {
            closePopover(sender: sender)
            if monitor != nil {
                NSEvent.removeMonitor(monitor!)
            }
            monitor = nil
          } else {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown,.rightMouseDown] ){ [weak self] event in
                if let strongSelf = self, strongSelf.popover.isShown {
                  strongSelf.closePopover(sender: event)
                }
            }
            showPopover(sender: sender)
          }
        }


    func showPopover(sender: Any?) {
        if let button = statusItem?.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Live_Tracking_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
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
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

