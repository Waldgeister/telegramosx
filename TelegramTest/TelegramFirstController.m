//
//  TelegramFirstResponder.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TelegramFirstController.h"
#define PERFORM_SELECTOR()  if([self.viewController respondsToSelector:sender.action]) [self controller:self.viewController performSelector:sender.action withObject:sender];
#import "TMMediaController.h"
#import "AboutViewControllerWindowController.h"
#import "Rebel/Rebel.h"

@interface TelegramFirstController ()
@property (nonatomic,strong) AboutViewControllerWindowController *aboutViewController;



@end

@implementation TelegramFirstController

- (id)init {
    self = [super init];
    if(self) {
      
    }
    return self;
}

- (void)controller:(TMViewController *)controller performSelector:(SEL)aSelector withObject:(id)anArgument {
    IMP imp = [controller methodForSelector:aSelector];
    if(imp) {
        void (*func)(id, SEL, id) = (void *)imp;
        func(controller, aSelector, anArgument);
    }
}

- (IBAction)newMessage:(NSMenuItem *)sender {
    [self controller:[Telegram leftViewController] performSelector:sender.action withObject:sender];
}

- (IBAction)newGroup:(NSMenuItem *)sender {
    [self controller:[Telegram leftViewController] performSelector:sender.action withObject:sender];
}

- (IBAction)newSecretChat:(NSMenuItem *)sender {
    [self controller:[Telegram leftViewController] performSelector:sender.action withObject:sender];
}

- (IBAction)logout:(NSMenuItem *)sender {
    [[Telegram delegate] logoutWithForce:NO];
}

- (IBAction)importContacts:(id)sender {
    [[NewContactsManager sharedManager] syncContacts:nil];
}
- (IBAction)openSettings:(id)sender {
    [[Telegram settingsWindowController] showWindow:sender];
    
}

- (IBAction)clearChatHistory:(NSMenuItem *)sender {
    PERFORM_SELECTOR();
}
- (IBAction)askQuestion:(id)sender {
    
    NSUInteger supportUserId = [SettingsArchiver supportUserId];
    
    __block TGUser *supportUser;
    
    
    dispatch_block_t block = ^ {
        TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:supportUser.n_id];
        
        if(!dialog) {
            dialog = [[DialogsManager sharedManager] createDialogForUser:supportUser];
            [dialog save];
        }
        
        [[Telegram rightViewController] showByDialog:dialog sender:self];
    };
    
    
    

    if(supportUserId) {
        supportUser = [[UsersManager sharedManager] find:supportUserId];
        if(supportUser) {
            block();
            return;
        }
    }
    
    [RPCRequest sendRequest:[TLAPI_help_getSupport create] successHandler:^(RPCRequest *request, TL_help_support *response) {
        
        supportUser = response.user;
        [[UsersManager sharedManager] add:@[supportUser]];
        
        [SettingsArchiver setSupportUserId:response.user.n_id];
        block();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(error.error_code == 502) {
            alert(NSLocalizedString(@"App.ConnectionError", nil), NSLocalizedString(error.error_msg, nil));
        }
        
        
    } timeout:5];

}

- (IBAction)settings:(id)sender {
    [[Telegram rightViewController] showUserInfoPage:[UsersManager currentUser]];
}
- (IBAction)showMedia:(id)sender {
     [[TMMediaController getCurrentController] show:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if(!self.viewController)
        return NO;
    
    if([Telegram delegate].mainWindow) {
        
        if(![Telegram delegate].mainWindow.isKeyWindow) {
            return NO;
        }
        
        if(menuItem.action == @selector(newMessage:)) {
            return YES;
        } else if(menuItem.action == @selector(newGroup:)) {
            return YES;
        } else if(menuItem.action == @selector(newSecretChat:)) {
            return YES;
        } else if(menuItem.action == @selector(logout:)) {
            return YES;
        } else if(menuItem.action == @selector(importContacts:)) {
            return YES;
        } else if(menuItem.action == @selector(settings:)) {
            return YES;
        } else if(menuItem.action == @selector(showMedia:)) {
            return [[Telegram rightViewController] isActiveDialog];
        } else if(menuItem.action == @selector(openSettings:)) {
            return YES;
        } else if(menuItem.action == @selector(askQuestion:)) {
            return YES;
        }
    }
    
    if(menuItem.action == @selector(aboutAction:))
        return YES;
    
    BOOL isRespondToSelector = [self.viewController respondsToSelector:menuItem.action];
    return isRespondToSelector;
}
- (IBAction)aboutAction:(id)sender {
    
    if(!self.aboutViewController) {
        self.aboutViewController = [[AboutViewControllerWindowController alloc] initWithWindowNibName:@"AboutViewControllerWindowController"];
    }
    
    [self.aboutViewController showWindow:self];
}

- (BOOL)closeAllPopovers {
    BOOL result = NO;
    NSWindow *mainWindow = [Telegram delegate].window;
    if(mainWindow.childWindows.count) {
        for(TMMenuPopoverWindow *window in mainWindow.childWindows) {
            if(([window isKindOfClass:[TMMenuPopoverWindow class]] || [window isKindOfClass:[RBLPopoverWindow class]]) && window.popover) {
                [window.popover close];
                result = YES;
            }
        }
    }
    return result;
}

- (void)backOrClose:(NSMenuItem *)sender {
    
    NSWindow *mainWindow = [Telegram delegate].window;
    if([self closeAllPopovers])
        return;
    
    if(mainWindow.attachedSheet) {
        [mainWindow.attachedSheet close];
        return;
    }
    
    if([[Telegram rightViewController] isModalViewActive]) {
        return [[Telegram rightViewController] hideModalView:YES animation:YES];
    }
    
    if([self.viewController respondsToSelector:@selector(backOrClose:)]) {
        [self controller:self.viewController performSelector:@selector(backOrClose:) withObject:nil];
        return;
    }
    
    [[Telegram rightViewController] navigationGoBack];
    return;
}

@end
