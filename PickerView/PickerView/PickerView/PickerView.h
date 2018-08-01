//
//  PickerView.h
//  Steward
//
//  Created by Peng he on 15/8/31.
//  Copyright (c) 2015年 ChengpinKuaipai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerView;
@protocol PickerViewDelegare;
typedef enum
{
    PickerType_leaveDate        = 0,     // 请假日期
    PickerType_endDate          = 1,     // 结束日期
    PickerType_frequency        = 2,     // 频率选择器
    PickerType_AnyDate          = 3,     // 任意日期
    PickerType_DateAndMeridiem  = 4      // 日期 + AM/PM
    
}PickerType;

typedef void (^PickerViewBlock)(PickerView *pickerView);

@interface PickerView : UIView<UIPickerViewDelegate , UIPickerViewDataSource>

@property (nonatomic, copy) PickerViewBlock  pickerViewBlock;



@property (nonatomic, assign) id <PickerViewDelegare> delegate;
@property (nonatomic, assign) UIDatePickerMode pickerMode; // Time || Date 模式 如果没有，则赋值为-1
//@property (nonatomic , retain) NSArray * argArray;
//@property (nonatomic , retain) NSString * selectNum; // 保存非省名和地名的单条字符串

@property (nonatomic, strong) NSDictionary * dataSouceDict;// pickerView数据源
@property (nonatomic, copy) NSString * dateString; // 保存 Time || Date
@property (nonatomic, strong) NSDate * pickerDate; // 保存选择的时间或日期
@property (nonatomic, assign) PickerType pickerType;

//判断是否日期是否已经选择
@property (nonatomic, assign) BOOL isCheckDate;
@property (nonatomic, strong) NSDate *CheckDate;

// 非日期已选中的type值
@property (nonatomic, assign) NSInteger selectType;

//"到期日"最大不超过的日期
@property (nonatomic, strong) NSDate * maxDate;     // 最大日期
@property (nonatomic, strong) NSDate * minDate;     // 最小日期

@property (nonatomic, copy) NSString *dateUnitString;
@property (nonatomic, copy) NSString *dateRateString;

// minuteInterval
@property (nonatomic, assign) NSInteger minuteInterval;

- (void)show;
- (void)remove;

@end

@protocol PickerViewDelegare <NSObject>

- (void)callbackForConfirmWithParamStr:(PickerView *)myPickerView Param:(NSString *)paramStr;

@end
