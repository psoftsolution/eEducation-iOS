//
//  OneToOneViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "OneToOneViewController.h"
#import "EENavigationView.h"
#import "EEWhiteboardTool.h"
#import "EEPageControlView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "EEColorShowView.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "UIView+Toast.h"

@interface OneToOneViewController ()<UITextFieldDelegate, RoomProtocol, SignalDelegate, RTCDelegate, EEPageControlDelegate, EEWhiteboardToolDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *chatRoomView;
@property (weak, nonatomic) IBOutlet OTOTeacherView *teacherView;
@property (weak, nonatomic) IBOutlet OTOStudentView *studentView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageListView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

// white
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, assign) NSInteger sceneCount;

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, assign) BOOL hasSignalReconnect;

@end

@implementation OneToOneViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self initData];
    [self addNotification];
}

- (void)initData {
    
    self.hasSignalReconnect = NO;
    
    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;
    
    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    EduConfigModel *configModel = self.educationManager.eduConfigModel;
    self.messageListView.userToken = configModel.userToken;
    self.messageListView.roomId = configModel.roomId;
    self.messageListView.appId = configModel.appId;
    
    NSString *className = configModel.className;
    [self.navigationView updateClassName:className];

    WEAK(self);
    [self.colorShowView setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray = [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        [weakself.educationManager setWhiteStrokeColor:colorArray];
    }];

    // api -> init rtm -> rtc & white
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {

        [weakself setupSignalWithSuccessBolck:^{
            [weakself setupRTC];
            [weakself setupWhiteBoard];

            [weakself updateTimeState];
            [weakself updateChatViews];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself showToast:errMessage];
    }];
}

- (void)updateViewOnReconnected{
    WEAK(self);
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        [weakself updateTimeState];
        [weakself updateChatViews];
        [weakself.educationManager disableCameraTransform:roomInfoModel.room.lockBoard];
        [weakself checkNeedRender];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
 
    }];
}

- (void)showToast:(NSString *)title {
    [self.navigationController.view makeToast:title];
}

- (void)setupView {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
        
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardBaseView addSubview:boardView];
    self.boardView = boardView;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReconnecting) name:NOTICE_KEY_ON_MESSAGE_RECONNECTING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageConnected) name:NOTICE_KEY_ON_MESSAGE_CONNECTED object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.textFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
        self.textFiledBottomCon.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.textFiledWidthCon.constant = 222;
    self.textFiledBottomCon.constant = 0;
}

- (void)onMessageReconnecting {
    self.hasSignalReconnect = YES;
}
-(void)onMessageConnected {
    if(self.hasSignalReconnect){
        self.hasSignalReconnect = NO;
        [self updateViewOnReconnected];
    }
}

- (void)setupWhiteBoard {
    
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];
    
    RoomModel *roomModel = self.educationManager.roomModel;
    WEAK(self);
    [self.educationManager joinWhiteRoomWithBoardId:roomModel.boardId boardToken:roomModel.boardToken whiteWriteModel:YES  completeSuccessBlock:^(WhiteRoom * _Nullable room) {
    
        [weakself.educationManager disableCameraTransform:roomModel.lockBoard];
        [weakself.educationManager disableWhiteDeviceInputs:NO];
        [weakself.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
            weakself.sceneCount = sceneCount;
            weakself.sceneIndex = sceneIndex;
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
            [weakself.educationManager moveWhiteToContainer:sceneIndex];
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        
        [weakself showToast:NSLocalizedString(@"JoinWhiteErrorText", nil)];
    }];
}

- (void)updateTeacherViews:(UserModel*)teacherModel {
    
    if(teacherModel == nil){
        return;
    }
    
    // update teacher views
    self.teacherView.defaultImageView.hidden = teacherModel.enableVideo ? YES : NO;
    [self.teacherView updateSpeakerEnabled:teacherModel.enableAudio];
    [self.teacherView updateUserName:teacherModel.userName];
}

- (void)updateTimeState {
    RoomModel *roomModel = self.educationManager.roomModel;
    if(roomModel.courseState == ClassStateInClass) {
        NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval currenTimeInterval = [currentDate timeIntervalSince1970];
        [self.navigationView initTimerCount:(NSInteger)currenTimeInterval - roomModel.startTime];
        [self.navigationView startTimer];
    } else {
        [self.navigationView stopTimer];
    }
}

