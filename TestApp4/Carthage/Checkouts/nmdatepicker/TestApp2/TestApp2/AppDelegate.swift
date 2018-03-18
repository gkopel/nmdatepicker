//
//  AppDelegate.swift
//  TestApp2
//
//  Created by Greg Kopel on 11.01.2015.
//  Copyright (c) 2015 Netmedia. All rights reserved.
//

import Cocoa

@NSApplicationMain


class AppDelegate: NSObject, NSApplicationDelegate, NMDatePickerDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var datePicker: NMDatePicker!


    func applicationDidFinishLaunching(_ aNotification: Notification)  {
        let now = Date()
        updateDateLabel(date: now)
        
        self.datePicker.dateValue = now as Date
        self.datePicker.delegate = self
        
        // NMDatePicker appearance properties
        datePicker.backgroundColor = NSColor.white
        datePicker.font = NSFont.systemFont(ofSize: 13.0)
        datePicker.titleFont = NSFont.boldSystemFont(ofSize: 14.0)
        datePicker.textColor = NSColor.black
        datePicker.todayTextColor = NSColor.blue
        datePicker.selectedTextColor = NSColor.white
        datePicker.todayBackgroundColor = NSColor.blue
        datePicker.todayBorderColor = NSColor.blue
        datePicker.highlightedBackgroundColor = NSColor.lightGray
        datePicker.highlightedBorderColor = NSColor.darkGray
        datePicker.selectedBackgroundColor = NSColor.orange
        datePicker.selectedBorderColor = NSColor.blue
        
    }
    
    @IBAction func showTodayAction(sender: AnyObject) {
        self.datePicker.displayViewForDate(NSDate() as Date)
    }
    
    class func shortDateForDate(date: Date) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
       // return dateFormatter.string(from: date as Date) as (Date)
        return dateFormatter.string(from: date) as NSString
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func updateDateLabel(date: Date) {
        self.label.stringValue = "\(AppDelegate.shortDateForDate(date: date))"
    }
    
    // MARK: - NMDatePicker delegate

    func nmDatePicker(_ datePicker: NMDatePicker, selectedDate: Date) {
        updateDateLabel(date: selectedDate)
    }


}

