//
//  NMDatePicker.swift
//
//  Created by Greg Kopel on 13.12.2014.
//  Copyright (c) 2014-15 Netmedia. All rights reserved.
//

import Cocoa

@objc public protocol NMDatePickerDelegate {
    /// This method notifies about the date selected in the date picker. (Required)
    func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate)
    
    /// Optional method that allows to adjust date picker height
    /// when the number of rows is changing between months.
    optional func nmDatePicker(datePicker: NMDatePicker, newSize: NSSize)
}

/// Custom date picker view.
public class NMDatePicker: NSView {
    
    
    // MARK: - Initializers
    public init(frame: NSRect, dateValue: NSDate) {
        self.dateValue = dateValue
        self.currentMonthLabel = NSTextField(frame: NSZeroRect)
        self.monthBackButton = NSButton(frame: NSZeroRect)
        self.monthForwardButton = NSButton(frame: NSZeroRect)
        self.currentHeight = 0
        self.font = NSFont.systemFontOfSize(12.0)
        self.titleFont = NSFont.boldSystemFontOfSize(12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        self.markedDates = [NSDate: [String: NSColor]]()
        super.init(frame: frame)
        configurePicker()
    }
    
    public required init?(coder: NSCoder) {
        self.dateValue = NSDate()
        self.currentMonthLabel = NSTextField(frame: NSZeroRect)
        self.monthBackButton = NSButton(frame: NSZeroRect)
        self.monthForwardButton = NSButton(frame: NSZeroRect)
        self.currentHeight = 0
        self.font = NSFont.systemFontOfSize(12.0)
        self.titleFont = NSFont.boldSystemFontOfSize(12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        self.markedDates = [NSDate: [String: NSColor]]()
        super.init(coder: coder)
        configurePicker()
    }

    
    func configurePicker() {
        self.calendar.firstWeekday = self.firstDayOfWeek
        self.firstDayComponents = self.firstDayOfMonthForDate(dateValue)
        configureDateFormatter()
        configureWeekdays()
        configureViewAppearance()
        doLayout()
    }
    
    // MARK: - Public properties
    public var delegate: NMDatePickerDelegate?
    public var dateValue: NSDate
    public let firstDayOfWeek = 2 // '1' - Sunday, '2' - Monday
    public var backgroundColor: NSColor? {
        didSet {
            self.setNeedsDisplayInRect(self.bounds)
        }
    }
    public var titleFont: NSFont {
        didSet {
            configureViewAppearance()
        }
    }
    public var font: NSFont {
        didSet {
            self.lineHeight = NMDatePicker.lineHeightForFont(font)
            configureViewAppearance()
        }
    }
    public var textColor: NSColor? {
        didSet {
            configureViewAppearance()
        }
    }
    public var selectedTextColor: NSColor? {
        didSet {
            configureViewAppearance()
        }
    }
    public var selectedBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    public var selectedBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    public var highlightedBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    public var highlightedBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    public var todayBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    public var todayBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    
    // MARK: - public methods
    
    
    public func markDate(date: NSDate, backgroundColor: NSColor, borderColor: NSColor, textColor: NSColor) {
        let markedDate = ["backgroundColor": backgroundColor, "borderColor": borderColor, "textColor": textColor]
        self.markedDates[date] = markedDate
        updateDaysView()
    }
    
    public func unmarkDate(date: NSDate) {
        self.markedDates[date] = nil
        updateDaysView()
    }
    
    public func unmarkAllDates() {
        self.markedDates.removeAll()
        updateDaysView()
    }
    
    
    
    // MARK: - Private properties
    private let calendar = NSCalendar.currentCalendar()
    private let dateUnitMask: NSCalendarUnit =  [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday]
    private let dateTimeUnitMask: NSCalendarUnit =  [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Weekday]
    private var firstDayComponents: NSDateComponents!
    
    override public var flipped: Bool { return true }

    private(set) public var currentMonthLabel: NSTextField!
    private(set) public var monthBackButton: NSButton!
    private(set) public var monthForwardButton: NSButton!

    private var weekdays: [String] = []
    private var weekdayLabels: [NSTextField] = []
    private var days: [NMDatePickerDayView] = []
    private var currentHeight: Int
    private var lineHeight: CGFloat
    private var dateFormatter: NSDateFormatter?
    private var markedDates: [ NSDate: [ String: NSColor ] ]

    
    
    // MARK: - Layout

    override public func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if let color = self.backgroundColor {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        
    }
    
    public func monthForwardAction(sender: NSButton) {
        self.firstDayComponents = oneMonthLaterDayForDay(self.firstDayComponents)
        updateCurrentMonthLabel()
        updateDaysView()
        
    }
    
    public func monthBackAction(sender: NSButton) {
        self.firstDayComponents = oneMonthEarlierDayForDay(self.firstDayComponents)
        updateCurrentMonthLabel()
        updateDaysView()
    }
    
    public func displayViewForDate(date: NSDate) {
        self.firstDayComponents = firstDayOfMonthForDate(date)
        self.dateValue = date
        updateCurrentMonthLabel()
        updateDaysView()
        if let delegate = self.delegate {
            delegate.nmDatePicker(self, selectedDate: self.dateValue)
        }
        
    }
    
    func doLayout() {
        let margin: CGFloat = 40
        self.currentMonthLabel.frame = NSMakeRect(margin, 10, self.bounds.size.width - 2*margin, 30)
        self.monthBackButton.frame = NSMakeRect(0, 0, 38, 39)
        self.monthForwardButton.frame = NSMakeRect(self.bounds.size.width - 38, 0, 38, 39)
        
        // weekday labels
        let labelWidth = floor(self.bounds.size.width / 7)
        var currentX = CGFloat(0.0)
        let currentY = NSMaxY(self.currentMonthLabel.frame) + 10.0
        for weekdayLabel in self.weekdayLabels {
            weekdayLabel.frame = NSMakeRect(currentX, currentY, labelWidth, self.lineHeight)
            
            if weekdayLabel.frame.size.height > self.lineHeight {
                self.lineHeight = weekdayLabel.frame.size.height
            }
            currentX += labelWidth
        }
        
        
        // day views
        let dayViewWidth: Int = Int(labelWidth)
        let dayViewHeight: Int = dayViewWidth
        var originY: Int = Int(currentY + self.lineHeight)
        var nextLine = false
        for dayView in self.days {
            if nextLine == true {
                nextLine = false
                originY += dayViewHeight
            }
            let weekday = dayView.dateComponents.weekday
            let column = columnForWeekday(weekday)
            var originX: Int = dayViewWidth * column
            dayView.frame = NSMakeRect(CGFloat(originX), CGFloat(originY), CGFloat(dayViewWidth), CGFloat(dayViewHeight))
            if column == 6 {
                // next line
                nextLine = true
                originX = 0
            } else {
                originX += dayViewWidth
            }
            
        }
        
        originY += dayViewHeight
        if originY != self.currentHeight {
            self.currentHeight = originY
            if let delegate = self.delegate {
                delegate.nmDatePicker?(self, newSize: NSMakeSize(self.bounds.size.width, CGFloat(originY)))
                
            }
        }
    }
    
    
    private func configureViewAppearance() {
        updateCurrentMonthLabel()
        
        // Current month and buttons
        self.currentMonthLabel.editable = false
        self.currentMonthLabel.backgroundColor = NSColor.clearColor()
        self.currentMonthLabel.bordered = false
        self.currentMonthLabel.alignment = NSTextAlignment.Center
        self.currentMonthLabel.font = self.titleFont
        self.currentMonthLabel.textColor = self.textColor
        self.addSubview(self.currentMonthLabel)
        
        self.monthBackButton.title = "<"
        self.monthBackButton.alignment = NSTextAlignment.Center
        let backBtnCell = self.monthBackButton.cell as! NSButtonCell
        backBtnCell.bezelStyle = NSBezelStyle.CircularBezelStyle
        self.monthBackButton.target = self
        self.monthBackButton.action = #selector(NMDatePicker.monthBackAction(_:))
        self.addSubview(self.monthBackButton)
        
        self.monthForwardButton.title = ">"
        self.monthForwardButton.alignment = NSTextAlignment.Center
        let forwardBtnCell = self.monthForwardButton.cell as! NSButtonCell
        forwardBtnCell.bezelStyle = NSBezelStyle.CircularBezelStyle
        self.monthForwardButton.target = self
        self.monthForwardButton.action = #selector(NMDatePicker.monthForwardAction(_:))
        self.addSubview(self.monthForwardButton)
        
        // Wekdays
        for weekdayLabel in self.weekdayLabels {
            weekdayLabel.removeFromSuperview()
        }
        self.weekdayLabels.removeAll(keepCapacity: true)
        for i in 0 ..< 7 {
            let weekday = weekdayNameForColumn(i)
            let weekdayLabel = NSTextField(frame: NSZeroRect)
            weekdayLabel.font = self.font
            weekdayLabel.textColor = self.textColor
            weekdayLabel.editable = false
            weekdayLabel.backgroundColor = NSColor.clearColor()
            weekdayLabel.bordered = false
            weekdayLabel.alignment = NSTextAlignment.Center
            weekdayLabel.stringValue = weekday
            
            self.weekdayLabels.append(weekdayLabel)
            self.addSubview(weekdayLabel)
        }
        
        // Days view
        updateDaysView()
    }
    
    
    private func updateCurrentMonthLabel() {
        self.currentMonthLabel.stringValue = monthAndYearForDay(self.firstDayComponents)
        
    }

    
    
    private func updateDaysView() {
        // Clean current view
        for day: NMDatePickerDayView in self.days {
            day.removeFromSuperview()
        }
        self.days.removeAll(keepCapacity: true)
        
        // Create new set of day views
        let daysInMonth = daysCountInMonthForDay(self.firstDayComponents)
        var dateComponents = self.firstDayComponents
        for _ in 0 ..< daysInMonth {
            let day = NMDatePickerDayView(dateComponents: dateComponents)
            day.backgroundColor = self.backgroundColor
            
            day.highlightedBorderColor = self.highlightedBorderColor
            day.highlightedBackgroundColor = self.highlightedBackgroundColor
            day.todayBackgroundColor = self.todayBackgroundColor
            day.todayBorderColor = self.todayBorderColor
            day.font = self.font
            day.textColor = self.textColor
            
            
            // Selected day callback action
            day.daySelectedAction = {
                () -> () in
                let dateComponents = day.dateComponents
                let dateValueComponents = self.calendar.components(self.dateTimeUnitMask, fromDate: self.dateValue)
                dateComponents.hour = dateValueComponents.hour
                dateComponents.minute = dateValueComponents.minute
                dateComponents.second = dateValueComponents.second
                if let dateValue = self.calendar.dateFromComponents(dateComponents) {
                    self.dateValue = dateValue
                    self.updateDaysView()
                    if let delegate = self.delegate {
                        delegate.nmDatePicker(self, selectedDate: self.dateValue)
                    }
                }
            }
            
            // Highlighted day callback action
            day.dayHighlightedAction = {
                (flag: Bool) -> () in
                day.setHighlighted(flag)
            }
            
            
            
            
            for markedDate in self.markedDates.keys {
                if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: markedDate) {
                    if let markedDateParams = self.markedDates[markedDate] {
                        day.selectedBackgroundColor = markedDateParams["backgroundColor"]
                        day.selectedBorderColor = markedDateParams["borderColor"]
                        day.selectedTextColor = markedDateParams["textColor"]
                        day.setSelected(true)
                    }
                    
                }
            }
            
            
            if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: self.dateValue) {
                day.selectedBackgroundColor = self.selectedBackgroundColor
                day.selectedBorderColor = self.selectedBorderColor
                day.selectedTextColor = self.selectedTextColor
                day.setSelected(true)
            }
            
            

            self.days.append(day)
            self.addSubview(day)
            dateComponents = nextDayForDay(dateComponents)
        }

        self.doLayout()
    }
    
