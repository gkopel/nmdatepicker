NMDatePicker: Custom OS X Date Picker
=====================================

NSDatePicker replacement allowing for appearance customisation.

## Preview
![NMDatePicker preview](http://netmedia.home.pl/github/nmdatepicker/nmdatepicker-preview.png)

## Features
- custom date picker size,
- custom font size and colour,
- custom colours for date picker background, selected day, highlighted day.
- can be created in code or in Interface Builder

## Installation
- Add NMDatePicker.swift and NMDatePickerDayView.swift to your project

## Requirements
- OS X 10.10 or later
- Swift 1.2 or later

## Delegate Methods
1. Swift
func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate)   

// Optional method that allows to adjust date picker height when the number of rows is changing between months  
func nmDatePicker(datePicker: NMDatePicker, newSize: NSSize) 

2. Objective-C
- (void)nmDatePicker:(NMDatePicker \*)datePicker newSize:(NSSize)newSize;

// Optional method that allows to adjust date picker height when the number of rows is changing between months  
- (void)nmDatePicker:(NMDatePicker \*)datePicker selectedDate:(NSDate \*)selectedDate;

## Demo Apps
NMDate Picker can be used from both Swifth and Objective-C code. See demo apps:
- TestApp1: example Swift  application containing NMDatePicker view created in code.
- TestApp2: example Swift application containing NMDatePicker view created in Interface Builder.
- TestApp3: example Objective-C application containing NMDatePicker view created in code.
- TestApp4: example Objective-C application containing NMDatePicker view created in Interface Builder.


## License
NMDatePicker is available under the MIT license. See the LICENSE file for more info.

