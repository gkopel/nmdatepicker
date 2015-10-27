//
//  AppDelegate.swift
//  TestApp1
//
//  Created by Greg Kopel on 10.01.2015.
//  Copyright (c) 2015 Netmedia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NMDatePickerDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label: NSTextField!
    weak var datePicker: NMDatePicker!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let contentView = self.window.contentView
        let date = NSDate()
        let frame = CGRectMake(20, 38, 256, 280)
        
        let datePicker = NMDatePicker(frame: frame, dateValue: date)
        self.datePicker = datePicker
        datePicker.delegate = self
        datePicker.autoresizingMask = NSAutoresizingMaskOptions.ViewMinYMargin
        
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
        
        contentView!.addSubview(datePicker)
        
        
        updateDateLabel(date)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func showTodayAction(sender: AnyObject) {
        self.datePicker.displayViewForDate(NSDate())
    }
    
    class func shortDateForDate(date: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.stringFromDate(date)
    }
    
    
    func updateDateLabel(date: NSDate) {
        self.label.stringValue = "\(AppDelegate.shortDateForDate(date))"
    }

    
    // MARK: - NMDatePicker delegate
    
    
    func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate) {
        updateDateLabel(selectedDate)
    }
    
    func nmDatePicker(datePicker: NMDatePicker, newSize: NSSize) {
        var frame = self.datePicker.frame
        frame.origin.y += frame.size.height - newSize.height
        frame.size.height = newSize.height
        self.datePicker.frame = frame
    }
    
}

