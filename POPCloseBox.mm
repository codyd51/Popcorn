#import "POPCloseBox.h"

@implementation POPCloseBox
-(id)initWithFrame:(CGRect)frame bundleID:(NSString*)bundleID {
    if ((self = [super initWithFrame:frame])) {
        self.layer.cornerRadius = 25;
        self.clipsToBounds = YES;

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = self.bounds;
        visualEffectView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.60];
        visualEffectView.clipsToBounds = YES;

        [self addSubview:visualEffectView];

        POPCloseButton* closeButton = [[POPCloseButton alloc] initWithFrame:frame bundleID:bundleID];
        self.closeButton = closeButton;
        [visualEffectView.contentView addSubview:closeButton];

    }
    return self;
}
@end