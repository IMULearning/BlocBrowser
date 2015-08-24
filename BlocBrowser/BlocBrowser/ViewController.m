//
//  ViewController.m
//  BlocBrowser
//
//  Created by Weinan Qiu on 2015-08-24.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

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
    
    // Init control buttons
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    [self.forwardButton setEnabled:NO];
    [self.stopButton setEnabled:NO];
    [self.reloadButton setEnabled:NO];
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back Command") forState:UIControlStateNormal];
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward Command") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop Command") forState:UIControlStateNormal];
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Refresh Command") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
    // Init web view
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    // add subviews
    for (UIView *eachView in @[self.webView,
                               self.urlTextField,
                               self.backButton,
                               self.forwardButton,
                               self.stopButton,
                               self.reloadButton]) {
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
    static const CGFloat buttonHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - textFieldHeight - buttonHeight;
    
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    self.urlTextField.frame = CGRectMake(0, 0, width, textFieldHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.urlTextField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        button.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, buttonHeight);
        currentButtonX += buttonWidth;
    }
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
    
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading;
}

@end
