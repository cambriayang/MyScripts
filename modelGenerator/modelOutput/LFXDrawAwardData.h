
#import "LFXDrawAwardLotteryProduct.h" 

#import "LFXDrawAwardLotteryWinningList.h" 
#import "LuRequestModel.h" 

@protocol LFXDrawAwardData <NSObject> 
@end 

@interface LFXDrawAwardData : LuRequestModel <LuRequestDelegate>

@property(nonatomic, assign) NSInteger *userPoint;

@property(nonatomic, assign) NSInteger *loginStatus;

@property(nonatomic, copy) NSString *orderCode;

@property(nonatomic, assign) NSInteger *freeLotteryTime;

@property(nonatomic, assign) NSInteger *activityStatus;

@property(nonatomic, strong) LFXDrawAwardLotteryProduct *lotteryProduct;

@property(nonatomic, copy) NSString *activityChannel;

@property(nonatomic, strong) LFXDrawAwardLotteryWinningList *lotteryWinningList;


@end