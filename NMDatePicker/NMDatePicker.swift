//
//  NMDatePicker.swift
//
//  Created by Greg Kopel on 13.12.2014.
//  Copyright (c) 2014-15 Netmedia. All rights reserved.
//

import Cocoa

@objc public protocol NMDatePickerDelegate {
    /// This method notifies about the date selected in the date picker. (Required)
    func nmDatePicker(_ datePicker: NMDatePicker, selectedDate: Date)
    
    /// Optional method that allows to adjust date picker height
    /// when the number of rows is changing between months.
    @objc optional func nmDatePicker(_ datePicker: NMDatePicker, newSize: NSSize)
}

/// Custom date picker view.
open class NMDatePicker: NSView {
    
    
    // MARK: - Initializers
    public init(frame: NSRect, dateValue: Date) {
        self.dateValue = dateValue
        self.currentMonthLabel = NSTextField(frame: NSZeroRect)
        self.monthBackButton = NSButton(frame: NSZeroRect)
        self.monthForwardButton = NSButton(frame: NSZeroRect)
        self.currentHeight = 0
        self.font = NSFont.systemFont(ofSize: 12.0)
        self.titleFont = NSFont.boldSystemFont(ofSize: 12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        self.markedDates = [Date]()
        super.init(frame: frame)
        configurePicker()
    }
    
    public required init?(coder: NSCoder) {
        self.dateValue = Date()
        self.currentMonthLabel = NSTextField(frame: NSZeroRect)
        self.monthBackButton = NSButton(frame: NSZeroRect)
        self.monthForwardButton = NSButton(frame: NSZeroRect)
        self.currentHeight = 0
        self.font = NSFont.systemFont(ofSize: 12.0)
        self.titleFont = NSFont.boldSystemFont(ofSize: 12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        self.markedDates = [Date]()
        super.init(coder: coder)
        configurePicker()
    }

    
    func configurePicker() {
        calendar.firstWeekday = firstDayOfWeek
        firstDayComponents = firstDayOfMonthForDate(dateValue)
        configureDateFormatter()
        configureWeekdays()
        configureViewAppearance()
        doLayout()
    }
    
    // MARK: - Public properties
    open var delegate: NMDatePickerDelegate?
    open var dateValue: Date
    open let firstDayOfWeek = 2 // '1' - Sunday, '2' - Monday
    open var backgroundColor: NSColor? {
        didSet {
            self.setNeedsDisplay(self.bounds)
        }
    }
    open var titleFont: NSFont {
        didSet {
            configureViewAppearance()
        }
    }
    open var font: NSFont {
        didSet {
            self.lineHeight = NMDatePicker.lineHeightForFont(font)
            configureViewAppearance()
        }
    }
    open var textColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var todayTextColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var selectedTextColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var selectedBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var selectedBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var highlightedBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var highlightedBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var todayBackgroundColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var todayBorderColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var nextMonthTextColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var previousMonthTextColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    open var markColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    
    open var todayMarkColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    
    open var selectedMarkColor: NSColor? {
        didSet {
            updateDaysView()
        }
    }
    
    // MARK: - public methods
    
    
    open func markDate(_ date: Date) {
        self.markedDates.append(date)
        updateDaysView()
    }
    
    open func unmarkDate(_ date: Date) {
        if let index = self.markedDates.index(of: date) {
            self.markedDates.remove(at: index)
            updateDaysView()
        }
        
    }
    
    open func unmarkAllDates() {
        self.markedDates.removeAll()
        updateDaysView()
    }
    
    
    
    // MARK: - Private properties
    fileprivate var calendar = Calendar.current
    fileprivate let dateUnitMask: NSCalendar.Unit =  [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday]
    fileprivate let dateTimeUnitMask: NSCalendar.Unit =  [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.weekday]
    fileprivate var firstDayComponents: DateComponents!
    
    override open var isFlipped: Bool { return true }

    fileprivate(set) open var currentMonthLabel: NSTextField!
    fileprivate(set) open var monthBackButton: NSButton!
    fileprivate(set) open var monthForwardButton: NSButton!

    fileprivate var weekdays: [String] = []
    fileprivate var weekdayLabels: [NSTextField] = []
    fileprivate var days: [NMDatePickerDayView] = []
    fileprivate var currentHeight: Int
    fileprivate var lineHeight: CGFloat
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var markedDates: [ Date ]

    
    
    // MARK: - Layout

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let color = self.backgroundColor {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        
    }
    
    open func monthForwardAction(_ sender: NSButton?) {
        self.firstDayComponents = oneMonthLaterDayForDay(self.firstDayComponents)
        updateCurrentMonthLabel()
        updateDaysView()
        
    }
    
    open func monthBackAction(_ sender: NSButton?) {
        self.firstDayComponents = oneMonthEarlierDayForDay(self.firstDayComponents)
        updateCurrentMonthLabel()
        updateDaysView()
    }
    
    open func displayViewForDate(_ date: Date) {
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
            let weekday = dayView.dateComponents.weekday!
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
    
    
    fileprivate func configureViewAppearance() {
        updateCurrentMonthLabel()
        
        // Current month and buttons
        self.currentMonthLabel.isEditable = false
        self.currentMonthLabel.backgroundColor = NSColor.clear
        self.currentMonthLabel.isBordered = false
        self.currentMonthLabel.alignment = NSTextAlignment.center
        self.currentMonthLabel.font = self.titleFont
        self.currentMonthLabel.textColor = self.textColor
        self.addSubview(self.currentMonthLabel)
        
        self.monthBackButton.title = "<"
        self.monthBackButton.alignment = NSTextAlignment.center
        let backBtnCell = self.monthBackButton.cell as! NSButtonCell
        backBtnCell.bezelStyle = NSBezelStyle.circular
        self.monthBackButton.target = self
        self.monthBackButton.action = #selector(NMDatePicker.monthBackAction(_:))
        self.addSubview(self.monthBackButton)
        
        self.monthForwardButton.title = ">"
        self.monthForwardButton.alignment = NSTextAlignment.center
        let forwardBtnCell = self.monthForwardButton.cell as! NSButtonCell
        forwardBtnCell.bezelStyle = NSBezelStyle.circular
        self.monthForwardButton.target = self
        self.monthForwardButton.action = #selector(NMDatePicker.monthForwardAction(_:))
        self.addSubview(self.monthForwardButton)
        
        // Wekdays
        for weekdayLabel in self.weekdayLabels {
            weekdayLabel.removeFromSuperview()
        }
        self.weekdayLabels.removeAll(keepingCapacity: true)
        for i in 0 ..< 7 {
            let weekday = weekdayNameForColumn(i)
            let weekdayLabel = NSTextField(frame: NSZeroRect)
            weekdayLabel.font = self.font
            weekdayLabel.textColor = self.textColor
            weekdayLabel.isEditable = false
            weekdayLabel.backgroundColor = NSColor.clear
            weekdayLabel.isBordered = false
            weekdayLabel.alignment = NSTextAlignment.center
            weekdayLabel.stringValue = weekday
            
            self.weekdayLabels.append(weekdayLabel)
            self.addSubview(weekdayLabel)
        }
        
        // Days view
        updateDaysView()
    }
    
    
    fileprivate func updateCurrentMonthLabel() {
        self.currentMonthLabel.stringValue = monthAndYearForDay(self.firstDayComponents)
        
    }

    
    
    fileprivate func updateDaysView() {
        // Clean current view
        for day: NMDatePickerDayView in self.days {
            day.removeFromSuperview()
        }
        self.days.removeAll(keepingCapacity: true)
        
        // Create new set of day views
        let daysInMonth = daysCountInMonthForDay(self.firstDayComponents)
        var dateComponents = self.firstDayComponents
        let firstWkDay = self.firstDayComponents.weekday
        
        
        // Previous month
        var visibledaysPreviousMonth = firstWkDay! - self.firstDayOfWeek
        if visibledaysPreviousMonth < 0 {
            visibledaysPreviousMonth += 7
        }
        visibledaysPreviousMonth *= -1
        for index in visibledaysPreviousMonth ..< 0 {
            let dayComponents = dayByAddingDays(index, fromDate: firstDayComponents)
            let day = NMDatePickerDayView(dateComponents: dayComponents)
            
            day.font = font
            day.textColor = self.previousMonthTextColor
            day.highlightedBorderColor = self.highlightedBorderColor
            day.highlightedBackgroundColor = self.highlightedBackgroundColor
            day.markColor = self.markColor
            
            // Highlighted day callback action
            day.dayHighlightedAction = {
                (flag: Bool) -> () in
                day.setHighlighted(flag)
            }
            
            // Selected day callback action
            day.daySelectedAction = {
                () -> () in
                self.monthBackAction(nil)
                var dateComponents = day.dateComponents
                let dateValueComponents = (self.calendar as NSCalendar).components(self.dateTimeUnitMask, from: self.dateValue)
                dateComponents.hour = dateValueComponents.hour
                dateComponents.minute = dateValueComponents.minute
                dateComponents.second = dateValueComponents.second
                if let dateValue = self.calendar.date(from: dateComponents) {
                    self.dateValue = dateValue
                    self.updateDaysView()
                    if let delegate = self.delegate {
                        delegate.nmDatePicker(self, selectedDate: self.dateValue)
                    }
                }
                
            }
            
            for markedDate in self.markedDates {
                if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: markedDate) {
                    day.marked = true
                }
            }
            
            self.days.append(day)
            self.addSubview(day)
        }
        
        
        // Current month
        for _ in 0 ..< daysInMonth {
            let day = NMDatePickerDayView(dateComponents: dateComponents!)
            day.backgroundColor = self.backgroundColor
            
            
            day.highlightedBorderColor = self.highlightedBorderColor
            day.highlightedBackgroundColor = self.highlightedBackgroundColor
            day.todayBorderColor = self.todayBorderColor
            day.font = self.font
            day.textColor = self.textColor
            day.markColor = self.markColor
            
            
            if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: Date()) {
                day.textColor = self.todayTextColor
                day.markColor = self.todayMarkColor
            }
            
            
            // Selected day callback action
            day.daySelectedAction = {
                () -> () in
                var dateComponents = day.dateComponents
                let dateValueComponents = (self.calendar as NSCalendar).components(self.dateTimeUnitMask, from: self.dateValue)
                dateComponents.hour = dateValueComponents.hour
                dateComponents.minute = dateValueComponents.minute
                dateComponents.second = dateValueComponents.second
                if let dateValue = self.calendar.date(from: dateComponents) {
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
            
            for markedDate in self.markedDates {
                if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: markedDate) {
                    day.marked = true
                }
            }
            
            
            if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: self.dateValue) {
                if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: Date()) {
                    day.selectedBackgroundColor = self.todayBackgroundColor
                    day.selectedBorderColor = self.todayBorderColor
                } else {
                    day.selectedBackgroundColor = self.selectedBackgroundColor
                    day.selectedBorderColor = self.selectedBorderColor
                }
                
                day.selectedTextColor = self.selectedTextColor
                day.markColor = self.selectedMarkColor
                day.setSelected(true)
            }
            

            self.days.append(day)
            self.addSubview(day)
            // dateComponents = nextDayForDay(dateComponents)
            dateComponents = dayByAddingDays(1, fromDate: dateComponents!)
        }
        
        
        
        // Next month
        var visibleDaysNextMonth = self.firstDayOfWeek + 7 - (dateComponents?.weekday!)!
        if visibleDaysNextMonth > 7 {
            visibleDaysNextMonth -= 7
        }
        for _ in 1 ... visibleDaysNextMonth {
            let day = NMDatePickerDayView(dateComponents: dateComponents!)
            
            day.font = font
            day.textColor = self.nextMonthTextColor
            day.highlightedBorderColor = self.highlightedBorderColor
            day.highlightedBackgroundColor = self.highlightedBackgroundColor
            day.markColor = self.markColor
            
            // Highlighted day callback action
            day.dayHighlightedAction = {
                (flag: Bool) -> () in
                day.setHighlighted(flag)
            }
            
            
            // Selected day callback action
            day.daySelectedAction = {
                () -> () in
                self.monthForwardAction(nil)
                var dateComponents = day.dateComponents
                let dateValueComponents = (self.calendar as NSCalendar).components(self.dateTimeUnitMask, from: self.dateValue)
                dateComponents.hour = dateValueComponents.hour
                dateComponents.minute = dateValueComponents.minute
                dateComponents.second = dateValueComponents.second
                if let dateValue = self.calendar.date(from: dateComponents) {
                    self.dateValue = dateValue
                    self.updateDaysView()
                    if let delegate = self.delegate {
                        delegate.nmDatePicker(self, selectedDate: self.dateValue)
                    }
                }

            }
            
            
            for markedDate in self.markedDates {
                if NMDatePicker.isEqualDay(day.dateComponents, anotherDate: markedDate) {
                    day.marked = true
                }
            }
            
            
            self.days.append(day)
            self.addSubview(day)
            dateComponents = dayByAddingDays(1, fromDate: dateComponents!)
        }

        doLayout()
    }
    
