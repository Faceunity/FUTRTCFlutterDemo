//
//  TRTCVideoCustomPreprocessor.h
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <TXLiteAVSDK_Professional/TRTCCloudDef.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCVideoCustomPreprocessor : NSObject

@property(nonatomic) float brightness;

- (void)invalidateBindedTexture;

- (GLuint)processTexture:(GLuint)textureId width:(uint32_t)width height:(uint32_t)height;

- (void)processFrame:(TRTCVideoFrame *)srcFrame dstFrame:(TRTCVideoFrame *)dstFrame;

@end

NS_ASSUME_NONNULL_END
