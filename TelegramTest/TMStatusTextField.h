//
//  TMStatusTextField.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"

@class TMStatusTextField;

@protocol TMStatusTextFieldProtocol <NSObject>

- (void) TMStatusTextFieldDidChanged:(TMStatusTextField *)textField;

@end

@interface TMStatusTextField : TMTextField

@property (nonatomic, strong) id<TMStatusTextFieldProtocol> statusDelegate;

@property (nonatomic) SEL selector;

@property (nonatomic) BOOL selected;

@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGChat *chat;
@property (nonatomic, strong) TL_broadcast *broadcast;
@property (nonatomic,assign) BOOL lock;

-(void)update;

@end
