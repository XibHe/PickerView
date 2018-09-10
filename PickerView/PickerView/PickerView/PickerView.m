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

@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIImageView *toolbarBackgroundView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIDatePicker *datePickerView; // 时间日期选择器
@property (nonatomic, strong) UIPickerView *pickerView;     // 自定义选择器


// 自定义频率选择器数据源
@property (nonatomic, strong) NSDictionary *frequencyDictionary;
@property (nonatomic ,strong) NSArray *frequencyArray;
@property (nonatomic ,strong) NSArray *rangeArray;

// 自定义日期+AM选择器数据源
@property (nonatomic, strong) NSMutableArray *arrayYears;
@property (nonatomic, strong) NSMutableArray *arrayMonths;
@property (nonatomic, strong) NSMutableArray *arrayDays;
@property (nonatomic, strong) NSArray *meridiemArray;
@property (nonatomic, copy) NSString *strYear;      //  年
@property (nonatomic, copy) NSString *strMonth;     //  月
@property (nonatomic, copy) NSString *strDay;       //  日
@property (nonatomic, copy) NSString *strMeridiem;  // AM/PM
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) NSString *dateAndMeridiemString;  // 处理后回传的 日期+AM/PM

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
        } else{
            _dateString = [dateformatter stringFromDate:senddate];
            self.pickerDate = senddate;
        }
    } else if (_pickerMode == UIDatePickerModeTime) {
        [dateformatter setDateFormat:@"HH:mm"];
        //显示已选的日期
        if (self.isCheckDate == YES) {
            //[dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            NSLog(@"已选的时间点 = %@",self.CheckDate);
            self.pickerDate = self.CheckDate;
        } else{
            _dateString = [dateformatter stringFromDate:senddate];
            self.pickerDate = senddate;
        }
    } else if (_pickerMode == UIDatePickerModeDate){
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        //显示已选的日期
        if (self.isCheckDate == YES) {
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            self.pickerDate = self.CheckDate;
        } else{
            _dateString = [dateformatter stringFromDate:senddate];
            self.pickerDate = senddate;
        }
    } else if (_pickerMode == UIDatePickerModeDateAndTime){
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        if (self.isCheckDate == YES) {
            _dateString = [dateformatter stringFromDate:self.CheckDate];
            self.pickerDate = self.CheckDate;
        } else{
            if (_minuteInterval == 10) {
                // 当分钟的间隔为 10 时，将分钟取整。eg. 08:13 取整 为 08:10
                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:senddate];
                NSInteger minutes = [dateComponents minute];
                NSInteger minutesRounded = ( (NSInteger)(minutes / 10) ) * 10;
                NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:senddate];
                _dateString = [dateformatter stringFromDate:roundedDate];
                self.pickerDate = roundedDate;
            } else {
                _dateString = [dateformatter stringFromDate:senddate];
                self.pickerDate = senddate;
            }
        }
    }
}

- (void)show
{
    [self assignTheNecessaryValue];
    [self createToolbar];
    
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
        self.strMeridiem = @"上午";
        //[_pickerView selectRow:0 inComponent:3 animated:YES];
    }
    
    // 默认选中已经选中的类型
    if (self.isCheckDate && self.selectType) {
        self.dateUnitString = [NSString stringWithFormat:@"%ld",self.selectType];
        [_pickerView selectRow:_selectType inComponent:0 animated:NO];
    }
}

