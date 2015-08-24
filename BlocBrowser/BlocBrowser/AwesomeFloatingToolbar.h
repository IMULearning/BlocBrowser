//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Weinan Qiu on 2015-08-24.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *) title;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;

@end

@interface AwesomeFloatingToolbar : UIView

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

- (instancetype) initWithFourTitles: (NSArray *) titles;

- (void) setEnabled: (BOOL) enabled forButtonWithTitle: (NSString *) title;


@end
