//
//  NMDatePicker.swift
//
//  Created by Greg Kopel on 13.12.2014.
//  Copyright (c) 2014-15 Netmedia. All rights reserved.
//

import Cocoa

@objc protocol NMDatePickerDelegate {
    /*
    This method notifies about the date selected in the date picker.
    */
    func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate)
    
    /*
    Optional method that allows to adjust date picker height
    when the number of rows is changing between months.
    */
    optional func nmDatePicker(datePicker: NMDatePicker, newSize: NSSize)
}

/**
* Custom date picker view
*/
class NMDatePicker: NSView {
    
    
    // MARK: - Initializers
    init(frame: NSRect, dateValue: NSDate) {
        self.dateValue = dateValue
        self.currentMonthLabel = NSTextField(frame: NSZeroRect)
        self.monthBackButton = NSButton(frame: NSZeroRect)
        self.monthForwardButton = NSButton(frame: NSZeroRect)
        self.currentHeight = 0
        self.font = NSFont.systemFontOfSize(12.0)
        self.titleFont = NSFont.boldSystemFontOfSize(12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        super.init(frame: frame)
        configurePicker()
    }
    
    required init?(coder: NSCoder) {
        self.dateValue = NSDate()
        self.currentMonthLabel = NSTextField(frame: NSZeroRect)
        self.monthBackButton = NSButton(frame: NSZeroRect)
        self.monthForwardButton = NSButton(frame: NSZeroRect)
        self.currentHeight = 0
        self.font = NSFont.systemFontOfSize(12.0)
        self.titleFont = NSFont.boldSystemFontOfSize(12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
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
    var delegate: NMDatePickerDelegate?
    var dateValue: NSDate
    let firstDayOfWeek = 2 // '1' - Sunday, '2' - Monday
    var backgroundColor: NSColor? {
        didSet {
            self.setNeedsDisplayInRect(self.bounds)
        }
    }
    var titleFont: NSFont {
        didSet {
            configureViewAppearance()
        }
    }
    var font: NSFont {
        didSet {
            self.lineHeight = NMDatePicker.lineHeightForFont(font)
            configureViewAppearance()
        }
    }
    var textColor: NSColor? {
        didSet {
            configureViewAppearance()
        }
    }
    var selectedTextColor: NSColor? {
        didSet {
            configureViewAppearance()
        }
    }
    var selectedBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    var selectedBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    var highlightedBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    var highlightedBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    var todayBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    var todayBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    
    
    
    // MARK: - Private properties
    private let calendar = NSCalendar.currentCalendar()
    private let dateUnitMask =  NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitWeekday
    private let dateTimeUnitMask =  NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |
                                    NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour |
                                    NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond |
                                    NSCalendarUnit.CalendarUnitWeekday
    private var firstDayComponents: NSDateComponents!
    
    override var flipped: Bool { return true }
    private var currentMonthLabel: NSTextField!
    private var monthBackButton: NSButton!
    private var monthForwardButton: NSButton!
    private var weekdays: [String] = []
    private var weekdayLabels: [NSTextField] = []
    private var days: [NMDatePickerDayView] = []
    private var currentHeight: Int
    private var lineHeight: CGFloat
    private var dateFormatter: NSDateFormatter?
    
    
    
    
    
    // MARK: - Layout

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if let color = self.backgroundColor {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        
    }
    
    func monthForwardAction(sender: NSButton) {
        self.firstDayComponents = oneMonthLaterDayForDay(self.firstDayComponents)
        updateCurrentMonthLabel()
        updateDaysView()
        
    }
    
    func monthBackAction(sender: NSButton) {
        self.firstDayComponents = oneMonthEarlierDayForDay(self.firstDayComponents)
        updateCurrentMonthLabel()
        updateDaysView()
    }
    
    func displayViewForDate(date: NSDate) {
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
        self.currentMonthLabel.alignment = NSTextAlignment.CenterTextAlignment
        self.currentMonthLabel.font = self.titleFont
        self.currentMonthLabel.textColor = self.textColor
        self.addSubview(self.currentMonthLabel)
        
        self.monthBackButton.title = "<"
        self.monthBackButton.alignment = NSTextAlignment.CenterTextAlignment
        let backBtnCell = self.monthBackButton.cell() as! NSButtonCell
        backBtnCell.bezelStyle = NSBezelStyle.CircularBezelStyle
        self.monthBackButton.target = self
        self.monthBackButton.action = Selector("monthBackAction:")
        self.addSubview(self.monthBackButton)
        
        self.monthForwardButton.title = ">"
        self.monthForwardButton.alignment = NSTextAlignment.CenterTextAlignment
        let forwardBtnCell = self.monthForwardButton.cell() as! NSButtonCell
        forwardBtnCell.bezelStyle = NSBezelStyle.CircularBezelStyle
        self.monthForwardButton.target = self
        self.monthForwardButton.action = Selector("monthForwardAction:")
        self.addSubview(self.monthForwardButton)
        
        // Wekdays
        for weekdayLabel in self.weekdayLabels {
            weekdayLabel.removeFromSuperview()
        }
        self.weekdayLabels.removeAll(keepCapacity: true)
        for var i = 0; i < 7; i++ {
            let weekday = weekdayNameForColumn(i)
            var weekdayLabel = NSTextField(frame: NSZeroRect)
            weekdayLabel.font = self.font
            weekdayLabel.textColor = self.textColor
            weekdayLabel.editable = false
            weekdayLabel.backgroundColor = NSColor.clearColor()
            weekdayLabel.bordered = false
            weekdayLabel.alignment = NSTextAlignment.CenterTextAlignment
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
        for var i = 0; i < daysInMonth; i++ {
            let day = NMDatePickerDayView(dateComponents: dateComponents)
            day.backgroundColor = self.backgroundColor
            day.selectedBackgroundColor = self.selectedBackgroundColor
            day.selectedBorderColor = self.selectedBorderColor
            day.highlightedBorderColor = self.highlightedBorderColor
            day.highlightedBackgroundColor = self.highlightedBackgroundColor
            day.todayBackgroundColor = self.todayBackgroundColor
            day.todayBorderColor = self.todayBorderColor
            day.font = self.font
            day.textColor = self.textColor
            day.selectedTextColor = self.selectedTextColor
            
            // Selected day callback action
            day.daySelectedAction = {
                () -> () in
                var dateComponents = day.dateComponents
                var dateValueComponents = self.calendar.components(self.dateTimeUnitMask, fromDate: self.dateValue)
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
            
            
            if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: self.dateValue) {
                day.setSelected(true)
            }

            self.days.append(day)
            self.addSubview(day)
            dateComponents = nextDayForDay(dateComponents)
        }

        self.doLayout()
    }
    
    class func lineHeightForFont(font: NSFont) -> CGFloat {
        var attribs = NSDictionary(object: font, forKey: NSFontAttributeName)
        
        let size = "Aa".sizeWithAttributes(attribs as [NSObject : AnyObject])
        return round(size.height)
    }
    
    // MARK: - Date calculations
    
    class func isEqualDay(dateComponents: NSDateComponents, anotherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let anotherDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear
            | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate:anotherDate)
        
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
        let monthSymbol = months[month-1] as! NSString
        
        return "\(monthSymbol) \(year)"
    }
    
    private func firstDayOfMonthForDate(date: NSDate) -> NSDateComponents {
        var dateComponents = self.calendar.components(self.dateUnitMask, fromDate: date)
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
        let days = self.calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: date)
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
        var newDateComponents = NSDateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month + 1
        newDateComponents.year = dateComponents.year
        let oneMonthLaterDay = self.calendar.dateFromComponents(newDateComponents)!
        return self.calendar.components(self.dateUnitMask, fromDate: oneMonthLaterDay)
    }
    
    private func oneMonthEarlierDayForDay(dateComponents: NSDateComponents) -> NSDateComponents {
        var newDateComponents = NSDateComponents()
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
        var weekdays: [String] = []
        if  let dateFormatter = self.dateFormatter {
            dateFormatter.dateFormat = "EEEEE"
            let oneDayInterval = NSTimeInterval(60*60*24)
            let now = NSDate()
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
            let components = calendar?.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth, fromDate: now)
            let dayComponents = NSDateComponents()
            dayComponents.hour = 12
            dayComponents.weekday = 1
            dayComponents.weekdayOrdinal = 1
            dayComponents.month = (components?.month)!
            dayComponents.year = (components?.year)!
            var day = calendar?.dateFromComponents(dayComponents)
            for var i = 0; i < 7; i++ {
                let daySymbol = dateFormatter.stringFromDate(day!)
                self.weekdays.append(daySymbol)
                day = day?.dateByAddingTimeInterval(oneDayInterval)
            }
            
        }
    }
    
    
    private func configureDateFormatter() {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        self.dateFormatter = dateFormatter
    }
    
    
}
