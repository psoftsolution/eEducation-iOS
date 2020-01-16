//
//  ReplayNavigationView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/12.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "ReplayNavigationView.h"


@interface ReplayNavigationView ()

@property (strong, nonatomic) IBOutlet UIView *navigationView;

@end

@implementation ReplayNavigationView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.navigationView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.navigationView];
        
        NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)closeReplay:(UIButton *)sender {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UINavigationController *nvc = (UINavigationController*)window.rootViewController;
    if(nvc != nil){
        [nvc.visibleViewController dismissViewControllerAnimated:YES completion:nil];
    }
}



@end
