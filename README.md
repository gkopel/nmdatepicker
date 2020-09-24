NMDatePicker: Custom OS X Date Picker 
=====================================


NSDatePicker replacement allowing for appearance customisation.

## Preview
![NMDatePicker preview](https://netmedia.dev/images/nmdatepicker/nmdatepicker.png)

## Features
- custom date picker size,
- custom font size and colour,
- custom colours for date picker background, selected day, highlighted day.
- particular days can be marked with a bullet symbol.
- can be created in code or in Interface Builder

## Installation
There are two alternative ways to install NMDatePicker:
- Add NMDatePicker.swift and NMDatePickerDayView.swift to your project,
- Add NMDatePicker framework using Carthage dependency manager.

## Requirements
- OS X 10.11 or later
- Swift 5.0 or later

## Delegate Methods
```swift
/* 
This method notifies about the date selected in the date picker.
*/
func nmDatePicker(_ datePicker: NMDatePicker, selectedDate: Date)   
```

```swift
/*
Optional method that allows to adjust date picker height   
when the number of rows is changing between months.    
*/
optional func nmDatePicker(_ datePicker: NMDatePicker, newSize: NSSize) 
```
You can use analogous methods in Objective-C code.


## Demo Apps
NMDate Picker can be used from both Swift and Objective-C code. See demo apps:
- TestApp1: example Swift application containing NMDatePicker view created in code.
- TestApp2: example Swift application containing NMDatePicker view created in Interface Builder.


## License
NMDatePicker is available under the MIT license. See the LICENSE file for more info.