- (void)updateChatViews {
    RoomModel *roomModel = self.educationManager.roomModel;
    BOOL muteChat = roomModel != nil ? roomModel.muteAllChat : NO;
    if(!muteChat) {
        UserModel *studentModel = self.educationManager.studentModel;
        muteChat = studentModel.enableChat == 0 ? YES : NO;
    }
    self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
    self.chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
}

- (void)updateStudentViews:(UserModel*)studentModel {
    
    if(studentModel == nil){
        return;
    }
    
    [self.studentView updateVideoImageWithMuted:studentModel.enableVideo == 0 ? YES : NO];
    [self.studentView updateAudioImageWithMuted:studentModel.enableAudio == 0 ? YES : NO];
    [self.studentView updateUserName:studentModel.userName];
    
    [self.educationManager muteRTCLocalVideo:studentModel.enableVideo == 0 ? YES : NO];
    [self.educationManager muteRTCLocalAudio:studentModel.enableAudio == 0 ? YES : NO];
}

- (void)setupSignalWithSuccessBolck:(void (^)(void))successBlock {

    NSString *appid = self.educationManager.eduConfigModel.appId;
    NSString *appToken = self.educationManager.eduConfigModel.rtmToken;
    NSString *uid = @(self.educationManager.eduConfigModel.uid).stringValue;
    
    WEAK(self);
    [self.educationManager initSignalWithAppid:appid appToken:appToken userId:uid dataSourceDelegate:self completeSuccessBlock:^{
        
        NSString *channelName = weakself.educationManager.eduConfigModel.channelName;
        [weakself.educationManager joinSignalWithChannelName:channelName completeSuccessBlock:^{
            if(successBlock != nil){
                successBlock();
            }
            
        } completeFailBlock:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"JoinSignalFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
        
    } completeFailBlock:^(NSInteger errorCode){
        NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"InitSignalFailedText", nil), (long)errorCode];
        [weakself showToast:errMsg];
    }];
}

- (void)setupRTC {
    
    EduConfigModel *configModel = self.educationManager.eduConfigModel;
    
    [self.educationManager initRTCEngineKitWithAppid:configModel.appId clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    
    WEAK(self);
    [self.educationManager joinRTCChannelByToken:configModel.rtcToken channelId:configModel.channelName info:nil uid:configModel.uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [weakself.educationManager.rtcUids addObject:uidStr];
        [weakself checkNeedRender];
    }];
}

- (IBAction)chatRoomViewShowAndHide:(UIButton *)sender {
    self.chatRoomViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.textFiledRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.chatRoomView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
}

- (void)checkNeedRender {
    
    if(self.educationManager.teacherModel != nil) {
        NSInteger teacherUid = self.educationManager.teacherModel.uid;
        if([self.educationManager.rtcUids containsObject:@(teacherUid).stringValue]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", teacherUid];
            NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
            if(filteredArray.count == 0){
                [self renderTeacherCanvas:teacherUid];
            }
            [self updateTeacherViews:self.educationManager.teacherModel];
        } else {
            [self removeTeacherCanvas];
        }
    } else {
        [self removeTeacherCanvas];
    }
    
    if(self.educationManager.studentModel != nil) {
        NSInteger studentUid = self.educationManager.studentModel.uid;
        if([self.educationManager.rtcUids containsObject:@(studentUid).stringValue]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", studentUid];
            NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
            if(filteredArray.count == 0){
                [self renderStudentCanvas:studentUid];
            }
            [self updateStudentViews:self.educationManager.studentModel];
        }
    }
}

- (void)renderTeacherCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.teacherView.videoRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
}

- (void)removeTeacherCanvas {
    
    self.teacherView.defaultImageView.hidden = NO;
    [self.teacherView updateUserName:@""];
    [self.teacherView updateSpeakerEnabled:NO];
}

- (void)renderShareCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
    
    self.shareScreenView.hidden = NO;
}

- (void)removeShareCanvas:(NSUInteger)uid {
    self.shareScreenView.hidden = YES;
}

- (void)renderStudentCanvas:(NSUInteger)uid {

    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.studentView.videoRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeLocal;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
}

- (void)closeRoom {
    
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    WEAK(self);
    [self.educationManager updateEnableVideoWithValue:!mute completeSuccessBlock:^{
        
        [weakself updateStudentViews:weakself.educationManager.studentModel];
        
        [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeVideo) value:mute success:^{
  
        } fail:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        [weakself updateStudentViews:weakself.educationManager.studentModel];
    }];
}

