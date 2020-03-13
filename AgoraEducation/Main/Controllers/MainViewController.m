//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "EyeCareModeUtil.h"
#import "NSString+MD5.h"
#import "UIView+Toast.h"

#import "OneToOneViewController.h"
#import "MCViewController.h"
#import "BCViewController.h"

@interface MainViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) BaseEducationManager *educationManager;
@end

@implementation MainViewController

#pragma mark LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self addTouchedRecognizer];
    [self addNotification];
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
}

#pragma mark Private Function
- (void)setupView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;
    
    self.userNameTextFiled.delegate = self;
    self.passwordTextFiled.delegate = self;
}

- (void)addTouchedRecognizer {
    UITapGestureRecognizer *touchedControl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBegan:)];
    [self.baseView addGestureRecognizer:touchedControl];
}
- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.userNameTextFiled resignFirstResponder];
    [self.passwordTextFiled resignFirstResponder];
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

- (BOOL)checkFieldText:(NSString *)text {
    int strlength = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    if(strlength <= 20){
        return YES;
    } else {
       return NO;
    }
}

- (IBAction)joinRoom:(UIButton *)sender {

    self.userNameTextFiled.text = @"JerrySrs";
    self.passwordTextFiled.text = @"TX3vvY";
    
    NSString *userName = self.userNameTextFiled.text;
    NSString *password = self.passwordTextFiled.text;
    
    if (userName.length <= 0
        || password.length <= 0
        || ![self checkFieldText:userName]) {
        
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"UserNameVerifyText", nil)];
        return;
    }

    EduConfigModel.shareInstance.userName = userName;
    EduConfigModel.shareInstance.password = password;

    WEAK(self);
    [self getConfigWithSuccessBolck:^{
        [weakself getEntryInfoWithSuccessBolck:^{
            [weakself getRoomInfoWithSuccessBlock:^{
                [weakself setupSignalWithSuccessBolck:^{
                    if(EduConfigModel.shareInstance.sceneType == SceneType1V1) {
                        [weakself join1V1RoomWithIdentifier:@"oneToOneRoom"];
                    } else if(EduConfigModel.shareInstance.sceneType == SceneTypeSmall){
                        [weakself joinMinRoomWithIdentifier:@"mcRoom"];
                    } else if(EduConfigModel.shareInstance.sceneType == SceneTypeBig){
                        [weakself joinBigRoomWithIdentifier:@"bcroom"];
                    }
                }];
            }];
        }];
    }];
}

- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
        [self.joinButton setEnabled:NO];
    } else {
        [self.activityIndicator stopAnimating];
        [self.joinButton setEnabled:YES];
    }
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)join1V1RoomWithIdentifier:(NSString*)identifier {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
    OneToOneViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.educationManager = (OneToOneEducationManager*)self.educationManager;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)joinMinRoomWithIdentifier:(NSString*)identifier {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
    MCViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.educationManager = (MinEducationManager*)self.educationManager;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)joinBigRoomWithIdentifier:(NSString*)identifier {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
    BCViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.educationManager = (BigEducationManager*)self.educationManager;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark EnterClassProcess
- (void)getConfigWithSuccessBolck:(void (^)(void))successBlock {
    
    WEAK(self);
    [self setLoadingVisible:YES];
    [BaseEducationManager getConfigWithSuccessBolck:^{
        [weakself setLoadingVisible:NO];
        if(successBlock != nil){
            successBlock();
        }
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself.view makeToast:errMessage];
        [weakself setLoadingVisible:NO];
    }];
}

- (void)getEntryInfoWithSuccessBolck:(void (^)(void))successBlock {
    WEAK(self);
    [self setLoadingVisible:YES];
    
    NSString *userName = EduConfigModel.shareInstance.userName;
    NSString *password = EduConfigModel.shareInstance.password;
    
    [BaseEducationManager enterRoomWithUserName:userName password:password successBolck:^{
        
        [weakself setLoadingVisible:NO];
        
        if(EduConfigModel.shareInstance.sceneType == SceneType1V1) {
            weakself.educationManager = [OneToOneEducationManager new];
        } else if(EduConfigModel.shareInstance.sceneType == SceneTypeSmall){
            weakself.educationManager = [MinEducationManager new];
        } else if(EduConfigModel.shareInstance.sceneType == SceneTypeBig){
            weakself.educationManager = [BigEducationManager new];
        }
        if(successBlock != nil){
            successBlock();
        }

    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself.view makeToast:errMessage];
        [weakself setLoadingVisible:NO];
    }];
}

- (void)getRoomInfoWithSuccessBlock:(void (^)(void))successBlock {
    WEAK(self);
    [self setLoadingVisible:YES];
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        [weakself setLoadingVisible:NO];
        if(successBlock != nil){
            successBlock();
        }
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself.view makeToast:errMessage];
        [weakself setLoadingVisible:NO];
    }];
}

- (void)setupSignalWithSuccessBolck:(void (^)(void))successBlock {

    NSString *appid = EduConfigModel.shareInstance.appId;
    NSString *appToken = EduConfigModel.shareInstance.rtmToken;
    NSString *uid = @(EduConfigModel.shareInstance.uid).stringValue;
    
    WEAK(self);
    [self.educationManager initSignalWithAppid:appid appToken:appToken userId:uid dataSourceDelegate:nil completeSuccessBlock:^{
        
        NSString *channelName = EduConfigModel.shareInstance.channelName;
        [weakself.educationManager joinSignalWithChannelName:channelName completeSuccessBlock:^{
            if(successBlock != nil){
                successBlock();
            }
            
        } completeFailBlock:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"JoinSignalFailedText", nil), (long)errorCode];
            [weakself.view makeToast:errMsg];
        }];
        
    } completeFailBlock:^(NSInteger errorCode){
        NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"InitSignalFailedText", nil), (long)errorCode];
        [weakself.view makeToast:errMsg];
    }];
}

@end
