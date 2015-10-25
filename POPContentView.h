#import "POPCloseBox.h"
#import "Interfaces.h"

@interface POPContentView : UIView {
    _UIBackdropView* _blurView;
    UIView* _keyWindow;
}
@property (nonatomic, retain) POPCloseBox* closeBox;
@property (nonatomic, retain) UIView* contextHostView;
-(id)initWithFrame:(CGRect)frame contextHostView:(UIView*)contextHostView;
-(void)fadeBlurIn;
-(void)presentMainContent;
@end