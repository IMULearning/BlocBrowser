//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Weinan Qiu on 2015-08-24.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

#define color1 [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1]
#define color2 [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1]
#define color3 [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1]
#define color4 [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]

@class ViewController;

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UIButton *currentLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        self.currentTitles = titles;
        
        self.colors = [@[color1, color2, color3, color4] mutableCopy];
        
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *label = [[UIButton alloc] init];
            
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            
            label.titleLabel.textAlignment = NSTextAlignmentCenter;
            label.titleLabel.font = [UIFont systemFontOfSize:15];
            label.titleLabel.textColor = [UIColor whiteColor];
            [label setTitle:titleForThisLabel forState:UIControlStateNormal];
            
            [label addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [labelArray addObject:label];
        }
        self.labels = labelArray;
        [self rotateColorAndAssign];
        
        for (UIButton *label in self.labels) {
            [self addSubview:label];
        }
        
        // gesture recognizer setup
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

- (void) layoutSubviews {
    for (UILabel *label in self.labels) {
        NSUInteger index = [self.labels indexOfObject:label];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0, labelY = 0;
        
        if (index < 2) {
            labelY = 0;
        } else {
            labelY = labelHeight;
        }
        
        if (index % 2 == 0) {
            labelX = 0;
        } else {
            labelX = labelWidth;
        }
        
        label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

- (void) rotateColorAndAssign {
    UIColor *firstColor = [self.colors firstObject];
    [self.colors removeObject:firstColor];
    [self.colors addObject:firstColor];
    
    NSUInteger index = 0;
    for (UILabel *label in self.labels) {
        label.backgroundColor = [self.colors objectAtIndex:index++];
    }
}

#pragma mark - Button Enabling

- (void) setEnabled: (BOOL) enabled forButtonWithTitle: (NSString *) title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

#pragma mark - Gesture Handling

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:recognizer.scale];
        }
        
        recognizer.scale = 1;
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self rotateColorAndAssign];
    }
}

#pragma mark - Button Tap Handling

- (void) buttonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:button.titleLabel.text];
    }
}

@end
