//
//  AppDelegate.m
//  TestApp3
//
//  Created by Greg Kopel on 11.01.2015.
//  Copyright (c) 2015 Netmedia. All rights reserved.
//

#import "AppDelegate.h"
#import "TestApp3-Swift.h"


@interface AppDelegate () <NMDatePickerDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;
@property (weak) NMDatePicker *datePicker;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDate *now = [NSDate date];
    [self updateDateLabel:now];
    
    NMDatePicker *datePicker = [[NMDatePicker alloc] initWithFrame:NSMakeRect(20, 60, 256, 256) dateValue:now];
    self.datePicker = datePicker;
    datePicker.delegate = self;
    datePicker.autoresizingMask = NSViewMinYMargin;
    
    
    // NMDatePicker appearance properties
    datePicker.backgroundColor = [NSColor whiteColor];
    datePicker.font = [NSFont systemFontOfSize:13.0];
    datePicker.titleFont = [NSFont boldSystemFontOfSize:14.0];
    datePicker.textColor = [NSColor blackColor];
    datePicker.selectedTextColor = [NSColor whiteColor];
    datePicker.todayBackgroundColor = [NSColor whiteColor];
    datePicker.todayBorderColor = [NSColor blueColor];
    datePicker.highlightedBackgroundColor = [NSColor lightGrayColor];
    datePicker.highlightedBorderColor = [NSColor darkGrayColor];
    datePicker.selectedBackgroundColor = [NSColor orangeColor];
    datePicker.selectedBorderColor = [NSColor blueColor];
    
    
    NSView *contentView = self.window.contentView;
    [contentView addSubview:datePicker];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

+ (NSString *)shortDateForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    return [dateFormatter stringFromDate:date];
}


- (void)updateDateLabel:(NSDate *)date {
    self.label.stringValue = [AppDelegate shortDateForDate:date];
}


- (IBAction)showTodayAction:(id)sender {
    [self.datePicker displayViewForDate:[NSDate date]];
}


#pragma mark - NMDatePicker delegate

- (void)nmDatePicker:(NMDatePicker *)datePicker selectedDate:(NSDate *)selectedDate {
    [self updateDateLabel:selectedDate];
}

@end
