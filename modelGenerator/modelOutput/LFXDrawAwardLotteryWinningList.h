
#import "LFXDrawAwardLotteryWinningListLotteryWinningDetailList.h" 
#import "LuRequestModel.h" 

@protocol LFXDrawAwardLotteryWinningList <NSObject> 
@end 

@interface LFXDrawAwardLotteryWinningList : LuRequestModel <LuRequestDelegate>

@property(nonatomic, assign) NSInteger *lotteryCount;

@property(nonatomic, strong) NSArray<LFXDrawAwardLotteryWinningListLotteryWinningDetailList *> *lotteryWinningDetailList;


@end