//
//  PickerView.m
//  Steward
//
//  Created by Peng he on 15/8/31.
//  Copyright (c) 2015年 ChengpinKuaipai. All rights reserved.
//

#import "PickerView.h"
#import "NSDate+YN.h"

#define CANCEL_BUTTON_TAG   100
#define DONE_BUTTON_TAG     200

// 获取设备物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
// 获取设备物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
// 设置颜色
#define Color(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
@interface PickerView ()
@property (nonatomic, strong) NSMutableArray *arrayYears;
@property (nonatomic, strong) NSMutableArray *arrayMonths;
@property (nonatomic, strong) NSMutableArray *arrayDays;
@property (nonatomic, strong) NSArray *meridiemArray;
@property (copy, nonatomic) NSString *strYear;      //  年
@property (copy, nonatomic) NSString *strMonth;     //  月
@property (copy, nonatomic) NSString *strDay;       //  日
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation PickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 1;
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor =[UIColor whiteColor];
    }
    return self;
}
- (void)assignTheNecessaryValue
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    //获得系统时间和日期
    NSDate *  senddate=[NSDate date];
    
    if (_pickerType == PickerType_AnyDate && _pickerMode == UIDatePickerModeDate) {
        
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        
        if (self.isCheckDate == YES) {
            
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            
            self.pickerDate = self.CheckDate;
        }
        else{
            
            _dateString = [dateformatter stringFromDate:senddate];
            
            self.pickerDate = senddate;
        }
        
    }
    else if (_pickerMode == UIDatePickerModeTime) {
        [dateformatter setDateFormat:@"HH:mm"];
        //显示已选的日期
        if (self.isCheckDate == YES) {
            
            //[dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            NSLog(@"已选的时间点 = %@",self.CheckDate);
            
            self.pickerDate = self.CheckDate;
        }
        else{
            
            _dateString = [dateformatter stringFromDate:senddate];
            
            self.pickerDate = senddate;
        }
        
    }
    else if (_pickerMode == UIDatePickerModeDate){
        
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        //显示已选的日期
        if (self.isCheckDate == YES) {
            
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            
            self.pickerDate = self.CheckDate;
        }
        else{
            
            _dateString = [dateformatter stringFromDate:senddate];
            
            self.pickerDate = senddate;
        }
        
    }
    else if (_pickerMode == UIDatePickerModeDateAndTime){
        
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        if (self.isCheckDate == YES) {
            
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            
            self.pickerDate = self.CheckDate;
        }
        else{
            
            _dateString = [dateformatter stringFromDate:senddate];
            
            self.pickerDate = senddate;
        }
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        
    }
}

- (void)show
{
    [self assignTheNecessaryValue];
    [self createToolbar];
    if (_pickerMode < 0) {
        [self createPickerView];
        [self addSubview:_pickerView];
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        [self createPickerView];
        [self addSubview:_pickerView];
    }
    else{
        [self creatDatePickerView];
        [self addSubview:_datePickerView];
    }
    [self addSubview:_toolBar];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.toolBar.frame = CGRectMake(0, ScreenHeight - 280 - 44, ScreenWidth, 44);
        if (weakSelf.pickerMode < 0) {
            weakSelf.pickerView.frame = CGRectMake(0, ScreenHeight - 280, ScreenWidth, 280);
        } else if (weakSelf.pickerType == PickerType_DateAndMeridiem) {
            // 日期 + AM/PM
            weakSelf.pickerView.frame = CGRectMake(0, ScreenHeight - 280, ScreenWidth, 280);
        } else{
            weakSelf.datePickerView.frame = CGRectMake(0, ScreenHeight - 280, ScreenWidth, 280);
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)remove
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.toolBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 44);
        if (weakSelf.pickerMode < 0) {
            weakSelf.pickerView.frame = CGRectMake(0, weakSelf.toolBar.frame.origin.y + weakSelf.toolBar.frame.size.height, ScreenWidth, 280);
        } else if (weakSelf.pickerType == PickerType_DateAndMeridiem) {
            // 日期 + AM/PM
            weakSelf.pickerView.frame = CGRectMake(0, weakSelf.toolBar.frame.origin.y + weakSelf.toolBar.frame.size.height, ScreenWidth, 280);
        } else{
            weakSelf.datePickerView.frame = CGRectMake(0, weakSelf.toolBar.frame.origin.y + weakSelf.toolBar.frame.size.height, ScreenWidth, 280);
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}

