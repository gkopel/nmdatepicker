NMDatePicker: Custom OS X Date Picker 
=====================================

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

NSDatePicker replacement allowing for appearance customisation.

## Preview
![NMDatePicker preview](http://netmedia.home.pl/github/nmdatepicker/nmdatepicker-preview.png)

## Features
- custom date picker size,
- custom font size and colour,
- custom colours for date picker background, selected day, highlighted day.
- particular days can be marked with a bullet symbol.
- can be created in code or in Interface Builder

## Installation
- Add NMDatePicker.swift and NMDatePickerDayView.swift to your project

## Requirements
- OS X 10.11 or later
- Swift 2.2 or later

## Delegate Methods
```swift
/* 
This method notifies about the date selected in the date picker.
*/
func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate)   
```

```swift
/*
Optional method that allows to adjust date picker height   
when the number of rows is changing between months.    
*/
func nmDatePicker(datePicker: NMDatePicker, newSize: NSSize) 
```
You can use analogous methods in Objective-C code.


## Demo Apps
NMDate Picker can be used from both Swift and Objective-C code. See demo apps:
- TestApp1: example Swift application containing NMDatePicker view created in code.
- TestApp2: example Swift application containing NMDatePicker view created in Interface Builder.
- TestApp3: example Objective-C application containing NMDatePicker view created in code.
- TestApp4: example Objective-C application containing NMDatePicker view created in Interface Builder.


## License
NMDatePicker is available under the MIT license. See the LICENSE file for more info.

