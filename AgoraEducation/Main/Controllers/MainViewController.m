//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "EEClassRoomTypeView.h"
#import "SettingViewController.h"
#import "GenerateSignalBody.h"
#import "EyeCareModeUtil.h"

#import "MinEducationManager.h"
#import "BigEducationManager.h"

#import "OneToOneViewController.h"
#import "MCViewController.h"
#import "BCViewController.h"

#import "NSString+MD5.h"
#import "KeyCenter.h"

#import "HttpManager.h"
#import "ConfigModel.h"
#import "EnterRoomAllModel.h"
#import "UIView+Toast.h"

@interface MainViewController ()<EEClassRoomTypeDelegate, SignalDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet UIButton *roomType;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic, weak) EEClassRoomTypeView *classRoomTypeView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;

@property (nonatomic, strong) ConfigInfoModel *configInfoModel;
@property (nonatomic, strong) EnterRoomInfoModel *enterRoomInfoModel;

@end

@implementation MainViewController

#pragma mark LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addTouchedRecognizer];
    [self addNotification];
}

- (void)initData {
    
    WEAK(self);
    [self.activityIndicator startAnimating];
    [self.joinButton setEnabled:NO];
    [HttpManager get:HTTP_GET_CONFIG params:nil success:^(id responseObj) {
        
        ConfigModel *model = [ConfigModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            
            weakself.configInfoModel = model.data;
            [KeyCenter setAgoraAppid:model.data.appId];
            
        } else {
            [weakself showHTTPToast:model.msg];
        }
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
        
    } failure:^(NSError *error) {
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
        
        [weakself showHTTPToast:@"Network request failed"];
        NSLog(@"HTTP GET CONFIG ERROR:%@", error.description);
    }];
}

- (void)showHTTPToast:(NSString *)title {
    if(title == nil || title.length == 0){
        title = @"Network request failed";
    }
    [self.view makeToast:title];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]) {
        [[EyeCareModeUtil sharedUtil] switchEyeCareMode:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [self.educationManager releaseResources];
}

#pragma mark Private Function
- (void)setupView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;
    
    EEClassRoomTypeView *classRoomTypeView = [EEClassRoomTypeView initWithXib:CGRectMake(30, kScreenHeight - 300, kScreenWidth - 60, 150)];
    [self.view addSubview:classRoomTypeView];
    self.classRoomTypeView = classRoomTypeView;
    classRoomTypeView.hidden = YES;
    classRoomTypeView.delegate = self;
}

- (void)addTouchedRecognizer {
    UITapGestureRecognizer *touchedControl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBegan:)];
    [self.baseView addGestureRecognizer:touchedControl];
}
- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
    self.classRoomTypeView.hidden  = YES;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textViewBottomCon.constant = bottom;
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.textViewBottomCon.constant = 261;
}

- (BOOL)checkClassRoomText:(NSString *)text {
    NSString *regex = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:text] && text.length <= 11) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Click Event
- (IBAction)popupRoomType:(UIButton *)sender {
    self.classRoomTypeView.hidden = NO;
}

- (IBAction)joinRoom:(UIButton *)sender {
    
    self.classNameTextFiled.text = @"Test1";
    self.userNameTextFiled.text = @"Jerry";
    
    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0 || ![self checkClassRoomText:self.classNameTextFiled.text] || ![self checkClassRoomText:self.userNameTextFiled.text]) {
        
        [AlertViewUtil showAlertWithController:self title:@"User name must be within 11 digits or English characters"];
        return;
    }
    
    NSArray<NSString*> *roomTypeStrings = @[@"One-to-One", @"Small Class", @"Large Class"];
    if(![roomTypeStrings containsObject:self.roomType.titleLabel.text]) {
        [AlertViewUtil showAlertWithController:self title:@"Please select a room type"];
        return;
    }
    
    [self.activityIndicator startAnimating];
    [self.joinButton setEnabled:YES];
    
    NSString *url = [NSString stringWithFormat:HTTP_POST_ENTER_ROOM, [KeyCenter agoraAppid]];
    
    NSString *roomType = self.roomType.titleLabel.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userName"] = self.userNameTextFiled.text;
    params[@"roomName"] = self.classNameTextFiled.text;
    params[@"type"] = @([roomTypeStrings indexOfObject:roomType] + 1);
    params[@"role"] = @(2);
    
    WEAK(self);
    [HttpManager post:url params:params success:^(id responseObj) {
        
        EnterRoomAllModel *model = [EnterRoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            
            weakself.enterRoomInfoModel = model.data;
            [KeyCenter setWhiteBoardToken:weakself.enterRoomInfoModel.room.whiteToken];
            [KeyCenter setAgoraRTMToken:weakself.enterRoomInfoModel.user.rtmToken];
            [KeyCenter setAgoraRTCToken:weakself.enterRoomInfoModel.user.rtcToken];
        
            if ([roomTypeStrings indexOfObject:roomType] == 0 ){
                [weakself join1V1RoomWithIdentifier:@"oneToOneRoom"];
            } else if ([roomTypeStrings indexOfObject:roomType] == 1 ){
                [weakself joinMinRoomWithIdentifier:@"mcRoom"];
            } else if ([roomTypeStrings indexOfObject:roomType] == 2 ){
                [weakself joinBigRoomWithIdentifier:@"bcroom"];
            }
            
        } else {
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
            [weakself showHTTPToast:model.msg];
        }
        
    } failure:^(NSError *error) {
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
        
        [weakself showHTTPToast:@"Network request failed"];
        NSLog(@"HTTP GET CONFIG ERROR:%@", error.description);
    }];
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}