- (void)creatDatePickerView
{
//    _datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, _toolBar.frame.origin.y + _toolBar.frame.size.height, ScreenWidth, 280)];
//     [_datePickerView   setTimeZone:[NSTimeZone defaultTimeZone]];
//    _datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//
//    // 设置 UIDatePicker 的 minuteInterval
//    if (_pickerMode == UIDatePickerModeDateAndTime && _minuteInterval == 10) {
//        _datePickerView.minuteInterval = 10;
//    }
//
//    //滚动datePicker到指定日期,self.CheckDate 可能为空,为空时会崩溃
//    if (self.isCheckDate == YES && self.CheckDate) {
//        NSLog(@"ddd");
//        [_datePickerView setDate:self.CheckDate animated:YES];
//    }
//    _datePickerView.datePickerMode = self.pickerMode;
//    _datePickerView.backgroundColor = [UIColor whiteColor];
//    NSLog(@"pickerMode == %ld",(long)_datePickerView.datePickerMode);
//
//    [_datePickerView setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
//    [_datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)createToolbar
{
    [self addSubview:self.toolBar];
    [_toolBar addSubview:self.toolbarBackgroundView];
    [_toolBar addSubview:self.cancelButton];
    [_toolBar addSubview:self.sureButton];
    
    if (_pickerMode < 0) {
        [self createPickerView];
        [self addSubview:self.pickerView];
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        [self createPickerView];
        [self addSubview:self.pickerView];
    } else{
        [self addSubview:self.datePickerView];
    }
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
        }
        [pickerView reloadComponent:1];
        self.dateUnitString = [NSString stringWithFormat:@"%ld",(long)[_pickerView selectedRowInComponent:0] ];
        self.dateRateString = [NSString stringWithFormat:@"%ld",(long)[_pickerView selectedRowInComponent:1] ];
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        if (component == 0) {
            self.strYear = self.arrayYears[row];
        } else if (component == 1) {
            self.strMonth = self.arrayMonths[row];
        } else if (component == 2){
            self.strDay = self.arrayDays[row];
        } else {
            self.strMeridiem = self.meridiemArray[row];
        }
        [self updateLabelText];
        
        if (component != 2 && component != 3) {
            
            // 去除时间字符串格式中的汉字
            self.strYear = [self.strYear stringByReplacingOccurrencesOfString:@"年" withString:@""];
            self.strMonth = [self.strMonth stringByReplacingOccurrencesOfString:@"月" withString:@""];
            if ([self.strMonth integerValue] < 10) {
                if ([self.strMonth containsString:@"0"]) {
                    // 不进行操作
                } else {
                  self.strMonth = [NSString stringWithFormat:@"0%@",self.strMonth];
                }
            }
            
            NSString *strDate = [NSString stringWithFormat:@"%@%@", self.strYear, self.strMonth];
            strDate = [strDate stringByReplacingOccurrencesOfString:@" " withString:@""];
        
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
    } else if (_pickerMode == UIDatePickerModeDate){
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if (_pickerType == PickerType_leaveDate) {
            
            _datePickerView.maximumDate = [NSDate date];
            
        }else if (_pickerType == PickerType_endDate){
            //最小日期
            _datePickerView.minimumDate = [NSDate date];
            _datePickerView.maximumDate = self.maxDate;
        }
    } else if (_pickerType == PickerType_leaveDate) {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        _datePickerView.minimumDate = [NSDate date];
    } else if (_pickerType == PickerType_AnyDate){
        
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
    if (_pickerType == PickerType_frequency) // 判断是否是DatePicker
    {
        paramStr = _dateUnitString;
    } else if (_pickerType == PickerType_DateAndMeridiem) {
        // 日期 + AM/PM
        paramStr = [_dateAndMeridiemString stringByReplacingOccurrencesOfString:@"- " withString:@"-0"];
    } else {
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
//- (UIPickerView *)pickerView{
//    if (!_pickerView) {
//        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, _toolBar.frame.origin.y + _toolBar.frame.size.height, ScreenWidth, 280)];
//        _pickerView.backgroundColor = [UIColor whiteColor];
//        _pickerView.delegate = self;
//        _pickerView.dataSource = self;
//        _pickerView.showsSelectionIndicator = YES;
//    }
//    return _pickerView;
//}

- (UIDatePicker *)datePickerView{
    //             weakSelf.datePickerView.frame = CGRectMake(0, ScreenHeight - 280, ScreenWidth, 280);
    if (!_datePickerView) {
        _datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, _toolBar.frame.origin.y + _toolBar.frame.size.height, ScreenWidth, 280)];
        [_datePickerView  setTimeZone:[NSTimeZone defaultTimeZone]];
        _datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        // 设置 UIDatePicker 的 minuteInterval
        if (_pickerMode == UIDatePickerModeDateAndTime && _minuteInterval == 10) {
            _datePickerView.minuteInterval = 10;
        }
        
        //滚动datePicker到指定日期,self.CheckDate 可能为空,为空时会崩溃
        if (self.isCheckDate == YES && self.CheckDate) {
            NSLog(@"ddd");
            [_datePickerView setDate:self.CheckDate animated:YES];
        }
        _datePickerView.datePickerMode = self.pickerMode;
        _datePickerView.backgroundColor = [UIColor whiteColor];
        //NSLog(@"pickerMode == %ld",(long)_datePickerView.datePickerMode);
        
        [_datePickerView setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [_datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePickerView;
}

- (UIView *)toolBar{
    if (!_toolBar) {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 60)];
    }
    return _toolBar;
}

- (UIImageView *)toolbarBackgroundView {
    if (!_toolbarBackgroundView) {
        _toolbarBackgroundView = [[UIImageView alloc] initWithFrame:_toolBar.bounds];
        _toolbarBackgroundView.image = [UIImage imageNamed:@"toolbar"];
    }
    return _toolbarBackgroundView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, 68, 60);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(ScreenWidth - 68, 0, 68, 60);
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:Color(0, 119, 255) forState:UIControlStateNormal];
        _sureButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_sureButton addTarget:self action:@selector(makeSureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

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
        NSString *strDay = [NSString stringWithFormat:@"%2i日", i];
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
    //NSString *dataString = [NSString stringWithFormat:@"%@年%@月%@日", self.strYear, self.strMonth, self.strDay];
    
    _dateAndMeridiemString = [NSString stringWithFormat:@"%@-%@-%@  %@",[self.strYear stringByReplacingOccurrencesOfString:@"年" withString:@""],[self.strMonth stringByReplacingOccurrencesOfString:@"月" withString:@""],[self.strDay stringByReplacingOccurrencesOfString:@"日" withString:@""],self.strMeridiem];
}

@end
