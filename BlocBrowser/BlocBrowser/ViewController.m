//
//  ViewController.m
//  BlocBrowser
//
//  Created by Weinan Qiu on 2015-08-24.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ViewController.h"
#import "AwesomeFloatingToolbar.h"
#import <WebKit/WebKit.h>

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AwesomeFloatingToolbar *toolbar;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void) loadView {
    
    // provide a container view for all other views
    UIView *mainView = [UIView new];
    
    // Init text url field view
    self.urlTextField = [[UITextField alloc] init];
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    self.urlTextField.returnKeyType = UIReturnKeyDone;
    self.urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.urlTextField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.urlTextField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.urlTextField.delegate = self;
    
    // Init web view
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    // Init control buttons
    self.toolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString,
                                                                        kWebBrowserForwardString,
                                                                        kWebBrowserStopString,
                                                                        kWebBrowserRefreshString]];
    self.toolbar.delegate = self;
    
    // add subviews
    for (UIView *eachView in @[self.webView,
                               self.urlTextField,
                               self.toolbar]) {
        [mainView addSubview:eachView];
    }
    
    self.view = mainView;
}

//- (void) loadWikipedia {
//    NSString *urlString = @"http://wikipedia.org";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:urlRequest];
//}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat textFieldHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - textFieldHeight;
    
    self.urlTextField.frame = CGRectMake(0, 0, width, textFieldHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.urlTextField.frame), width, browserHeight);
    
    self.toolbar.frame = CGRectMake(20, 100, 280, 60);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // init the activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *inputedText = textField.text;
    NSURL *url = [NSURL URLWithString:inputedText];
    
    if (!url.scheme) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", inputedText]];
    }
    
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    
    return NO;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    if (error.code != NSURLErrorCancelled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];

    }

    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

#pragma mark - Misc

- (void) updateButtonsAndTitle {
    NSString *title = [self.webView.title copy];
    if ([title length]) {
        self.title = title;
    } else {
        self.title = self.webView.URL.absoluteString;
    }
    
    if (self.webView.isLoading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.toolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.toolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.toolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.toolbar setEnabled:(![self.webView isLoading] && self.webView.URL) forButtonWithTitle:kWebBrowserRefreshString];
}

- (void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [WKWebView new];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.urlTextField.text = nil;
    [self updateButtonsAndTitle];
}

#pragma mark - AwesomeFloatingToolbarDelegate

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqualToString:kWebBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqualToString:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqualToString:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqualToString:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}

- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

@end
