#import "POPCloseButton.h"

@interface POPCloseBox : UIView 
@property (nonatomic, retain) POPCloseButton* closeButton;
-(id)initWithFrame:(CGRect)frame bundleID:(NSString*)bundleID;
@end 