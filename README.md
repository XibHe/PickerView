# PickerView
Custom different type UIPickerView.

# Usage
see sample Xcode project in /Demo.

Import **PickerView.h** before you want to use.

To make a new PickerView, call the class method like so:

```objectivec
    PickerView *datePickerView = [[PickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    datePickerView.delegate = self;
    datePickerView.pickerType = PickerType_AnyDate;
    datePickerView.pickerMode = UIDatePickerModeDate;
    [self.view.superview insertSubview:datePickerView aboveSubview:self.view];
    [datePickerView show];
```

# Hint

you can set different style by property, eg. **pickerType**，**pickerMode**，**CheckDate**

```objectivec
  datePickerView.pickerType = PickerType_pruductDate;
  datePickerView.pickerMode = UIDatePickerModeDate;
  datePickerView.isCheckDate = YES;
  datePickerView.CheckDate = self.checkDate;
```

# Requirements
iOS 8+

# License
PickerView is available under the MIT license. See the LICENSE file for more info.