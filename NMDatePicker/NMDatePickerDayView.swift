//
//  NMDatePickerDayView.swift
//
//  Created by Greg Kopel on 26.12.2014.
//  Copyright (c) 2014-15 Netmedia. All rights reserved.
//

import Cocoa


/// Custom view presenting single day in `NMDatePickerView`.
open class NMDatePickerDayView: NSView {
    
    // MARK: - Public properties
    open let dateComponents: DateComponents
    open var backgroundColor: NSColor?
    open var borderColor: NSColor?
    open var selected: Bool?
    open var highlighted: Bool?
    open var highlightedBackgroundColor: NSColor?
    open var highlightedBorderColor: NSColor?
    open var selectedBackgroundColor: NSColor?
    open var selectedBorderColor: NSColor?
    open var todayBackgroundColor: NSColor?
    open var todayBorderColor: NSColor?
    open var textColor: NSColor? {
        didSet {
            self.label.textColor = textColor
        }
    }
    open var selectedTextColor: NSColor?
    open var highlightedTextColor: NSColor?
    open var font: NSFont {
        didSet {
            self.label.font = font
            self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        }
    }
    open var marked: Bool?
    open var markColor: NSColor?
    
    // Callback actions
    var daySelectedAction: ((Void) -> (Void))?
    var dayHighlightedAction: ((Bool) -> (Void))?
    
    
    // MARK: - Private properties
    fileprivate var trackingArea: NSTrackingArea?
    fileprivate var label: NSTextField!
    fileprivate var lineHeight: CGFloat
    
    
    // MARK: - Initializers
    
    public init(dateComponents: DateComponents) {
        self.dateComponents = dateComponents
        self.font = NSFont.systemFont(ofSize: 12.0)
        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
        super.init(frame: NSZeroRect)
        
        
        // Get day component
        let day = self.dateComponents.day!
        
        // Configure label
        self.label = NSTextField(frame: NSZeroRect)
        self.label.isEditable = false
        self.label.backgroundColor = NSColor.clear
        self.label.isBordered = false
        self.label.alignment = NSTextAlignment.center
        self.label.textColor = NSColor.black
        self.label.font = self.font
        self.label.stringValue = "\(day)"
        self.addSubview(self.label)
        
        self.marked = false
        
        
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override open func resizeSubviews(withOldSize oldSize: NSSize) {
        
        let labelRect = CGRect(x: 2.5, y: (self.bounds.size.height-self.lineHeight)/2+0.5, width: self.bounds.size.width-4, height: self.lineHeight)
        self.label.frame = labelRect.integral
        
    }
    

    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Rectangular selection
//        var frameRect = CGRectInset(dirtyRect, 1, 1)
//        frameRect.origin.x += 0.5
//        frameRect.origin.y += 0.5
//        let path = NSBezierPath(rect:frameRect)

        
        // Circle selection
        let width = self.bounds.height * 0.9
        let height = self.bounds.height * 0.9
        let pathFrame = CGRect(x: (self.bounds.width - width)/2.0, y: (self.bounds.height - height)/2.0, width: width, height: height);
        let path = NSBezierPath(ovalIn: pathFrame)
        
        if self.selected == true {
            if let color = self.selectedBackgroundColor {
                color.setFill()
                path.fill()
            }
            if let color = self.selectedBorderColor {
                color.setStroke()
                path.stroke()
            }
        } else if self.highlighted == true {
            if let color = self.highlightedBackgroundColor {
                color.setFill()
                path.fill()
            }
            if let color = self.highlightedBorderColor {
                color.setStroke()
                path.stroke()
            }
        } else {
            if let color = self.backgroundColor {
                color.setFill()
                path.fill()
            }
            if let color = self.borderColor {
                color.setStroke()
                path.stroke()
            }
        }
        
        
        if self.marked == true {
            let markerFrame = CGRect(x: (self.bounds.width - 4.0)/2.0, y: self.label.frame.minY - 5.0, width: 4.0, height: 4.0);
            let path = NSBezierPath(ovalIn: markerFrame)
            if let color = self.markColor {
                color.setFill()
                path.fill()
            }
        }
        
        
    }
    
    open func setSelected(_ state: Bool) {
        self.selected = state
        if state == true {
            if let color = self.selectedTextColor {
                self.label.textColor = color
            }
            
        } else {
            if let color = self.textColor {
                self.label.textColor = color
            }
        }
        
        self.setNeedsDisplay(self.bounds)
    }
    
    open func setHighlighted(_ state: Bool) {
        self.highlighted = state
        self.setNeedsDisplay(self.bounds)
    }
    
    // MARK: - Events handling
    
    override open func mouseDown(with theEvent: NSEvent) {
        if let action = self.daySelectedAction {
            action()
        }
    }
    
    override open func mouseEntered(with theEvent: NSEvent) {
        if let action = self.dayHighlightedAction {
            action(true)
        }
    }
    
    override open func mouseExited(with theEvent: NSEvent) {
        if let action = self.dayHighlightedAction {
            action(false)
        }
    }
    
    override open func updateTrackingAreas() {
        if self.trackingArea != nil {
            self.removeTrackingArea(self.trackingArea!)
        }
        let opts: NSTrackingAreaOptions = [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea!)
        
    }
}