- (void)createPickerView
{
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, _toolBar.frame.origin.y + _toolBar.frame.size.height, ScreenWidth, 280)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    
    //判断是否为频率选择器
    if (self.pickerType == PickerType_frequency) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"frequency" ofType:@"plist"];
        self.frequencyDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        self.frequencyArray = @[@"永不",@"每天",@"每周",@"每月",@"每年"];
        self.rangeArray = [self.frequencyDictionary objectForKey:[self.frequencyArray objectAtIndex:0]];
        
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        //日期 + AM/PM
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyyMM";
        
        NSInteger allDays = [self totaldaysInMonth:[NSDate date]];
        for (int i = 1; i <= allDays; i++) {
            NSString *strDay = [NSString stringWithFormat:@"%2i日", i];
            [self.arrayDays addObject:strDay];
        }
        
        //  更新年
        NSInteger currentYear = [[NSDate date] getYear];
        NSString *strYear = [NSString stringWithFormat:@"%4li年", (long)currentYear];
        NSInteger indexYear = [self.arrayYears indexOfObject:strYear];
        if (indexYear == NSNotFound) {
            indexYear = 0;
        }
        [_pickerView selectRow:indexYear inComponent:0 animated:YES];
        self.strYear = self.arrayYears[indexYear];;
        
        //  更新月份
        NSInteger currentMonth = [[NSDate date] getMonth];
        NSString *strMonth = [NSString stringWithFormat:@"%2li月", (long)currentMonth];
        NSInteger indexMonth = [self.arrayMonths indexOfObject:strMonth];
        if (indexMonth == NSNotFound) {
            indexMonth = 0;
        }
        [_pickerView selectRow:indexMonth inComponent:1 animated:YES];
        self.strMonth = self.arrayMonths[indexMonth];
        
        //  更新日
        NSInteger currentDay = [[NSDate date] getDay];
        NSString *strDay = [NSString stringWithFormat:@"%2li日", (long)currentDay];
        NSInteger indexDay = [self.arrayDays indexOfObject:strDay];
        if (indexDay == NSNotFound) {
            indexDay = 0;
        }
        [_pickerView selectRow:indexDay inComponent:2 animated:YES];
        self.strDay = self.arrayDays[indexDay];
        
        self.meridiemArray = @[@"上午",@"下午"];
        //[_pickerView selectRow:0 inComponent:3 animated:YES];
    }
}

- (void)creatDatePickerView
{
    _datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, _toolBar.frame.origin.y + _toolBar.frame.size.height, ScreenWidth, 280)];
     [_datePickerView   setTimeZone:[NSTimeZone defaultTimeZone]];
    _datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //滚动datePicker到指定日期,self.CheckDate 可能为空,为空时会崩溃
    if (self.isCheckDate == YES && self.CheckDate) {
        NSLog(@"ddd");
        [_datePickerView setDate:self.CheckDate animated:YES];
    }
    _datePickerView.datePickerMode = self.pickerMode;
    _datePickerView.backgroundColor = [UIColor whiteColor];
    NSLog(@"pickerMode == %ld",(long)_datePickerView.datePickerMode);
    
    [_datePickerView setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [_datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)createToolbar
{
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 60)];
    
    UIImageView * toolbarBackgroundView = [[UIImageView alloc] initWithFrame:_toolBar.bounds];
    toolbarBackgroundView.image = [UIImage imageNamed:@"toolbar"];
    [_toolBar addSubview:toolbarBackgroundView];
    
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 7, 68, 60-7);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:cancelButton];
    
    UIButton * doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(ScreenWidth - 68, 7, 68, 60-7);
    [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [doneButton setTitleColor:Color(0, 119, 255) forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [doneButton addTarget:self action:@selector(makeSureAction) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:doneButton];
}

#pragma mark UIPickerViewDataSource 处理方法

// 返回显示的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    if (self.pickerType == PickerType_frequency) {
        return 2;
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        return 4;
    } else{
        return [_dataSouceDict count];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickerType == PickerType_frequency) {
        
        if (component == 0) {
            return [self.frequencyArray count];
        }else{
            return [self.rangeArray count];
        }
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        if (component == 0) {
            return self.arrayYears.count;
        } else if (component == 1) {
            return self.arrayMonths.count;
        } else if (component == 2){
            return self.arrayDays.count;
        } else {
            return self.meridiemArray.count;
        }
    } else{
        return [[_dataSouceDict objectForKey:@"pickerContent"] count];
    }
}

#pragma mark --- UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (_pickerType == PickerType_frequency) {
        if (component == 0) {
            return [self.frequencyArray objectAtIndex:row];
        }else{
            return [self.rangeArray objectAtIndex:row];
        }
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        if (component == 0) {
            return self.arrayYears[row];
        } else if (component == 1) {
            return self.arrayMonths[row];
        } else if (component == 2){
            return self.arrayDays[row];
        } else {
            return self.meridiemArray[row];
        }
    }
    return @"";
}

