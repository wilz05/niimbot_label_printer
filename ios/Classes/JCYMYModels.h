//version 3.2.8 20250315

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface JCSModelBase : NSObject

- (NSDictionary *)toDictionary ;

@end

@interface JCSColorSupport : JCSModelBase

/// 是否支持单色打印，默认所有机器都支持
@property (assign,nonatomic) BOOL normalMode;

/// 是否支持红黑双色打印
@property (assign,nonatomic) BOOL rbMode;

/// 是否支持灰阶打印
@property (assign,nonatomic) BOOL grayMode;

@property (assign,nonatomic) BOOL grayMode16;

@end


@interface JCSQualitySupport : JCSModelBase

/// 是否支持高质量打印
@property (assign,nonatomic) BOOL highQuality;

/// 是否支持高速度打印
@property (assign,nonatomic) BOOL highSpeed;


@end


@interface JCHalfCutLevel : JCSModelBase


/// 是否支持半切
@property (assign,nonatomic) BOOL supportHalfCut;

/// 支持的情况下才有意义，半切最大值
@property (assign,nonatomic) signed int max;

/// 支持的情况下才有意义，半切最小值
@property (assign,nonatomic) signed int min;


@end


@interface OutNetBean : JCSModelBase

/// 服务器类型 1.MQTT
@property (assign,nonatomic) int serverType;

/// 域名 50byte以内，长了会截取前50字节
@property (copy,nonatomic) NSString *domain;
/// 端口
@property (assign,nonatomic) uint16_t port;

/// clientId 30byte以内，长了会截取前30字节
@property (copy,nonatomic) NSString *clientId;

/// 用户名 80byte以内，长了会截取前80字节
@property (copy,nonatomic) NSString *userName;

/// 密码 30byte以内，长了会截取前30字节
@property (copy,nonatomic) NSString *password;

/// 推送主题数据 15byte以内，长了会截取前15字节
@property (copy,nonatomic) NSString *pushTheme;

/// 订阅主题数据 15byte以内，长了会截取前15字节
@property (copy,nonatomic) NSString *subscribeTheme;

@end

NS_ASSUME_NONNULL_END
