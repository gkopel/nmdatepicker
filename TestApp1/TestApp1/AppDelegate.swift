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
    @IBOutlet weak var dateMarker: NSDatePicker!
    weak var datePicker: NMDatePicker!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let contentView = self.window.contentView
        let date = NSDate()
        let frame = CGRectMake(20, 38, 256, 280)
        
        let datePicker = NMDatePicker(frame: frame, dateValue: date)
        self.datePicker = datePicker
        datePicker.delegate = self
        datePicker.autoresizingMask = NSAutoresizingMaskOptions.ViewMinYMargin
        
        // Background color, font size
        datePicker.backgroundColor = NSColor.whiteColor()
        datePicker.font = NSFont.systemFontOfSize(13.0)
        datePicker.titleFont = NSFont.boldSystemFontOfSize(14.0)
        
        
        // Text color
        datePicker.textColor = NSColor.blackColor()
        datePicker.todayTextColor = NSColor.redColor()
        datePicker.selectedTextColor = NSColor.whiteColor()
        
        // Markers
        datePicker.markColor = NSColor.darkGrayColor()
        datePicker.todayMarkColor = NSColor.redColor()
        datePicker.selectedMarkColor = NSColor.whiteColor()
        
        // Today
        datePicker.todayBackgroundColor = NSColor.redColor()
        datePicker.todayBorderColor = NSColor.redColor()
        
        // Selection
        datePicker.selectedBackgroundColor = NSColor.lightGrayColor()
        datePicker.selectedBorderColor = NSColor.lightGrayColor()
        
        // Next & previous month days
        datePicker.nextMonthTextColor = NSColor.grayColor()
        datePicker.previousMonthTextColor = NSColor.grayColor();
        
        
        
        
        
        // 'Mouse-over' highlight
        datePicker.highlightedBackgroundColor = NSColor(white: 0.95, alpha: 1.0)
        datePicker.highlightedBorderColor = NSColor(white: 0.95, alpha: 1.0)
        
        
        
        contentView!.addSubview(datePicker)
        
        
        dateMarker.dateValue = date.dateByAddingTimeInterval(60*60*24)
        updateDateLabel(date)
        
        
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func showTodayAction(sender: AnyObject) {
        self.datePicker.displayViewForDate(NSDate())
    }
    
    
    @IBAction func markDateAction(sender: AnyObject) {
        self.datePicker.markDate(self.dateMarker.dateValue)
    }
    
    @IBAction func unmarkDateAction(sender: AnyObject) {
        self.datePicker.unmarkDate(self.dateMarker.dateValue)
    }
    
    @IBAction func unmarkAllAction(sender: AnyObject) {
        self.datePicker.unmarkAllDates()
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