#pragma mark UIPickerViewDelegate 处理方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerType == PickerType_frequency) {
        if (component == 0) {
            self.rangeArray = [self.frequencyDictionary objectForKey:[self.frequencyArray objectAtIndex:row]];
            //NSLog(@"self.rangeArray = %@",self.rangeArray);
        }
        [pickerView reloadComponent:1];
        self.dateUnitString = [NSString stringWithFormat:@"%ld",(long)[_pickerView selectedRowInComponent:0] ];
        self.dateRateString = [NSString stringWithFormat:@"%ld",(long)[_pickerView selectedRowInComponent:1] ];
        //NSLog(@"频率选择器控件 = %@,%@",self.dateUnitString,self.dateRateString);
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        if (component == 0) {
            self.strYear = self.arrayYears[row];
        } else if (component == 1) {
            self.strMonth = self.arrayMonths[row];
        } else if (component == 2){
            self.strDay = self.arrayDays[row];
        } else {
            
        }
        [self updateLabelText];
        
        if (component != 2) {
            NSString *strDate = [NSString stringWithFormat:@"%@%@", self.strYear, self.strMonth];
            [self upDateCurrentAllDaysWithDate:[self.dateFormatter dateFromString:strDate]];
        }
    }
}

#pragma mark datePickerView 值改变回调方法
- (void)dateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    if (_pickerMode == UIDatePickerModeTime) {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    else if (_pickerMode == UIDatePickerModeDate){
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if (_pickerType == PickerType_pruductDate) {
            
            _datePickerView.maximumDate = [NSDate date];
            
        }else if (_pickerType == PickerType_endDate){
            //最小日期
            _datePickerView.minimumDate = [NSDate date];
            _datePickerView.maximumDate = self.maxDate;
            
        }else if (_pickerType == PickerType_warrantyDate){
            
            _datePickerView.minimumDate = self.minDate;
            
        }
        
    }
    else if (_pickerType == PickerType_AnyDate){
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
    }
    _dateString = [dateFormatter stringFromDate:datePicker.date];
    
    self.pickerDate = datePicker.date;
    NSLog(@"未改变的日期 = %@,date = %@",_dateString,datePicker.date);
}

#pragma mark - Actions
- (void)cancelAction
{
    [self remove];
}

- (void)makeSureAction
{
    NSString * paramStr = @"";
    if (_pickerType == PickerType_AnyDate) // 判断是否是DatePicker
    {
        paramStr = _dateString;
    }
    else{
        paramStr = _dateString;
    }
    
    [_delegate callbackForConfirmWithParamStr:self Param:paramStr];
    
    [self remove];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self remove];
}

#pragma mark - Lazy
- (NSMutableArray *)arrayYears{
    if (!_arrayYears) {
        _arrayYears = [NSMutableArray array];
        for (int i = 1; i < 10000; i++) {
            NSString *strYear = [NSString stringWithFormat:@"%4i年", i];
            [_arrayYears addObject:strYear];
        }
    }
    return _arrayYears;
}

- (NSMutableArray *)arrayMonths{
    if (!_arrayMonths) {
        _arrayMonths = [NSMutableArray array];
        for (int i = 1; i <= 12; i++) {
            NSString *str = [NSString stringWithFormat:@"%2i月", i];
            [_arrayMonths addObject:str];
        }
    }
    return _arrayMonths;
}

- (NSMutableArray *)arrayDays{
    if (!_arrayDays) {
        _arrayDays = [NSMutableArray array];
    }
    return _arrayDays;
}

#pragma mark - 计算出当月有多少天
- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInOfMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInOfMonth.length;
}

- (void)upDateCurrentAllDaysWithDate:(NSDate *)currentDate
{
    [self.arrayDays removeAllObjects];
    
    NSInteger allDays = [self totaldaysInMonth:currentDate];
    for (int i = 1; i <= allDays; i++) {
        NSString *strDay = [NSString stringWithFormat:@"%02i", i];
        [self.arrayDays addObject:strDay];
    }
    
    [_pickerView reloadComponent:2];
    
    //  更新日
    NSInteger indexDay = [self.arrayDays indexOfObject:self.strDay];
    if (indexDay == NSNotFound) {
        indexDay = (self.arrayDays.count - 1) > 0 ? (self.arrayDays.count - 1) : 0;
    }
    [_pickerView selectRow:indexDay inComponent:2 animated:YES];
    self.strDay = self.arrayDays[indexDay];
    
    [self updateLabelText];
}

#pragma mark - 更新当前label的日期
- (void)updateLabelText
{
    NSString *dataString = [NSString stringWithFormat:@"%@年%@月%@日", self.strYear, self.strMonth, self.strDay];
}

@end
