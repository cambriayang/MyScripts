
#import "LFXDrawAwardData.h" 
#import "LuRequestModel.h" 

@protocol LFXDrawAwardResponseResult <NSObject> 
@end 

@interface LFXDrawAwardResponseResult : LuRequestModel <LuRequestDelegate>

@property(nonatomic, strong) LFXDrawAwardData *data;

@property(nonatomic, copy) NSString *result;


@end