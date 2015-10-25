#import "POPCloseButton.h"
#import "Interfaces.h"

@implementation POPCloseButton
-(id)initWithFrame:(CGRect)frame bundleID:(NSString*)bundleID {
    if ((self = [super.class buttonWithType:UIButtonTypeCustom])) {
        [self addTarget:[NSClassFromString(@"SBIconController") sharedInstance] action:@selector(pop_unpop:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(dim) forControlEvents:(UIControlEventTouchDown | UIControlEventTouchDragInside)];
        [self addTarget:self action:@selector(undim) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchUpOutside | UIControlEventTouchCancel)];

        self.accessibilityHint = bundleID;

        [self setTitle:@"Close" forState:UIControlStateNormal];
        [self setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];

        self.frame = frame;

        _dimView = [[UIView alloc] initWithFrame:self.frame];
        _dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        _dimView.alpha = 0.0;
        _dimView.userInteractionEnabled = NO;
        [self addSubview:_dimView];
    }
    return self;
}
-(void)dim {
    _dimView.alpha = 1.0;
}
-(void)undim {
    _dimView.alpha = 0.0;
}
@end