//
//  AppDelegate.m
//  TestApp4
//
//  Created by Greg Kopel on 11.01.2015.
//  Copyright (c) 2015 Netmedia. All rights reserved.
//

#import "AppDelegate.h"
#import "TestApp4-Swift.h"

@interface AppDelegate () <NMDatePickerDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NMDatePicker *datePicker;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDate *now = [NSDate date];
    [self updateDateLabel:now];
    
    self.datePicker.dateValue = now;
    self.datePicker.delegate = self;
    
    // NMDatePicker appearance properties
    self.datePicker.backgroundColor = [NSColor whiteColor];
    self.datePicker.font = [NSFont systemFontOfSize:13.0];
    self.datePicker.titleFont = [NSFont boldSystemFontOfSize:14.0];
    self.datePicker.textColor = [NSColor blackColor];
    self.datePicker.selectedTextColor = [NSColor whiteColor];
    self.datePicker.todayBackgroundColor = [NSColor whiteColor];
    self.datePicker.todayBorderColor = [NSColor blueColor];
    self.datePicker.highlightedBackgroundColor = [NSColor lightGrayColor];
    self.datePicker.highlightedBorderColor = [NSColor darkGrayColor];
    self.datePicker.selectedBackgroundColor = [NSColor orangeColor];
    self.datePicker.selectedBorderColor = [NSColor blueColor];
    
    
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


- (void)nmDatePicker:(NMDatePicker *)datePicker newSize:(NSSize)newSize {
    CGRect frame = self.datePicker.frame;
    frame.origin.y += frame.size.height - newSize.height;
    frame.size.height = newSize.height;
    
    self.datePicker.frame = frame;
}



- (void)nmDatePicker:(NMDatePicker *)datePicker selectedDate:(NSDate *)selectedDate {
    [self updateDateLabel:selectedDate];
}


@end
