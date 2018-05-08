//
//  ViewController.m
//  PickerView
//
//  Created by Peng he on 2018/5/8.
//  Copyright © 2018年 Peng he. All rights reserved.
//

#import "ViewController.h"
#import "PickerView.h"
#import "DateRateTransform.h"

@interface ViewController () <PickerViewDelegare>
@property (weak, nonatomic) IBOutlet UIButton *starBtn;
@property (weak, nonatomic) IBOutlet UIButton *endButon;
@property (weak, nonatomic) IBOutlet UIButton *frequencyBtn;

@property (nonatomic, strong) NSDate *checkDate;   // 已选中的时间
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
- (IBAction)clickAction:(UIButton *)sender {
    
    PickerView *datePickerView = [[PickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    datePickerView.tag = sender.tag;
    datePickerView.delegate = self;
    
    switch (sender.tag) {
        case 12:
        {//开始时间
            datePickerView.pickerType = PickerType_frequency;
            datePickerView.pickerMode = -1;
        }
            break;
        case 11:
        {// 结束时间
            datePickerView.pickerType = PickerType_AnyDate;
            datePickerView.pickerMode = UIDatePickerModeDate;
        }
            break;
        case 10:
        {// 频率
            datePickerView.pickerType = PickerType_pruductDate;
            datePickerView.pickerMode = UIDatePickerModeDate;
            datePickerView.isCheckDate = YES;
            datePickerView.CheckDate = self.checkDate;
        }
            break;
        default:
            break;
    }
    
    [self.view.superview insertSubview:datePickerView aboveSubview:self.view];
    [datePickerView show];
}

#pragma mark - PickerViewDelegare
- (void)callbackForConfirmWithParamStr:(PickerView *)myPickerView Param:(NSString *)paramStr
{
    if (myPickerView.tag == 10) {
        self.checkDate = myPickerView.CheckDate;
        [self.starBtn setTitle:paramStr forState:UIControlStateNormal];
    } else if (myPickerView.tag == 11) {
        [self.endButon setTitle:paramStr forState:UIControlStateNormal];
    } else if (myPickerView.tag == 12) {
        [self.frequencyBtn setTitle:[DateRateTransform outputFrequencyUnitString:[myPickerView.dateUnitString integerValue] frequencyRate:[myPickerView.dateRateString integerValue]] forState:UIControlStateNormal];
    }
}

@end
