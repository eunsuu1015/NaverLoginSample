//
//  ViewController.h
//  NaverLoginSample
//
//  Created by Eunsuu1015 on 2021/11/22.
//

#import <UIKit/UIKit.h>
#import "SampleOAuthView.h"
#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>

@interface ViewController : UIViewController <SampleOAuthViewDelegate, NaverThirdPartyLoginConnectionDelegate> {
    NaverThirdPartyLoginConnection *_thirdPartyLoginConn;
    SampleOAuthView *_mainView;
}

@property (nonatomic, strong) SampleOAuthView *mainView;

@end

