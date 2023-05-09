//
//  TencentVideoTextureRender.m
//  tencent_trtc_cloud
//
//  Created by gavinwjwang on 2021/3/30.
//

#import "LocalStreamRender.h"
#import "libkern/OSAtomic.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <FURenderKit/FURenderKit.h>
#import <FURenderKit/FUGLContext.h>
#import <string.h>

@implementation LocalStreamRender
{
    bool _isLocal;
    CVPixelBufferRef _localBuffer;
    CVPixelBufferRef _target;
    CVPixelBufferRef _latestPixelBuffer;
    FrameUpdateCallback _callback;
    // 使用纹理渲染时,记录当前glcontext
    EAGLContext *_mContext;

}

- (instancetype)initWithFrameCallback:(FrameUpdateCallback)calback isLocal:(bool)isLocal{
    if(self = [super init]) {
        _callback = calback;
        _isLocal = isLocal;
    }
    return self;
}
- (void)dealloc {
  if (_latestPixelBuffer) {
    CFRelease(_latestPixelBuffer);
  }
}
- (CVPixelBufferRef)copyPixelBuffer {
    if(_isLocal){
        if(_localBuffer != NULL)
            return  _localBuffer;
        return  NULL;
    }else{
        CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
        while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
            pixelBuffer = _latestPixelBuffer;
        }
        return pixelBuffer;
    }
}

- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType {
    if (frame.pixelBuffer != NULL) {
        CVPixelBufferRef newBuffer = frame.pixelBuffer;
        CFRetain(newBuffer);
        
        
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.renderConfig.isFromFrontCamera = YES;
        input.pixelBuffer = newBuffer;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];

        CVPixelBufferRef resultBuffer = output.pixelBuffer;

        if (frame.pixelFormat == TRTCVideoPixelFormat_NV12) {
            [self NV12PixelBufferCopySrcBuffer:resultBuffer desPixelBuffer:newBuffer];
        } else if (frame.pixelFormat == TRTCVideoPixelFormat_32BGRA) {
            [self rgbPixelBufferCopySrcBuffer:resultBuffer desPixelBuffer:newBuffer];
        } else {}
        
        
        _callback();
        CVPixelBufferRef old = _latestPixelBuffer;
        while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **)&_latestPixelBuffer)) {
          old = _latestPixelBuffer;
        }
        if (old != nil) {
          CFRelease(old);
        }
        CFRelease(newBuffer);
    }
}

- (void)NV12PixelBufferCopySrcBuffer:(CVPixelBufferRef)srcPixelBuffer desPixelBuffer:(CVPixelBufferRef)desPixelBuffer {
    CVPixelBufferLockBaseAddress(srcPixelBuffer, 0);
    CVPixelBufferLockBaseAddress(desPixelBuffer, 0);
    void *desStrdeY = CVPixelBufferGetBaseAddressOfPlane(desPixelBuffer, 0);
    void *desStrdeUV = CVPixelBufferGetBaseAddressOfPlane(desPixelBuffer, 1);
    
    //使用实际宽度而不是 stride
//    size_t desStrideY_size = CVPixelBufferGetBytesPerRowOfPlane(desPixelBuffer, 0);
//    size_t desStrideUV_size = CVPixelBufferGetBytesPerRowOfPlane(desPixelBuffer, 1);

    void *srcStrdeY = CVPixelBufferGetBaseAddressOfPlane(srcPixelBuffer, 0);
    void *srcStrdeUV = CVPixelBufferGetBaseAddressOfPlane(srcPixelBuffer, 1);
    //使用实际宽度而不是 stride
//    size_t srcStrideY_size = CVPixelBufferGetBytesPerRowOfPlane(srcPixelBuffer, 0);
//    size_t srcStrideUV_size = CVPixelBufferGetBytesPerRowOfPlane(srcPixelBuffer, 1);

    size_t desWidth = CVPixelBufferGetWidth(desPixelBuffer);
//    size_t desHeight = CVPixelBufferGetHeight(desPixelBuffer);
    
    size_t srcWidth = CVPixelBufferGetWidth(srcPixelBuffer);
    size_t srcHeight = CVPixelBufferGetHeight(srcPixelBuffer);
    
    size_t w_nv21 = ((srcWidth + 3) >> 2);
    size_t h_uv = ((srcHeight + 1) >> 1);

    //desStrideY 清零
//    memset(desStrdeY, 0, desStrideY_size);
    for (size_t i = 0; i < srcHeight; i ++) {
        //stride0 copy
        memcpy((void *)((size_t)desStrdeY + desWidth * i), (void *)((size_t)srcStrdeY + (w_nv21 * 4) * i), srcWidth);
//        memccpy();
    }
    
    //desStrideUV 清零
//    memset(desStrdeUV, 0, desStrideUV_size);
    size_t des_w_uv = 2 * ((desWidth + 1) >> 1);
    size_t src_w_uv = 2 * ((srcWidth + 1) >> 1);
    for (int i = 0; i < h_uv; i ++) {
        memcpy((void *)((size_t)desStrdeUV + i * des_w_uv), (void *)((size_t)srcStrdeUV + i * w_nv21 * 4), src_w_uv);
    }
    CVPixelBufferUnlockBaseAddress(desPixelBuffer, 0);
    CVPixelBufferUnlockBaseAddress(srcPixelBuffer, 0);
}


