#import "LuRequestModel.h" 

@protocol LFXDrawAwardLotteryProduct <NSObject> 
@end 

@interface LFXDrawAwardLotteryProduct : LuRequestModel <LuRequestDelegate>

@property(nonatomic, assign) NSInteger *position;

@property(nonatomic, copy) NSString *productDisplayName;

@property(nonatomic, assign) NSInteger *id;

@property(nonatomic, copy) NSString *productType;

@property(nonatomic, copy) NSString *productDisplayImage;


@end