- (void)sendSignalWithType:(NSString *)type value:(BOOL)mute success:(void (^ _Nullable) (void))successBlock fail:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    SignalMessageInfoModel *model = [SignalMessageInfoModel new];
    model.uid = self.educationManager.eduConfigModel.uid;
    model.account = self.educationManager.eduConfigModel.userName;
    model.resource = type;
    model.value = mute ? 0 : 1;
    [self.educationManager sendSignalWithModel:model completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)muteAudioStream:(BOOL)mute {
    
    WEAK(self);
    [self.educationManager updateEnableAudioWithValue:!mute completeSuccessBlock:^{
        
        [weakself updateStudentViews:weakself.educationManager.studentModel];
        
        [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeAudio) value:mute success:^{

        } fail:^(NSInteger errorCode) {
          NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
          [weakself showToast:errMsg];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        [weakself updateStudentViews:weakself.educationManager.studentModel];
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark SignalDelegate
- (void)didReceivedSignal:(SignalMessageInfoModel *)model {
    WEAK(self);
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        [weakself updateTimeState];
        [weakself updateChatViews];
        
        [weakself.educationManager disableCameraTransform:roomInfoModel.room.lockBoard];
        
        if (model.uid == weakself.educationManager.teacherModel.uid) {

            [weakself updateTeacherViews:weakself.educationManager.teacherModel];
            
        } else if (model.uid == weakself.educationManager.studentModel.uid) {
            
            [weakself updateStudentViews:weakself.educationManager.studentModel];
        }
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        
    }];
}
- (void)didReceivedMessage:(MessageInfoModel *)model {
    [self.messageListView addMessageModel:model];
}
- (void)didReceivedReplaySignal:(MessageInfoModel *)model {
    [self.messageListView addMessageModel:model];
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {

    if(uid == kShareScreenUid) {
        [self renderShareCanvas: uid];
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids addObject:uidStr];
        [self checkNeedRender];
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    
    if (uid == kShareScreenUid) {
        [self removeShareCanvas: uid];
    } else if (uid == self.educationManager.teacherModel.uid) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids removeObject:uidStr];
        [self removeTeacherCanvas];
    }
}

- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade {
    
    switch (grade) {
        case RTCNetworkGradeHigh:
            [self.navigationView updateSignalImageName:@"icon-signal3"];
            break;
        case RTCNetworkGradeMiddle:
            [self.navigationView updateSignalImageName:@"icon-signal2"];
            break;
        case RTCNetworkGradeLow:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
        default:
            break;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSString *content = textField.text;
    if (content.length > 0) {
        MessageInfoModel *model = [MessageInfoModel new];
        model.account = self.educationManager.eduConfigModel.userName;
        model.content = content;
        WEAK(self);
        [self.educationManager sendMessageWithModel:model completeSuccessBlock:^{
            [weakself.messageListView addMessageModel:model];
        } completeFailBlock:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

#pragma mark EEPageControlDelegate
- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        }];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.sceneCount - 1  && self.sceneCount > 0) {
        self.sceneIndex ++;
        
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        }];
    }
}

- (void)lastPage {
    self.sceneIndex = self.sceneCount - 1;
    
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
    }];
}

- (void)firstPage {
    self.sceneIndex = 0;
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
    }];
}

-(void)setWhiteSceneIndex:(NSInteger)sceneIndex completionSuccessBlock:(void (^ _Nullable)(void ))successBlock {
    
    [self.educationManager setWhiteSceneIndex:sceneIndex completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            NSLog(@"Set scene index err：%@", error);
        }
    }];
}

#pragma mark EEWhiteboardToolDelegate
- (void)selectWhiteboardToolIndex:(NSInteger)index {
    
    NSArray<NSString *> *applianceNameArray = @[ApplianceSelector, AppliancePencil, ApplianceText, ApplianceEraser];
    if(index < applianceNameArray.count) {
        NSString *applianceName = [applianceNameArray objectAtIndex:index];
        if(applianceName != nil) {
            [self.educationManager setWhiteApplianceName:applianceName];
        }
    }
    
    BOOL bHidden = self.colorShowView.hidden;
    // select color
    if (index == 4) {
        self.colorShowView.hidden = !bHidden;
    } else if (!bHidden) {
        self.colorShowView.hidden = YES;
    }
}

#pragma mark WhitePlayDelegate
- (void)whiteRoomStateChanged {
    WEAK(self);
    [self.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
        weakself.sceneCount = sceneCount;
        weakself.sceneIndex = sceneIndex;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        [weakself.educationManager moveWhiteToContainer:sceneIndex];
    }];
}

@end
