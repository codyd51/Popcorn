#import "POPContentView.h"
#import "CDTContextHostProvider.h"

@implementation POPContentView
-(id)initWithFrame:(CGRect)frame contextHostView:(UIView*)contextHostView {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;

        _keyWindow = [[[NSClassFromString(@"SBIconController") sharedInstance] _rootFolderController] contentView];

        CGFloat closeBoxHeight = fmax(frame.size.height/12, frame.size.width/12);

        self.contextHostView = contextHostView;
        contextHostView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.70, 0.70);
        contextHostView.layer.cornerRadius = 10;
        contextHostView.layer.masksToBounds = YES;
        //the context host view slides up from the bottom of the screen
        contextHostView.center = CGPointMake(_keyWindow.center.x, _keyWindow.center.y*3 - closeBoxHeight/2);

        POPCloseBox* closeBox = [[POPCloseBox alloc] initWithFrame:CGRectMake(0, 0, fmin(contextHostView.frame.size.width, contextHostView.frame.size.height), closeBoxHeight) bundleID:[[CDTContextHostProvider sharedInstance] bundleIDFromHostView:contextHostView]];
        closeBox.center = CGPointMake(_keyWindow.center.x, contextHostView.frame.origin.y + contextHostView.frame.size.height + closeBox.frame.size.height);
        self.closeBox = closeBox;

        _blurView = [[_UIBackdropView alloc] initWithFrame:[[UIScreen mainScreen] bounds] autosizesToFitSuperview:NO settings:[NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:2]];
        _blurView.center = self.center;
        _blurView.alpha = 0.0;
        //don't allow them to interact with the HS while this is active
        _blurView.userInteractionEnabled = YES;

        [self addSubview:_blurView];
        [self addSubview:contextHostView];
        [self addSubview:closeBox];
    }
    return self;
}
-(void)fadeBlurIn {
    [UIView animateWithDuration:0.75 animations:^{
        _blurView.alpha = 1.0; 
    }];
}
-(void)presentMainContent {
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut) animations:^{
        CGPoint oldCenter = _contextHostView.center;
        _contextHostView.center = CGPointMake(oldCenter.x, oldCenter.y - _keyWindow.frame.size.height);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.5 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut) animations:^{
        CGPoint oldCenter = _closeBox.center;
        _closeBox.center = CGPointMake(oldCenter.x, oldCenter.y - _keyWindow.frame.size.height);
    } completion:nil];
}
@end