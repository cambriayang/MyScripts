
@protocol LFXDrawAwardRequestParam <NSObject> 
@end 

@interface LFXDrawAwardRequestParam : LuRequestModel <LuRequestDelegate>

@property(nonatomic, copy) NSString *sourceType;

@property(nonatomic, copy) NSString *platform;

@property(nonatomic, copy) NSString *agentVersion;

@property(nonatomic, copy) NSString *activityCode;

@property(nonatomic, copy) NSString *rid;

@property(nonatomic, copy) NSString *ct;


@end
