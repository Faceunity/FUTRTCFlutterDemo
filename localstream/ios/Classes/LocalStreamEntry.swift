//
//  LocalStreanEntrt.swift
//  localstream
//
//  Created by Chen on 2022/1/13.
//

import UIKit
import TXLiteAVSDK_Live

class LocalStreamEntry: NSObject {
    private var txCloudManager: TRTCCloud = TRTCCloud.sharedInstance();
    private var _textures: FlutterTextureRegistry?;
    init(registrar: FlutterPluginRegistrar?){
        _textures = registrar?.textures();
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setLocalVideoRenderListener" {
            var textureID :Int64? = 0;
            var isFront = false;
            if let args = call.arguments as? Dictionary<String, Any> {
                isFront = (args["isFront"] != nil);
            }
            
            txCloudManager.startLocalPreview(isFront, view: nil);
            // ios原生端需要修复,本地画面没有问题，但是远端看不到画面
            let render:LocalStreamRender = LocalStreamRender(frameCallback: ({
                self._textures?.textureFrameAvailable(textureID!);
            }),isLocal:true);
            txCloudManager.setLocalVideoProcessDelegete(render, pixelFormat: ._Texture_2D, bufferType: .pixelBuffer);
            textureID = self._textures?.register(render);
            NSLog("------------ setLocalVideoProcessDelegete  textureID: %lld", textureID ?? "---");
            result(textureID);
        }
    }
}
