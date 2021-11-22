//
//  ViewController.m
//  NaverLoginSample
//
//  Created by Eunsuu1015 on 2021/11/22.
//

#import "ViewController.h"
#import <SafariServices/SafariServices.h>

#define kServiceAppUrlScheme    @"naverlogin"
#define kConsumerKey            @"Client ID"
#define kConsumerSecret         @"Client Secret"
#define kServiceAppName         @"App Name"

@interface ViewController ()

@property(nonatomic,strong) SFAuthenticationSession *authSession;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _thirdPartyLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];
    _thirdPartyLoginConn.delegate = self;
    
    _mainView = [[SampleOAuthView alloc] initWithFrame:CGRectZero];
    _mainView.delegate = self;
    
    [self.view addSubview:_mainView];
}

/// 네아로 2.0 로그인
- (void)requestThirdpartyLogin
{
    NSLog(@"%s start", __FUNCTION__);
    // NaverThirdPartyLoginConnection의 인스턴스에 서비스앱의 url scheme와 consumer key, consumer secret, 그리고 appName을 파라미터로 전달하여 3rd party OAuth 인증을 요청한다.
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    tlogin.delegate = self;
    [tlogin setConsumerKey:_mainView.ckeyTextField.text];
    [tlogin setConsumerSecret:_mainView.cSecretTextField.text];
    [tlogin setAppName:_mainView.appNameTextField.text];
    [tlogin setServiceUrlScheme:kServiceAppUrlScheme];
    [tlogin requestThirdPartyLogin];
}

- (void)requestAccessTokenWithRefreshToken
{
    NSLog(@"%s start", __FUNCTION__);
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    [tlogin setConsumerKey:_mainView.ckeyTextField.text];
    [tlogin setConsumerSecret:_mainView.cSecretTextField.text];
    [tlogin requestAccessTokenWithRefreshToken];
}

- (void)resetToken
{
    NSLog(@"%s start", __FUNCTION__);
    [_thirdPartyLoginConn resetToken];
}

- (void)requestDeleteToken
{
    NSLog(@"%s start", __FUNCTION__);
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    [tlogin requestDeleteToken];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } if ([[NaverThirdPartyLoginConnection getSharedInstance] isOnlyPortraitSupportedInIphone]) {
        return interfaceOrientation == UIInterfaceOrientationMaskPortrait;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait) |
        (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) |
        (interfaceOrientation ==UIInterfaceOrientationLandscapeRight);
    }
}


#pragma mark - SampleOAuthViewDelegate

- (void)didClickAuthenticateBtn:(SampleOAuthView *)view {
    NSLog(@"%s start", __FUNCTION__);
    [self requestThirdpartyLogin];
}

- (void)didClickShowOAuthStatusBtn:(SampleOAuthView *)view {
    NSString *oauthStatus = [NSString stringWithFormat:@"Access Token - %@\nAccess Token Expire date - %@\nRefresh Token - %@\nToken Type - %@\nAC isValid = %@", _thirdPartyLoginConn.accessToken, _thirdPartyLoginConn.accessTokenExpireDate, _thirdPartyLoginConn.refreshToken, _thirdPartyLoginConn.tokenType, (_thirdPartyLoginConn.isValidAccessTokenExpireTimeNow?@"YES":@"NO")];
    [_mainView setResultLabelText:oauthStatus];
}

- (void)didClickCheckNidTokenBtn:(SampleOAuthView *)view {
    if (NO == [_thirdPartyLoginConn isValidAccessTokenExpireTimeNow]) {
        [_mainView setResultLabelText:@"로그인 하세요."];
        return;
    }
    //xml
    //NSString *urlString = @"https://openapi.naver.com/v1/nid/getUserProfile.xml";  //  사용자 프로필 호출
    //json
    NSString *urlString = @"https://openapi.naver.com/v1/nid/me";
    
    [self sendRequestWithUrlString:urlString];
}

- (void)didClickGetUserProfileBtn:(SampleOAuthView *)view {
    if (NO == [_thirdPartyLoginConn isValidAccessTokenExpireTimeNow]) {
        [_mainView setResultLabelText:@"로그인 하세요."];
        return;
    }
    
    //xml
    //NSString *urlString = @"https://openapi.naver.com/v1/nid/getUserProfile.xml";  //  사용자 프로필 호출
    //json
    NSString *urlString = @"https://openapi.naver.com/v1/nid/me";

    [self sendRequestWithUrlString:urlString];
}

- (void)sendRequestWithUrlString:(NSString *)urlString {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", _thirdPartyLoginConn.accessToken];

    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *decodingString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Error happened - %@", [error description]);
                [_mainView setResultLabelText:[error description]];
            } else {
                NSLog(@"recevied data - %@", decodingString);
                [_mainView setResultLabelText:decodingString];
            }
        });
    }] resume];
}

- (void)didClickGetACTokenWithRefreshTokenBtn:(SampleOAuthView *)view {
    [self requestAccessTokenWithRefreshToken];
}

- (void)didClickGetResetBtn:(SampleOAuthView *)view {
    [self resetToken];
    [_mainView setResultLabelText:@"Reset token done!"];
}

- (void)didClickLogoutBtn:(SampleOAuthView *)view {
    [self requestDeleteToken];
}

- (void)didClickLoginCheckBtn:(SampleOAuthView *)view
{
    NSURL *asideURL = [NSURL URLWithString:@"https://m.naver.com/aside"];
    if(@available(iOS 11, *)) {
        _authSession = [[SFAuthenticationSession alloc] initWithURL:asideURL callbackURLScheme:nil completionHandler:^(NSURL * callbackURL, NSError * error){
        }];
        [_authSession start];
    } else {
        SFSafariViewController *loginCheckViewController = [[SFSafariViewController alloc] initWithURL:asideURL];
        
        [self presentViewController:loginCheckViewController animated:YES completion:nil];
    }
}


#pragma mark - OAuth20 deleagate

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
    NSLog(@"%s start", __FUNCTION__);
        NSLog(@"%s=[%@]", __FUNCTION__, error);
    [_mainView setResultLabelText:[NSString stringWithFormat:@"%@", error]];
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
    NSLog(@"%s start", __FUNCTION__);
    _thirdPartyLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];
        [_mainView setResultLabelText:[NSString stringWithFormat:@"OAuth Success!\n\nAccess Token - %@\n\nAccess Token Expire Date- %@\n\nRefresh Token - %@", _thirdPartyLoginConn.accessToken, _thirdPartyLoginConn.accessTokenExpireDate, _thirdPartyLoginConn.refreshToken]];
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
    NSLog(@"%s start", __FUNCTION__);
    _thirdPartyLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];
    [_mainView setResultLabelText:[NSString stringWithFormat:@"Refresh Success!\n\nAccess Token - %@\n\nAccess sToken ExpireDate- %@", _thirdPartyLoginConn.accessToken, _thirdPartyLoginConn.accessTokenExpireDate ]];
    
}
- (void)oauth20ConnectionDidFinishDeleteToken {
    NSLog(@"%s start", __FUNCTION__);
    [_mainView setResultLabelText:[NSString stringWithFormat:@"인증해제 완료"]];
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFinishAuthorizationWithResult:(THIRDPARTYLOGIN_RECEIVE_TYPE)receiveType
{
    NSLog(@"%s start", __FUNCTION__);
    NSLog(@"Getting auth code from NaverApp success!");
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailAuthorizationWithReceiveType:(THIRDPARTYLOGIN_RECEIVE_TYPE)recieveType
{
    NSLog(@"%s start", __FUNCTION__);
    NSLog(@"NaverApp login fail handler");
}



@end
