
#import "LuRequestModel.h" 
#import "LFXDrawAwardRequestParam.h"
#import "LFXDrawAwardResponseResult.h"
@implementation LFXDrawAwardRequestParam
 
+(BOOL)propertyIsOptional:(NSString *)propertyName  
{ 
    return YES;
} 

/**
 * 老的mappcode请求的code
 * LU_ERQUEST_MODEL_NONE
 * @return a NSString mappCode 例：M3024
 */
- (NSString *)requestCode {
    
    return @"";
}

/**
 * 新的RESTFul的接口 URL PATH
 * LU_ERQUEST_MODEL_POST_DATA
 * @return a NSString path 例：/service/discovery/info/list
 */
- (NSString *)requestPath {
    
    return @"/service/lumi/lottery/send-lottery-request-v1";
}

/**
 * 需要自定义完整URL的请求
 * @return a NSString path 例：https://ma.lu.com/api/m-list/service/productList?listType=current
 */
- (NSString *)requestURL{
    
    return @"";
}

/**
 * urlParam 泳道参数 大部分接口不需要
 * @return a NSString 返回泳道参数，拼接到url后面
 */
- (NSString *)requestParam {
    
    return @"";
}

/**
 * ResponseModel的Class
 * 将接口JSON字段转化成ResponseModel实体model
 * @return a Class 例：[DiscoverResponseResult Class]
 */
-(Class)responseModelClass {
    
    return [LFXDrawAwardResponseResult class];
}

/**
 * 请求接口类型 __ENUM_LU_ERQUEST_MODEL
 * 常用的有：LU_ERQUEST_MODEL_QUERY(0):GET，LU_ERQUEST_MODEL_POST_MAPP(5):Restful POST, LU_ERQUEST_MODEL_NONE(6):m_code POST
 * @return a __ENUM_LU_ERQUEST_MODEL 返回枚举类型
 */
- (__ENUM_LU_ERQUEST_MODEL)requestType {
    
    return LU_ERQUEST_MODEL_POST_MAPP;
}

/**
 * 接口是否需要登录
 * @return a BOOL 例：YES代表登录
 */
- (BOOL)needLogin {
    return NO;
}

@end

