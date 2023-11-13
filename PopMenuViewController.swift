//
//  PopMenuViewController.swift
//  Live-Tracking_App
//
//  Created by Donghan Hu on 10/26/23.
//

import Cocoa
import AppKit
import Foundation
import SwiftUI



class PopMenuViewController: NSViewController {
    
    private var quitButton : NSButton!
    private var startButton : NSButton!
    private var confirmButton: NSButton!
    
    private var topFiveLabel : NSTextField!
    
    private var topFiveLabels = [NSTextField]()
    
    private var topFive1Label : NSTextField!
    private var topFive2Label : NSTextField!
    private var topFive3Label : NSTextField!
    private var topFive4Label : NSTextField!
    private var topFive5Label : NSTextField!
    
    private var descriptionLabe : NSTextField!
    
    private var detectingFrontMostAppTimer = Timer()
    private var timeIntervalForDetecing = 1.0
    
    
    private var refreshTopFiveTrackingTimeTimer = Timer()
    private var timeIntervalForRefeshing = 1.0
    
    private var timePickerHour : NSStepper!
    private var timePickerMinute : NSStepper!
    
    private var minuteSetting: NSTextField!
    private var hourSetting: NSTextField!
    
    private var frontMostApplicationName = ""
    
    // for saving top five
    var items:[FTApplication] = []
    
    // not used, delegate is a second(new) instance of AppDelegate class?
    // dalegate.statusItem is nil
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do view setup here.
        
        // NSTextFiled for setting hour
        hourSetting = NSTextField(frame: NSRect(x: self.view.frame.origin.x+50, y: self.view.frame.origin.x+200, width: 50, height: 20))
        hourSetting.stringValue = "hour"
        hourSetting.isEditable = false
        // self.view.addSubview(hourSetting)
        
        // NSTextFiedl for setting minute
        minuteSetting = NSTextField(frame: NSRect(x: self.view.frame.origin.x+50, y: self.view.frame.origin.x+150, width: 50, height: 20))
        minuteSetting.stringValue = "minute"
        minuteSetting.isEditable = false
        // self.view.addSubview(minuteSetting)
        
        
        // stepper for setting tracking start time point: Hour
        timePickerHour = NSStepper(frame: NSRect(x: self.view.frame.origin.x+200, y: self.view.frame.origin.x+150, width: 120, height: 30))
        timePickerHour.minValue = 0
        timePickerHour.maxValue = 23
        timePickerHour.increment = 1
        // initial values
        timePickerHour.intValue = 8
        hourSetting.stringValue = String(timePickerHour.intValue)
        // self.view.addSubview(timePickerHour)
        
        // Hour: Create a binding between the stepper's value and the text field's value
        let bindingOptionsHour: [NSBindingOption : Any] = [:]
        hourSetting.bind(NSBindingName.value, to: timePickerHour, withKeyPath: "intValue", options: bindingOptionsHour)

        timePickerHour.target = self
        timePickerHour.action = #selector(hourStepperValueChanged)
        
        // stepper for setting tracking start time point: Minute
        timePickerMinute = NSStepper(frame: NSRect(x: self.view.frame.origin.x+300, y: self.view.frame.origin.x+150, width: 120, height: 30))
        timePickerMinute.minValue = 0
        timePickerMinute.maxValue = 59
        timePickerHour.increment = 1
        timePickerMinute.intValue = 0
        minuteSetting.stringValue = String(timePickerMinute.intValue)
        // self.view.addSubview(timePickerMinute)
        
        // Minute: Create a binding between the stepper's value and the text field's value
        let bindingOptionsMinute: [NSBindingOption : Any] = [:]
        minuteSetting.bind(NSBindingName.value, to: timePickerMinute, withKeyPath: "intValue", options: bindingOptionsMinute)
        
        timePickerMinute.target = self
        timePickerMinute.action = #selector(minuteStepperValueChanged)
        
        
        // button to set start time point
        confirmButton = NSButton(frame: NSRect(x: self.view.frame.origin.x+50, y: self.view.frame.origin.x+90, width: 120, height: 30))
        confirmButton.target = self
        confirmButton.title = "Confirm"
        confirmButton.bezelStyle = .rounded
        confirmButton.isBordered = true
        confirmButton.setButtonType(.momentaryPushIn)
        // self.view.addSubview(confirmButton)
        
        
        
        
        
        
        
