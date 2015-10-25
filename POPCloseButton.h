@interface POPCloseButton : UIButton {
    UIView* _dimView;
}
-(id)initWithFrame:(CGRect)frame bundleID:(NSString*)bundleID;
-(void)dim;
-(void)undim;
@end