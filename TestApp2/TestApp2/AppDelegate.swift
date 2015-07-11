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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let now = NSDate()
        updateDateLabel(now)
        
        self.datePicker.dateValue = now
        self.datePicker.delegate = self
        
        // NMDatePicker appearance properties
        datePicker.backgroundColor = NSColor.whiteColor()
        datePicker.font = NSFont.systemFontOfSize(13.0)
        datePicker.titleFont = NSFont.boldSystemFontOfSize(14.0)
        datePicker.textColor = NSColor.blackColor()
        datePicker.selectedTextColor = NSColor.whiteColor()
        datePicker.todayBackgroundColor = NSColor.whiteColor()
        datePicker.todayBorderColor = NSColor.blueColor()
        datePicker.highlightedBackgroundColor = NSColor.lightGrayColor()
        datePicker.highlightedBorderColor = NSColor.darkGrayColor()
        datePicker.selectedBackgroundColor = NSColor.orangeColor()
        datePicker.selectedBorderColor = NSColor.blueColor()
        
        
    }
    
    @IBAction func showTodayAction(sender: AnyObject) {
        self.datePicker.displayViewForDate(NSDate())
    }
    
    class func shortDateForDate(date: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.stringFromDate(date)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func updateDateLabel(date: NSDate) {
        self.label.stringValue = "\(AppDelegate.shortDateForDate(date))"
    }
    
    // MARK: - NMDatePicker delegate

    func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate) {
        updateDateLabel(selectedDate)
    }


}

