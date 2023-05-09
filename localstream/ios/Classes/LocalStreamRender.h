//
//  TencentVideoTextureRender.h
//  tencent_trtc_cloud
//
//  Created by gavinwjwang on 2021/3/30.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import <TXLiteAVSDK_Live/TRTCCloud.h>
#import <TXLiteAVSDK_Live/TRTCCloudDef.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FrameUpdateCallback)(void);

@interface LocalStreamRender : NSObject<FlutterTexture ,TRTCVideoRenderDelegate,TRTCVideoFrameDelegate>


- (instancetype)initWithFrameCallback:(FrameUpdateCallback)calback isLocal:(bool)isLocal;

@end

NS_ASSUME_NONNULL_END
