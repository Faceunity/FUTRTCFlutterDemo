import UIKit
import Flutter
import TXLiteAVSDK_Professional
import tencent_trtc_cloud
import TXCustomBeautyProcesserPlugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    lazy var customBeautyInstance: TRTCVideoCustomPreprocessor = {
        let customBeautyInstance = TRTCVideoCustomPreprocessor()
//        customBeautyInstance.brightness = 0.5
        return customBeautyInstance
    }()

    TencentTRTCCloud.register(customBeautyProcesserFactory: customBeautyInstance)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension TRTCVideoCustomPreprocessor: ITXCustomBeautyProcesserFactory {
    public func createCustomBeautyProcesser() -> ITXCustomBeautyProcesser {
        return self
    }
    
    public func destroyCustomBeautyProcesser() {
        invalidateBindedTexture()
    }
}

extension TRTCVideoCustomPreprocessor: ITXCustomBeautyProcesser {
    public func getSupportedPixelFormat() -> ITXCustomBeautyPixelFormat {
        return .Texture2D
    }
    
    public func getSupportedBufferType() -> ITXCustomBeautyBufferType {
        return .Texture
    }
    
    public func onProcessVideoFrame(srcFrame: ITXCustomBeautyVideoFrame, dstFrame: ITXCustomBeautyVideoFrame) -> ITXCustomBeautyVideoFrame {
        
        FURenderQueue.sync {
            let currentContext = EAGLContext.current()
            let glContext = FUGLContext.share().currentGLContext
            if currentContext != glContext {
                FUGLContext.share().setCustom(currentContext!)
            }
            let input = FURenderInput.init()
            input.texture = FUTexture(ID: srcFrame.textureId, size: CGSize(width: Double(srcFrame.width), height: Double(srcFrame.height)))
            input.renderConfig.gravityEnable = true
            input.renderConfig.imageOrientation = FUImageOrientationDown
            input.renderConfig.isFromFrontCamera = true
            input.renderConfig.isFromMirroredCamera = true
            input.renderConfig.textureTransform = CCROT0_FLIPVERTICAL
            if (FURenderKit.share().beauty != nil && FURenderKit.share().beauty?.enable == true) {
                FURenderKitManager.updateBeautyBlurEffect()
            }
            let output = FURenderKit.share().render(with: input)
            dstFrame.textureId = output.texture.ID
        }
        return dstFrame
    }
}