- (void)join1V1RoomWithIdentifier:(NSString*)identifier {
    
    NSInteger maxCount = self.configInfoModel.oneToOneStudentLimit.integerValue;
    NSString *channelName = self.enterRoomInfoModel.room.channelName;
    NSString *uid = @(self.enterRoomInfoModel.user.uid).stringValue;

    WEAK(self);
    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = uid;
    OneToOneEducationManager *educationManager = [OneToOneEducationManager new];
    [educationManager initSignalWithModel:model dataSourceDelegate:nil completeSuccessBlock:^{
        
        [educationManager queryOnlineStudentCountWithChannelName:channelName maxCount:maxCount completeSuccessBlock:^(NSInteger count) {
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
            
            if (count < maxCount) {
                
                VCParamsModel *paramsModel = [weakself generateVCParamsModel];
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
                OneToOneViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.paramsModel = paramsModel;
                vc.educationManager = educationManager;
                [weakself presentViewController:vc animated:YES completion:nil];
                
            } else {
                [AlertViewUtil showAlertWithController:self title:@"The number is full, please change room name"];
            }
            
        } completeFailBlock:^{
            [weakself showHTTPToast:@"query online student count error"];
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
        }];
        
        
    } completeFailBlock:^{
        
        [weakself showHTTPToast:@"init signal error"];
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
    }];
}

- (VCParamsModel*)generateVCParamsModel {
    
    NSString *className = self.classNameTextFiled.text;
    NSString *userName = self.userNameTextFiled.text;
    
    NSString *channelName = self.enterRoomInfoModel.room.channelName;
    NSString *userId = [NSNumber numberWithInteger:self.enterRoomInfoModel.user.uid].stringValue;
    NSString *userToken = self.enterRoomInfoModel.user.userToken;
    NSString *roomid = @(self.enterRoomInfoModel.room.roomId).stringValue;
    
    VCParamsModel *paramsModel = [VCParamsModel new];
    paramsModel.className = className;
    paramsModel.userName = userName;
    paramsModel.channelName = channelName;
    paramsModel.userId = userId;
    paramsModel.userToken = userToken;
    paramsModel.roomId = roomid;
    
    return paramsModel;
}

- (void)joinMinRoomWithIdentifier:(NSString*)identifier {
    
    NSInteger maxCount = self.configInfoModel.smallClassStudentLimit.integerValue;
    NSString *channelName = self.enterRoomInfoModel.room.channelName;
    NSString *uid = [NSNumber numberWithInteger:self.enterRoomInfoModel.user.uid].stringValue;

    WEAK(self);
    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = uid;
    MinEducationManager *educationManager = [MinEducationManager new];
    [educationManager initSignalWithModel:model dataSourceDelegate:nil completeSuccessBlock:^{
        
        [educationManager queryOnlineStudentCountWithChannelName:channelName maxCount:maxCount completeSuccessBlock:^(NSInteger count) {
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
            
            if (count < maxCount) {
                
                VCParamsModel *paramsModel = [weakself generateVCParamsModel];
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
                MCViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.paramsModel = paramsModel;
                vc.educationManager = educationManager;
                [weakself presentViewController:vc animated:YES completion:nil];
                
            } else {
                [AlertViewUtil showAlertWithController:self title:@"Room is full, please change another room"];
            }
            
        } completeFailBlock:^{
            [weakself showHTTPToast:@"query online student count error"];
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
        }];
        
    } completeFailBlock:^{
        
        [weakself showHTTPToast:@"init signal error"];
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
    }];
}

- (void)joinBigRoomWithIdentifier:(NSString*)identifier {
    
    NSInteger maxCount = self.configInfoModel.largeClassStudentLimit.integerValue;
    NSString *channelName = self.enterRoomInfoModel.room.channelName;
    NSString *uid = [NSNumber numberWithInteger:self.enterRoomInfoModel.user.uid].stringValue;

    WEAK(self);
    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = uid;
    BigEducationManager *educationManager = [BigEducationManager new];
    
    [educationManager initSignalWithModel:model dataSourceDelegate:nil completeSuccessBlock:^{
        
        [educationManager queryOnlineStudentCountWithChannelName:channelName maxCount:maxCount completeSuccessBlock:^(NSInteger count) {
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
            
            if (count < maxCount) {
                
                VCParamsModel *paramsModel = [weakself generateVCParamsModel];
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
                BCViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.paramsModel = paramsModel;
                vc.educationManager = educationManager;
                [weakself presentViewController:vc animated:YES completion:nil];
                
            } else {
                [AlertViewUtil showAlertWithController:self title:@"The number is full, please change room name"];
            }
            
        } completeFailBlock:^{
            [weakself showHTTPToast:@"query online student count error"];
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
        }];
        
        
    } completeFailBlock:^{
        
        [weakself showHTTPToast:@"init signal error"];
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
    }];
}

#pragma mark EEClassRoomTypeDelegate
- (void)selectRoomTypeName:(NSString *)name {
    [self.roomType setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
}
@end