- (void)rgbPixelBufferCopySrcBuffer:(CVPixelBufferRef)srcPixelBuffer desPixelBuffer:(CVPixelBufferRef)desPixelBuffer {
    CVPixelBufferLockBaseAddress(srcPixelBuffer, 0);
    CVPixelBufferLockBaseAddress(desPixelBuffer, 0);
    
    void *srcBufferAddress = CVPixelBufferGetBaseAddress(srcPixelBuffer);
    size_t srcStride = CVPixelBufferGetBytesPerRow(srcPixelBuffer);
//    size_t srcWidth = CVPixelBufferGetWidth(srcPixelBuffer);
    size_t srcHeight = CVPixelBufferGetHeight(srcPixelBuffer);
    
    void *desBufferAddress = CVPixelBufferGetBaseAddress(desPixelBuffer);
    size_t desStride = CVPixelBufferGetBytesPerRow(desPixelBuffer);
//    size_t width = CVPixelBufferGetWidth(desPixelBuffer);
//    size_t desStride = width * 4;
//    size_t desHeight = CVPixelBufferGetHeight(desPixelBuffer);
    for (int i = 0; i < srcHeight; i ++) {
        memcpy((void *)((size_t)desBufferAddress + i * desStride), (void *)((size_t)srcBufferAddress + i * srcStride) , desStride);
    }
    
    CVPixelBufferUnlockBaseAddress(desPixelBuffer, 0);
    CVPixelBufferUnlockBaseAddress(srcPixelBuffer, 0);
}


- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *)srcFrame
                       dstFrame:(TRTCVideoFrame *)dstFrame {
    dstFrame.pixelBuffer = srcFrame.pixelBuffer;
    //走纹理
    if (srcFrame.textureId != 0) {
        CVPixelBufferRef buffer = srcFrame.pixelBuffer;
        _localBuffer = CVBufferRetain(buffer);
        
        
        _mContext = [EAGLContext currentContext];
        if ([FUGLContext shareGLContext].currentGLContext != _mContext) {
            [[FUGLContext shareGLContext] setCustomGLContext: _mContext];
        }
        
        if (![FURenderKit shareRenderKit].beauty || ![FURenderKit shareRenderKit].beauty.enable) {
            //无需处理人脸置信度和磨皮相关
        } else {
            if ([FURenderKit devicePerformanceLevel] == FUDevicePerformanceLevelHigh) {
                // 根据人脸置信度设置不同磨皮效果
                CGFloat score = [FUAIKit fuFaceProcessorGetConfidenceScore:0];
                if (score > 0.95) {
                    [FURenderKit shareRenderKit].beauty.blurType = 3;
                    [FURenderKit shareRenderKit].beauty.blurUseMask = YES;
                } else {
                    [FURenderKit shareRenderKit].beauty.blurType = 2;
                    [FURenderKit shareRenderKit].beauty.blurUseMask = NO;
                }
            } else {
                // 设置精细磨皮效果
                [FURenderKit shareRenderKit].beauty.blurType = 2;
                [FURenderKit shareRenderKit].beauty.blurUseMask = NO;
            }
        }


        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.renderConfig.isFromFrontCamera = YES;
        input.renderConfig.stickerFlipH = YES;
        FUTexture tex = {srcFrame.textureId, CGSizeMake(srcFrame.width, srcFrame.height)};
        input.texture = tex;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        input.renderConfig.textureTransform = CCROT0_FLIPVERTICAL;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
        dstFrame.textureId = output.texture.ID;
        
        //触发Flutter 调用 copyPixelBuffer
        _callback();
        
        if (output.texture.ID != 0) {
            return output.texture.ID;
        }
    }
    return 0;
}
@end
