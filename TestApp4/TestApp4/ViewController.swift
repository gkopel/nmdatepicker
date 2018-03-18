//
//  ViewController.swift
//  TestApp4
//
//  Created by Grzegorz Kopel on 18.03.2018.
//  Copyright © 2018 Grzegorz Kopel. All rights reserved.
//

import Cocoa
import NMDatePicker

class ViewController: NSViewController, NMDatePickerDelegate {
    
    @IBOutlet weak var datePicker: NMDatePicker!
    @IBOutlet weak var label: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let now = Date()
        updateDateLabel(date: now)
        
        self.datePicker.dateValue = now
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
    
    
    func updateDateLabel(date: Date) {
        self.label.stringValue = "\(shortDateForDate(date: date))"
    }

    

    
    func shortDateForDate(date: Date) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // return dateFormatter.string(from: date as Date) as (Date)
        return dateFormatter.string(from: date) as NSString
    }
    
    @IBAction func showTodayAction(sender: AnyObject) {
        self.datePicker.displayViewForDate(NSDate() as Date)
    }
    
    
    // MARK: - NMDatePicker delegate
    
    func nmDatePicker(_ datePicker: NMDatePicker, selectedDate: Date) {
        updateDateLabel(date: selectedDate)
    }

}