    public class func lineHeightForFont(font: NSFont) -> CGFloat {
        let attribs = NSDictionary(object: font, forKey: NSFontAttributeName)
        let size = "Aa".sizeWithAttributes(attribs as? [String : AnyObject])
        return round(size.height)
    }
    
    override public func setFrameSize(newSize: NSSize) {
        super.setFrameSize(newSize)
        doLayout()
    }
    
    // MARK: - Date calculations
    
    class func isEqualDay(dateComponents: NSDateComponents, anotherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let anotherDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate:anotherDate)
        
        if dateComponents.day == anotherDateComponents.day && dateComponents.month == anotherDateComponents.month
            && dateComponents.year == anotherDateComponents.year {
                return true
        } else {
            return false
        }
    }
    
    private func monthAndYearForDay(dateComponents: NSDateComponents) -> String {
        let year = dateComponents.year
        let month = dateComponents.month
        let months = self.dateFormatter!.standaloneMonthSymbols
        let monthSymbol = months[month-1] as NSString
        
        return "\(monthSymbol) \(year)"
    }
    
    private func firstDayOfMonthForDate(date: NSDate) -> NSDateComponents {
        let dateComponents = self.calendar.components(self.dateUnitMask, fromDate: date)
        let weekday = dateComponents.weekday
        let day = dateComponents.day
        let weekOffset = day % 7
        
        dateComponents.day = 1
        dateComponents.weekday = weekday - weekOffset + 1
        if dateComponents.weekday < 0 {
            dateComponents.weekday += 7
        }
        
        return dateComponents
    }
    
    private func daysCountInMonthForDay(dateComponents: NSDateComponents) -> Int {
        let date = self.calendar.dateFromComponents(dateComponents)!
        let days = self.calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: date)
        return days.length
    }
    
    private func nextDayForDay(dateComponents: NSDateComponents) -> NSDateComponents {
        let nextDateComponents = NSDateComponents()
        nextDateComponents.day = dateComponents.day + 1
        nextDateComponents.month = dateComponents.month
        nextDateComponents.year = dateComponents.year
        nextDateComponents.weekday = dateComponents.weekday + 1
        if nextDateComponents.weekday > 7 {
            nextDateComponents.weekday -= 7
        }
        return nextDateComponents
    }

    
    private func oneMonthLaterDayForDay(dateComponents: NSDateComponents) -> NSDateComponents {
        let newDateComponents = NSDateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month + 1
        newDateComponents.year = dateComponents.year
        let oneMonthLaterDay = self.calendar.dateFromComponents(newDateComponents)!
        return self.calendar.components(self.dateUnitMask, fromDate: oneMonthLaterDay)
    }
    
    private func oneMonthEarlierDayForDay(dateComponents: NSDateComponents) -> NSDateComponents {
        let newDateComponents = NSDateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month - 1
        newDateComponents.year = dateComponents.year
        let oneMonthLaterDay = self.calendar.dateFromComponents(newDateComponents)!
        return self.calendar.components(self.dateUnitMask, fromDate: oneMonthLaterDay)
    }
    
    
    private func weekdayNameForColumn(column: Int) -> String {
        var index = column + self.firstDayOfWeek - 1
        if index >= 7 { index -= 7 }
        return self.weekdays[index]
    }
    
    private func columnForWeekday(weekday: Int) -> Int {
        var column = weekday - self.firstDayOfWeek
        if column < 0 { column += 7 }
        return column
    }

    
    private func configureWeekdays() {
        if  let dateFormatter = self.dateFormatter {
            dateFormatter.dateFormat = "EEEEE"
            let oneDayInterval = NSTimeInterval(60*60*24)
            let now = NSDate()
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
            let components = calendar?.components([NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: now)
            let dayComponents = NSDateComponents()
            dayComponents.hour = 12
            dayComponents.weekday = 1
            dayComponents.weekdayOrdinal = 1
            dayComponents.month = (components?.month)!
            dayComponents.year = (components?.year)!
            var day = calendar?.dateFromComponents(dayComponents)
            for _ in 0 ..< 7 {
                let daySymbol = dateFormatter.stringFromDate(day!)
                self.weekdays.append(daySymbol)
                day = day?.dateByAddingTimeInterval(oneDayInterval)
            }
            
        }
    }
    
    
    private func configureDateFormatter() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        self.dateFormatter = dateFormatter
    }
}
