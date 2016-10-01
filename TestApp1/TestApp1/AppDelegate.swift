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
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = self.window.contentView
        let date = Date()
        let frame = CGRect(x: 20, y: 38, width: 256, height: 280)
        
        let datePicker = NMDatePicker(frame: frame, dateValue: date)
        self.datePicker = datePicker
        datePicker.delegate = self
        datePicker.autoresizingMask = NSAutoresizingMaskOptions.viewMinYMargin
        
        // Background color, font size
        datePicker.backgroundColor = NSColor.white
        datePicker.font = NSFont.systemFont(ofSize: 13.0)
        datePicker.titleFont = NSFont.boldSystemFont(ofSize: 14.0)
        
        
        // Text color
        datePicker.textColor = NSColor.black
        datePicker.todayTextColor = NSColor.red
        datePicker.selectedTextColor = NSColor.white
        
        // Markers
        datePicker.markColor = NSColor.darkGray
        datePicker.todayMarkColor = NSColor.red
        datePicker.selectedMarkColor = NSColor.white
        
        // Today
        datePicker.todayBackgroundColor = NSColor.red
        datePicker.todayBorderColor = NSColor.red
        
        // Selection
        datePicker.selectedBackgroundColor = NSColor.lightGray
        datePicker.selectedBorderColor = NSColor.lightGray
        
        // Next & previous month days
        datePicker.nextMonthTextColor = NSColor.gray
        datePicker.previousMonthTextColor = NSColor.gray;
        
        
        
        
        
        // 'Mouse-over' highlight
        datePicker.highlightedBackgroundColor = NSColor(white: 0.95, alpha: 1.0)
        datePicker.highlightedBorderColor = NSColor(white: 0.95, alpha: 1.0)
        
        
        
        contentView!.addSubview(datePicker)
        
        
        dateMarker.dateValue = date.addingTimeInterval(60*60*24)
        updateDateLabel(date)
        
        
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func showTodayAction(_ sender: AnyObject) {
        self.datePicker.displayViewForDate(Date())
    }
    
    
    @IBAction func markDateAction(_ sender: AnyObject) {
        self.datePicker.markDate(self.dateMarker.dateValue)
    }
    
    @IBAction func unmarkDateAction(_ sender: AnyObject) {
        self.datePicker.unmarkDate(self.dateMarker.dateValue)
    }
    
    @IBAction func unmarkAllAction(_ sender: AnyObject) {
        self.datePicker.unmarkAllDates()
    }
    
    class func shortDateForDate(_ date: Date) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date) as NSString
    }
    
    
    func updateDateLabel(_ date: Date) {
        self.label.stringValue = "\(AppDelegate.shortDateForDate(date))"
    }

    
    // MARK: - NMDatePicker delegate
    
    
    func nmDatePicker(_ datePicker: NMDatePicker, selectedDate: Date) {
        updateDateLabel(selectedDate)
    }
    
    func nmDatePicker(_ datePicker: NMDatePicker, newSize: NSSize) {
        var frame = self.datePicker.frame
        frame.origin.y += frame.size.height - newSize.height
        frame.size.height = newSize.height
        self.datePicker.frame = frame
    }
    
}

