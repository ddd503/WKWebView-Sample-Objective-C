//
//  ViewController.m
//  WKWebView-Sample-Objective-C
//
//  Created by kawaharadai on 2018/04/08.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKUIDelegate, WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) WKWebView *webView;
@end

static NSString *const RequestURL = @"https://www.apple.com/";

@implementation ViewController

#pragma mark - LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

#pragma mark - Private Methods
- (void)setup {
    [self setupWebView];
    [self setURL: RequestURL];
}

- (void)setupWebView {
    self.webView = [[WKWebView alloc] initWithFrame: CGRectZero
                                      configuration: [self setJS]];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.baseView addSubview: self.webView];
    [self setupWKWebViewConstain: self.webView];
    
}

- (void)setURL:(NSString *)requestURLString {
    NSURL *url = [[NSURL alloc] initWithString: requestURLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url
                                                  cachePolicy: NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval: 5];
    [self.webView loadRequest: request];
}

/// JSをセット
- (WKWebViewConfiguration *)setJS {
    NSString *jsString = @"";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource: jsString
                                                      injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
    WKUserContentController *wkUController = [WKUserContentController new];
    [wkUController addUserScript: userScript];
    
    WKWebViewConfiguration *wkWebConfig = [WKWebViewConfiguration new];
    wkWebConfig.userContentController = wkUController;
    
    return wkWebConfig;
}


/// autoLayoutをセット
- (void)setupWKWebViewConstain: (WKWebView *)webView {
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // ４辺のマージンを0にする
    NSLayoutConstraint *topConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeTop
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeTop
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *bottomConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeBottom
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeBottom
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *leftConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeLeft
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeLeft
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *rightConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeRight
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeRight
                                multiplier: 1.0
                                  constant: 0];
    
    NSArray *constraints = @[
                             topConstraint,
                             bottomConstraint,
                             leftConstraint,
                             rightConstraint
                             ];
    
    [self.baseView addConstraints:constraints];
}

#pragma mark - Action Methods
- (IBAction)back:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (IBAction)forword:(id)sender {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (IBAction)refresh:(id)sender {
    [self.webView reload];
}

#pragma mark - UIWebViewDelegate Methods
/// 新しいウィンドウ、フレームを指定してコンテンツを開く時
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (navigationAction.targetFrame != nil &&
        !navigationAction.targetFrame.mainFrame) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [[NSURL alloc] initWithString: navigationAction.request.URL.absoluteString]];
        [webView loadRequest: request];
        
        return nil;
    }
    return nil;
}

/// JSのalert実行時
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
}

/// JSのconfirm実行時
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
}

/// JSのprompt実行時
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
}

/// 指定された要素がプレビューを表示する許可
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo {
    return YES;
}

#pragma mark - WKNavigationDelegate Methods
/// ページ遷移前にアクセスを許可
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"アクセスURL：%@", navigationAction.request.URL.absoluteString);
    
    // どのページも許可
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 読み込み開始
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"読み込み開始");
}

// 読み込み完了
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"読み込み完了");
    [self.baseView bringSubviewToFront: self.toolbar];
}

// 読み込み失敗
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"読み込み失敗");
}

// 接続失敗
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"エラーコード：%ld", (long)error.code);
}

@end