    open class func lineHeightForFont(_ font: NSFont) -> CGFloat {
        let attribs = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let size = "Aa".size(withAttributes: attribs as? [String : AnyObject])
        return round(size.height)
    }
    
    override open func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        doLayout()
    }
    
    // MARK: - Date calculations
    
    class func isEqualDay(_ dateComponents: DateComponents, anotherDate: Date) -> Bool {
        let calendar = Calendar.current
        let anotherDateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from:anotherDate)
        
        if dateComponents.day == anotherDateComponents.day && dateComponents.month == anotherDateComponents.month
            && dateComponents.year == anotherDateComponents.year {
                return true
        } else {
            return false
        }
    }
    
    fileprivate func monthAndYearForDay(_ dateComponents: DateComponents) -> String {
        let year = dateComponents.year
        let month = dateComponents.month
        let months = self.dateFormatter!.standaloneMonthSymbols
        
        if let _year = year, let _month = month, let _months = months {
            let monthSymbol = _months[_month-1]
            return "\(monthSymbol) \(_year)"
        } else {
            return "--"
        }
    }
    
    fileprivate func firstDayOfMonthForDate(_ date: Date) -> DateComponents {
        var dateComponents = (self.calendar as NSCalendar).components(self.dateUnitMask, from: date)
        let weekday = dateComponents.weekday!
        let day = dateComponents.day!
        let weekOffset = day % 7
        
        dateComponents.day = 1
        dateComponents.weekday = weekday - weekOffset + 1
        if dateComponents.weekday! < 0 {
            dateComponents.weekday! += 7
        }
        
        return dateComponents
    }
    
    fileprivate func daysCountInMonthForDay(_ dateComponents: DateComponents) -> Int {
        let date = self.calendar.date(from: dateComponents)!
        let days = (self.calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date)
        return days.length
    }
    
    fileprivate func dayByAddingDays(_ days: Int, fromDate anotherDate: DateComponents) -> DateComponents {
        
        var dateComponents = DateComponents()
        
        dateComponents.day = anotherDate.day! + days
        dateComponents.month = anotherDate.month
        dateComponents.year = anotherDate.year
        
        let day = self.calendar.date(from: dateComponents)!
        return (self.calendar as NSCalendar).components(self.dateUnitMask, from: day)
    }

    
    fileprivate func oneMonthLaterDayForDay(_ dateComponents: DateComponents) -> DateComponents {
        var newDateComponents = DateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month! + 1
        newDateComponents.year = dateComponents.year
        let oneMonthLaterDay = self.calendar.date(from: newDateComponents)!
        return (self.calendar as NSCalendar).components(self.dateUnitMask, from: oneMonthLaterDay)
    }
    
    fileprivate func oneMonthEarlierDayForDay(_ dateComponents: DateComponents) -> DateComponents {
        var newDateComponents = DateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month! - 1
        newDateComponents.year = dateComponents.year
        let oneMonthLaterDay = self.calendar.date(from: newDateComponents)!
        return (self.calendar as NSCalendar).components(self.dateUnitMask, from: oneMonthLaterDay)
    }
    
    
    fileprivate func weekdayNameForColumn(_ column: Int) -> String {
        var index = column + self.firstDayOfWeek - 1
        if index >= 7 { index -= 7 }
        return self.weekdays[index]
    }
    
    fileprivate func columnForWeekday(_ weekday: Int) -> Int {
        var column = weekday - self.firstDayOfWeek
        if column < 0 { column += 7 }
        return column
    }

    
    fileprivate func configureWeekdays() {
        if  let dateFormatter = self.dateFormatter {
            dateFormatter.dateFormat = "EEEEE"
            let oneDayInterval = TimeInterval(60*60*24)
            let now = Date()
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let components = (calendar as NSCalendar?)?.components([NSCalendar.Unit.year, NSCalendar.Unit.month], from: now)
            var dayComponents = DateComponents()
            dayComponents.hour = 12
            dayComponents.weekday = 1
            dayComponents.weekdayOrdinal = 1
            dayComponents.month = (components?.month)!
            dayComponents.year = (components?.year)!
            var day = calendar.date(from: dayComponents)
            for _ in 0 ..< 7 {
                let daySymbol = dateFormatter.string(from: day!)
                self.weekdays.append(daySymbol)
                day = day?.addingTimeInterval(oneDayInterval)
            }
            
        }
    }
    
    
    fileprivate func configureDateFormatter() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        self.dateFormatter = dateFormatter
    }
}