        // button: start tracking button
        startButton = NSButton(frame: NSRect(x: self.view.frame.origin.x+35, y: self.view.frame.origin.y+40, width: 140, height: 30))
        startButton.target = self
        startButton.title = "Start"
        startButton.action = #selector(self.trackingAction)
        startButton.bezelStyle = .rounded
        startButton.isBordered = true
        //startButton.bezelColor = .blue
        startButton.setButtonType(.momentaryPushIn)
        self.view.addSubview(startButton)
        
        
        // button: quit the application
        quitButton = NSButton(frame: NSRect(x: self.view.frame.origin.x+35, y: self.view.frame.origin.y+10, width: 140, height: 30))
        quitButton.target = self;
        quitButton.title = "Quit"
        quitButton.bezelStyle = .rounded
        quitButton.isBordered = true
        quitButton.setButtonType(.momentaryPushIn)
        quitButton.action = #selector(self.quitApplication)
        self.view.addSubview(quitButton)
        
        
        
        
        // label
        topFiveLabel = NSTextField(frame: NSRect(x: self.view.frame.origin.x+15, y: self.view.frame.origin.y+230, width: 150, height: 20))
        topFiveLabel.isEditable = false
        self.view.addSubview(topFiveLabel)
        
        
        
        topFive1Label = NSTextField(frame: NSRect(x: self.view.frame.origin.x+15, y: self.view.frame.origin.y+200, width: 150, height: 20))
        topFive1Label.isBezeled = true
        self.view.addSubview(topFive1Label)
        topFive1Label.isEditable = false
        topFive2Label = NSTextField(frame: NSRect(x: self.view.frame.origin.x+15, y: self.view.frame.origin.y+170, width: 150, height: 20))
        self.view.addSubview(topFive2Label)
        topFive2Label.isEditable = false
        topFive3Label = NSTextField(frame: NSRect(x: self.view.frame.origin.x+15, y: self.view.frame.origin.y+140, width: 150, height: 20))
        self.view.addSubview(topFive3Label)
        topFive3Label.isEditable = false
        topFive4Label = NSTextField(frame: NSRect(x: self.view.frame.origin.x+15, y: self.view.frame.origin.y+110, width: 150, height: 20))
        self.view.addSubview(topFive4Label)
        topFive4Label.isEditable = false
        topFive5Label = NSTextField(frame: NSRect(x: self.view.frame.origin.x+15, y: self.view.frame.origin.y+80, width: 150, height: 20))
        self.view.addSubview(topFive5Label)
        topFive5Label.isEditable = false
        
        topFiveLabels.append(topFive1Label)
        topFiveLabels.append(topFive2Label)
        topFiveLabels.append(topFive3Label)
        topFiveLabels.append(topFive4Label)
        topFiveLabels.append(topFive5Label)
        
        
        // timer to refresh
        refreshTopFiveTrackingTimeTimer = Timer.scheduledTimer(timeInterval: timeIntervalForRefeshing, target: self, selector: #selector(fetchAndSortByTrackingTime), userInfo: nil, repeats: true)
        
    }
    
    // change Hour setting
    @objc func hourStepperValueChanged(_ sender: NSStepper) {
        hourSetting.stringValue = String(sender.intValue)
    }
    
    // change Minute setting
    @objc func minuteStepperValueChanged(_ sender: NSStepper) {
        minuteSetting.stringValue = String(sender.intValue)
    }
    
    // action: click button to start/pause tracking
    @objc func trackingAction() {
        if(startButton.title == "Start"){
            
            // get application list from the core data
            
            // print("this is daily application array")
            // global variable that can be accessed
            // print(dailyApplicationDictionary)
            
            
            // create a timer for monitoring the fronmost applciation
            detectingFrontMostAppTimer = Timer.scheduledTimer(timeInterval: timeIntervalForDetecing, target: self, selector: #selector(obtainFrontMostApplication), userInfo: nil, repeats: true)
            
            
            
            
            startButton.title = "Pause"
        } else {
            startButton.title = "Start"
            // pause the timer
            detectingFrontMostAppTimer.invalidate()
            print("current timer status: ", detectingFrontMostAppTimer.isValid)
            DispatchQueue.main.async(execute: {
                let appDele = NSApplication.shared.delegate as! AppDelegate
                appDele.changeAppTitle(appName: "Live Tracking")
              })
            
            // save unsaved data
            let coreDataContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            for ftapp in dailyApplicationDictionary{
                do {
                    try coreDataContext.save()
                    print("save successfully")
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
    @objc func fetchAndSortByTrackingTime(){
        //context.fetch()
        do{
            let coreDataContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<FTApplication> = FTApplication.fetchRequest()
            let dateObject = DateFormatting()
            let todayDate = dateObject.getTodayDateFormatString()
            let datePredicate = NSPredicate(format: "date == %@", todayDate)
            fetchRequest.predicate = datePredicate
            // decreasing order
            let sort = NSSortDescriptor(key: #keyPath(FTApplication.trackingTime), ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                    items = try coreDataContext.fetch(fetchRequest)
                    topFiveApplicationTracking = items
                let appCount = topFiveApplicationTracking.count
//                for item in items {
//                    print(item.domainName)
//                }
                // print(topFiveApplicationTracking)
                self.topFiveLabel.stringValue = "Today tracked apps: " + String(appCount)
                if(appCount >= 5){
                    topFive1Label.stringValue = (topFiveApplicationTracking[0].domainName ?? "Unknown App") + ": " +  String(topFiveApplicationTracking[0].trackingTime)

                    topFive2Label.stringValue = (topFiveApplicationTracking[1].domainName ?? "Unknown App") + ": " + String(topFiveApplicationTracking[1].trackingTime)
                    topFive3Label.stringValue = (topFiveApplicationTracking[2].domainName ?? "Unknown App") + ": " +  String(topFiveApplicationTracking[2].trackingTime)
                    topFive4Label.stringValue = (topFiveApplicationTracking[3].domainName ?? "Unknown App") + ": " +  String(topFiveApplicationTracking[3].trackingTime)
                    topFive5Label.stringValue = (topFiveApplicationTracking[4].domainName ?? "Unknown App") + ": " + String(topFiveApplicationTracking[4].trackingTime)
                } else {
                    // appCount < 5
                    for i in 0..<appCount {
                        
                        topFiveLabels[i].stringValue = (topFiveApplicationTracking[i].domainName ?? "Unknown App") + " " + String(topFiveApplicationTracking[i].trackingTime)
                    }
                            

                }
                
                //print("the cound of applicationtracking array: ", topFiveApplicationTracking.count)
                } catch {
                    print("Cannot fetch Expenses")
                }
            // fetch data from core data, based on today's date, and this is a temporary array for daily usage
            topFiveApplicationTracking = items
        }
        catch {
            print(error)
        }

    }
    
    
    @objc func obtainFrontMostApplication(){
        
        let appDele = NSApplication.shared.delegate as! AppDelegate
        let CurrentFrontMostAppName = NSWorkspace.shared.frontmostApplication?.localizedName?.description
        // appDele.changeAppTitle(appName: CurrentFrontMostAppName!)
        
        
        
        var domainName = CurrentFrontMostAppName
        
        if(!appleScriptDicrionary.keys.contains(CurrentFrontMostAppName ?? "Unknown Appliction Name")){
            // check if we have appleScript for this application
            // if not, then
            print("applescript dictionary does not have this application name")
        } else {
            print("Current Front most app name: is ", CurrentFrontMostAppName)
            let metadataHandler = metaData()
            let resultFirst = metadataHandler.getMetaDataInfor1(appName: CurrentFrontMostAppName!)
            // print(result)
            let resultSecond = metadataHandler.getMetaDataInfor2(appName: CurrentFrontMostAppName!)
             
            if (CurrentFrontMostAppName == "Google Chrome" || CurrentFrontMostAppName == "Safari"){
                //print("metadata 1: ", resultFirst)
                var urlString = resultFirst
                var url = URL(string: urlString)
                var domain = url?.host ?? "invalide domain name"
                domain = domain.replacingOccurrences(of: "^www.", with: "", options: .regularExpression)
                var components = domain.components(separatedBy: ".")
                components.removeLast()
                domain = components.joined(separator: ".")
                print("this is domain: ", domain)
                domainName = domain
                // print(domain)
            } else {
                
            }
        }

        
        let result = isApplicationExist(appArray: dailyApplicationDictionary, frontMostApplicationName: domainName!)
        
        if (result){
            // do nothing
            print("Do have this frontmost application in the dailyapplicationdictionary")
            
        } else {
            print("doesn't have this frontmost application in the dailyapplicationdictionary")
            // create a new one entity or dailyApplication?
            // Access the managed object context (you can modify this based on your project setup)
            let coreDataContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newApplication = FTApplication(context: coreDataContext)
            let dateObject = DateFormatting()
            newApplication.date = dateObject.getTodayDateFormatString()
            newApplication.applicationName = CurrentFrontMostAppName
            newApplication.metadataInfor1 = "metadata1"
            newApplication.metadataInfor2 = "metadata2"
            newApplication.category = "categoryInfor"
            newApplication.domainName = domainName
            // initial value
            newApplication.trackingTime = 0
            
            // append to the dailyApplicationDictionary
            dailyApplicationDictionary.append(newApplication)
            
            // save to the core data?
//            do {
//                try coreDataContext.save()
//                print("create new entity and save successfully")
//            } catch {
//                print(error)
//            }
            
        }
        
        
        // print("new dailyapplicationDictionary: ", dailyApplicationDictionary)
        // update for each execuation of this function
        let updatedTime = updateTrackingTime(appArray: dailyApplicationDictionary, frontMostApplicationName: domainName!)
        
        let dynoAppNameString = domainName! + " " + intToTime(trackingTime: updatedTime)
        appDele.changeAppTitle(appName: dynoAppNameString)
        
        
        
// can be put into a async queue for the following opearations
//        DispatchQueue.main.async(execute: {
//            let appDele = NSApplication.shared.delegate as! AppDelegate
//            let CurrentFrontMostAppName = NSWorkspace.shared.frontmostApplication?.localizedName?.description
//            appDele.changeAppTitle(appName: CurrentFrontMostAppName!)
//          })
        
        
        
        // let pairs: KeyValuePairs = ["john": 1,"ben": 2,"bob": 3,"hans": 4]
        // print(pairs.first!)
    }
    
    
    func intToTime(trackingTime : Int) -> String {
        let hour = trackingTime / 3600
        let minute = trackingTime / 60
        let second = trackingTime % 60
        let result = String(hour) + ":" + String(minute) + ":" + String(second)
        return result
    }
    
    func updateTrackingTime(appArray : [FTApplication], frontMostApplicationName: String) -> Int {
        for app in appArray {
            let appName = app.domainName
            if (appName == frontMostApplicationName){
                app.trackingTime = app.trackingTime + 1
                return Int(app.trackingTime)
            }
        }
        return -1
    }
    
    // check if we have this applicaiton entity in the application dictionary
    func isApplicationExist(appArray : [FTApplication], frontMostApplicationName: String) -> Bool {
        for app in appArray {
            let appName = app.domainName
            if (appName == frontMostApplicationName){
                return true
            }
        }
        return false;
    }
    
    @objc func quitApplication() {
        
        let coreDataContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        for ftapp in dailyApplicationDictionary{
            do {
                try coreDataContext.save()
                print("save successfully")
            } catch {
                print(error)
            }
        }
        
        // stop the timer
        refreshTopFiveTrackingTimeTimer.invalidate()
        exit(0);
    }
    
}

extension PopMenuViewController {
    static func initController() -> PopMenuViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name( "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("PopMenuViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PopMenuViewController else {
            fatalError("Cannot find PopMenuViewController")
        }
        return viewcontroller
    }
}
